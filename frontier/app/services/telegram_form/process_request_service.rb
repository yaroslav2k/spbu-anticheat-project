# frozen_string_literal: true

class TelegramForm::ProcessRequestService < ApplicationService
  input :telegram_form, type: TelegramForm, allow_nil: true
  input :telegram_chat, type: TelegramChat, allow_nil: true
  input :input, type: TelegramForm::ParseInputService::Input

  output :event, type: Symbol, allow_nil: true
  output :context, type: Hash, default: {}, allow_nil: true
  output :reason

  def call
    return self.event = :invalid_command if !input.command_type.start? && !telegram_chat

    service_result = "#{self.class}::#{input.command_type.upcase_first}".constantize.call(
      telegram_form:, telegram_chat:, input:
    )

    self.event = service_result.event
    self.context = service_result.context
    self.reason = service_result.reason
  end

  class Base < ApplicationService
    input :telegram_form, type: TelegramForm, allow_nil: true
    input :telegram_chat, type: TelegramChat, allow_nil: true
    input :input

    output :event
    output :context
    output :reason
  end

  class Start < Base
    def call
      ApplicationRecord.transaction do
        process_request
      end
    end

    private

      def process_request # rubocop:disable Metrics/PerceivedComplexity
        telegram_chat ||= TelegramChat
          .create!(username: input.username, external_identifier: input.chat_id)

        assignments = nil

        telegram_chat.telegram_forms.incompleted.take&.destroy!

        options = {}
        event, telegram_form_stage = if telegram_chat.completed? && (course = telegram_chat.latest_submitted_course)
          options = { course: }

          %i[updated_to_course_provided_stage course_provided]
        elsif telegram_chat.completed?
          %i[telegram_chat_group_provided telegram_chat_populated]
        else
          %i[updated_to_created_stage created]
        end

        telegram_chat.save! if telegram_chat.new_record?
        telegram_form = telegram_chat.telegram_forms.create!(telegram_chat:, stage: telegram_form_stage, **options)

        if event == :updated_to_course_provided_stage
          assignments = Assignment
            .joins(submissions: { telegram_form: :telegram_chat })
            .where(telegram_chat: { external_identifier: input.chat_id })
            .where(telegram_form: { course_id: telegram_form.course_id })
            .order(:created_at)

          assignments = telegram_form.course.assignments.where.not(id: assignments.ids)
        end

        self.event = event
        self.context = { telegram_form:, assignments: }.compact
      end
  end

  class Submit < Base
    def call
      # telegram_form = telegram_chat.telegram_forms.incompleted.sole
      # return failure! reason: :unable_to_process_record unless telegram_form
      tx_result = ApplicationRecord.transaction do
        telegram_form.update!(stage: :uploads_provided)
        telegram_chat.update!(last_submitted_course: telegram_form.course)

        true
      rescue ActiveRecord::RecordInvalid
        false
      end

      if tx_result
        Submission::ProcessJob.perform_later(telegram_form.submission)

        assignments = Assignment
                      .joins(submissions: { telegram_form: :telegram_chat })
                      .where(telegram_chat: { external_identifier: input.chat_id })
                      .where(telegram_form: { course_id: telegram_form.course_id })
                      .order(:created_at)

        self.event = :updated_to_uploads_provided_stage
        self.context = { assignments: }
      else
        self.reason = :missing_uploads
      end
    end
  end

  class Preview < Base
    FIELD_SEPARATOR = ": "

    def call
      preview = I18n.with_locale(:ru) do
        if telegram_form
          build_preview
        else
          I18n.t("no_telegram_form")
        end
      end

      self.event = :succeeded_preview
      self.context = { preview: }
    end

    private

      def build_preview
        field_pairs = [].tap do |fields|
          fields << [I18n.t("course"), handle_blank(telegram_form.course&.title)]
          fields << [I18n.t("assignment"), handle_blank(telegram_form.assignment&.title)]
          fields << [I18n.t("author_name"), handle_blank(telegram_chat.name)]
          fields << [I18n.t("author_group"), handle_blank(telegram_chat.group)]
          fields << [I18n.t("uploads"), handle_blank(telegram_form.submission&.uploads&.count)]
        end

        field_pairs.map { |field_pair| field_pair.join(FIELD_SEPARATOR) }.join("\n")
      end

      def handle_blank(value)
        value.presence || I18n.t("unspecified")
      end

      def telegram_chat
        @telegram_chat ||= telegram_form.telegram_chat
      end
  end

  class Reset < Base
    def call
      fail!(error: :unable_to_process_record) unless telegram_form

      tx_result = ApplicationRecord.transaction do
        telegram_chat.update!(last_submitted_course: nil)
        telegram_form.update!(stage: :telegram_chat_populated, course: nil)
      end

      self.event = if tx_result
        :telegram_chat_group_provided
      else
        :unable_to_process_record
      end
    end
  end

  class Unknown < Base
    def call
      if telegram_chat.status.created?
        telegram_chat.update!(status: "name_provided", name: input.message)
        self.event = :telegram_chat_name_provided
      elsif telegram_chat.status.name_provided?
        telegram_chat.update!(status: "group_provided", group: input.message)
        telegram_form.update!(stage: :telegram_chat_populated)
        self.event = :telegram_chat_group_provided
      elsif telegram_chat.status.group_provided?
        send(:"process_state_#{telegram_form.stage}")
      end
    end

    private

    def process_state_created
      self.event = :updated_to_created_stage
    end

    def process_state_telegram_chat_populated
      course = Course.find_by(title: input.message)

      if telegram_form.update(stage: "course_provided", course:)
        assignments = Assignment
          .joins(submissions: { telegram_form: :telegram_chat })
          .where(telegram_chat: { external_identifier: input.chat_id })
          .where(telegram_form: { course_id: telegram_form.course_id })
          .order(:created_at)

        assignments = telegram_form.course.assignments.where.not(id: assignments.ids)

        self.event = :updated_to_course_provided_stage
        self.context = { assignments: }
      else
        fail! error: :unable_to_process_record
      end
    end

    def process_state_course_provided
      assignment = telegram_form.course.assignments.find_by(title: input.message)

      if assignment && telegram_form.update(stage: "assignment_provided", assignment:)
        self.event = :updated_to_assignment_provided_stage
      else
        fail! error: :unable_to_process_record
      end
    end

    def process_state_assignment_provided
      submission = find_or_create_submission!(telegram_form)

      upload = create_upload!(submission) if submission.of_type.files_group?

      if telegram_form.update(submission:)
        if submission.of_type.files_group?
          self.event = :created_upload
          self.context = { upload: }
        elsif submission.of_type.git?
          self.event = :github_url_provided
          self.context = { url: submission.url }
        else
          raise "Unexpected submission type `#{submission.of_type}`"
        end
      else
        fail! error: :unable_to_process_record
      end
    end

    ###

    def find_or_create_submission!(telegram_form)
      if input.git_revision?
        telegram_form.assignment.submissions.git.create!(
          author_name: telegram_chat.name,
          author_group: telegram_chat.group,
          url: input.git_revision.repository_url,
          branch: input.git_revision.branch
        )
      else
        telegram_form.assignment.submissions.files_group.create_with(
          author_name: telegram_chat.name,
          author_group: telegram_chat.group
        ).find_or_create_by!({})
      end
    end

    def create_upload!(submission)
      Upload::CreateService.call(
        submission:,
        attributes: {
          external_id: input.document.fetch(:file_id),
          external_unique_id: input.document.fetch(:file_unique_id),
          filename: input.document.fetch(:file_name),
          mime_type: input.document.fetch(:mime_type, "application/octet-stream"),
          source: :telegram
        }
      ).record
    end
  end
end

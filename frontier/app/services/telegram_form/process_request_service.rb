# frozen_string_literal: true

class TelegramForm::ProcessRequestService < ApplicationService
  subject :telegram_form

  context :telegram_chat
  context :input

  result_on_success :event, :context
  result_on_failure :reason

  def call
    return failure! reason: :invalid_command if !input.command_type.start? && !telegram_chat

    "#{self.class}::#{input.command_type.upcase_first}".constantize.call(
      telegram_form, telegram_chat:, input:
    )
  end

  class Base < ::ApplicationService
    subject :telegram_form

    context :telegram_chat
    context :input

    result_on_success :event, :context
    result_on_failure :reason
  end
  private_constant :Base

  class Start < Base
    def call
      ApplicationRecord.transaction do
        process_request
      end
    end

    private

      def process_request
        self.telegram_chat ||= TelegramChat
          .create!(username: input.username, external_identifier: input.chat_id)

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

        success! event:, context: { telegram_form: }
      end
  end
  private_constant :Start

  class Submit < Base
    def call
      # telegram_form = telegram_chat.telegram_forms.incompleted.sole
      # return failure! reason: :unable_to_process_record unless telegram_form
      tx_result = ApplicationRecord.transaction do
        telegram_form.update!(stage: :uploads_provided)
        telegram_chat.update!(last_submitted_course: telegram_form.course)
      rescue ActiveRecord::RecordInvalid
        false
      end

      if tx_result
        Assignment::CreateJob.perform_later(telegram_form.submission)

        assignments = Assignment
                      .joins(submissions: { telegram_form: :telegram_chat })
                      .where(telegram_chat: { external_identifier: input.chat_id })
                      .where(telegram_form: { course_id: telegram_form.course_id })
                      .order(:created_at)

        success! event: :updated_to_uploads_provided_stage, context: { assignments: }
      else
        failure! reason: :missing_uploads
      end
    end
  end
  private_constant :Submit

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

      success! event: :succeeded_preview, context: { preview: }
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
  private_constant :Preview

  class Reset < Base
    def call
      return failure! reason: :unable_to_process_record unless telegram_form

      tx_result = ApplicationRecord.transaction do
        telegram_chat.update!(last_submitted_course: nil)
        telegram_form.update!(stage: :telegram_chat_populated, course: nil)
      end

      if tx_result
        success! event: :telegram_chat_group_provided
      else
        failure! reason: :unable_to_process_record
      end
    end
  end
  private_constant :Reset

  class Unknown < Base
    def call
      if telegram_chat.status.created?
        telegram_chat.update!(status: "name_provided", name: input.message)
        success! event: :telegram_chat_name_provided
      elsif telegram_chat.status.name_provided?
        telegram_chat.update!(status: "group_provided", group: input.message)
        telegram_form.update!(stage: :telegram_chat_populated)
        success! event: :telegram_chat_group_provided
      elsif telegram_chat.status.group_provided?
        send(:"process_state_#{telegram_form.stage}")
      end
    end

    private

    def process_state_created
      success! event: :updated_to_created_stage
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

        success! event: :updated_to_course_provided_stage, context: { assignments: }
      else
        failure! reason: :unable_to_process_record
      end
    end

    def process_state_course_provided
      assignment = telegram_form.course.assignments.find_by(title: input.message)

      if assignment && telegram_form.update(stage: "assignment_provided", assignment:)
        success! event: :updated_to_assignment_provided_stage
      else
        failure! reason: :unable_to_process_record
      end
    end

      def process_state_assignment_provided
        submission = create_submission!(telegram_form)
        upload = create_upload!(submission)

        if telegram_form.update(submission:)
          success! event: :created_upload, context: { upload: }
        else
          failure! reason: :unable_to_process_record
        end
      end

      ###

      def create_submission!(telegram_form)
        telegram_form.assignment.submissions.files_group.create!(
          author_name: telegram_chat.name,
          author_group: telegram_chat.group
        )
      end

      def create_upload!(submission)
        submission.uploads.create!(
          external_id: input.document.fetch(:file_id),
          external_unique_id: input.document.fetch(:file_unique_id),
          filename: input.document.fetch(:file_name),
          mime_type: input.document.fetch(:mime_type),
          source: :telegram
        )
      end
  end
  private_constant :Unknown
end

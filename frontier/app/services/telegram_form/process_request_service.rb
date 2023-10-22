# frozen_string_literal: true

class TelegramForm::ProcessRequestService < ApplicationService
  subject :telegram_form

  context :input

  result_on_success :event, :context
  result_on_failure :reason

  def call
    send(:"process_command_#{input.command_type}")
  end

  private

    def process_command_start
      TelegramForm.incompleted.find_by(
        chat_identifier: input.chat_id
      )&.destroy!

      telegram_form = TelegramForm.create!(
        chat_identifier: input.chat_id
      )

      success! event: :updated_to_created_stage, context: { telegram_form: }
    end

    def process_command_submit
      telegram_form = TelegramForm.incompleted.find_or_initialize_by(
        chat_identifier: input.chat_id
      )

      if telegram_form&.update(stage: :uploads_provided)
        Assignment::CreateJob.perform_later(telegram_form.submission)
        success! event: :updated_to_uploads_provided_stage
      else
        failure! reason: :unable_to_process_record
      end
    end

    def process_command_unknown
      send(:"process_state_#{telegram_form.stage}")
    end

    def process_state_created
      course = Course.find_by(title: input.message)
      if telegram_form.update(stage: "course_provided", course:)
        success! event: :updated_to_course_provided_stage
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
      if telegram_form.update(stage: "author_name_provided", author_name: input.message)
        success! event: :updated_to_author_name_provided_stage
      else
        failure! reason: :unable_to_process_record
      end
    end

    def process_state_author_name_provided
      if telegram_form.update(stage: "author_group_provided", author_group: input.message)
        success! event: :updated_to_author_group_provided_stage
      else
        failure! reason: :unable_to_process_record
      end
    end

    def process_state_author_group_provided
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
      telegram_form.assignment.submissions.files_group.first_or_create!(
        author_name: telegram_form.author_name,
        author_group: telegram_form.author_group
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

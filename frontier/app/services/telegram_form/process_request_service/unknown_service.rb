# frozen_string_literal: true

class TelegramForm::ProcessRequestService::UnknownService < TelegramForm::ProcessRequestService::ApplicationService
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

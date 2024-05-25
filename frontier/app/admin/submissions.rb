# frozen_string_literal: true

ActiveAdmin.register Submission do
  controller do
    def scoped_collection
      resources = resource_class.for(current_user)

      resources = resources.where(author_name: params[:author_name]) if params[:author_name].present?
      resources = resources.where(author_group: params[:author_group]) if params[:author_group].present?

      resources
    end
  end

  actions :index, :show

  config.sort_order = "created_at_desc"

  scope("Recent") { |scope| scope.where(created_at: DateTime.now.all_day) }

  index do
    column :assignment
    column :author_name
    column :status
    column :type

    column :sent_at

    column :plagiarism do
      s3_client = Aws::S3::Client.new
      raw_report =
        s3_client
          .get_object(bucket: Storage::PRIMARY.bucket, key: resource.assignment.nicad_report_storage_key)
          .body
          .read

      decorated_object = AssignmentDecorator.decorate(context: { raw_report: })

      if decorated_object.plagiarism_by_author_detected?(resource.author_name)
        link_to "+", report_admin_assignment_url(resource.assignment)
      else
        "--"
      end
    end

    actions
  end

  show do
    attributes_table do
      row :assignment
      row :author_name
      row :author_group
      row :status

      if submission.of_type.files_group?
        row :uploads do
          safe_join(
            submission.uploads.reduce([]) do |links, upload|
              links << link_to(upload.filename, upload.source_url, target: "_blank", rel: "noopener")
            end, tag.br
          )
        end
      elsif submission.of_type.git?
        row :"Github URL" do
          link_to submission.url, submission.url, target: "_blank", rel: "noopener"
        end

        row :branch do
          submission.branch
        end
      end
    end
  end
end

# frozen_string_literal: true

ActiveAdmin.register Assignment do
  actions :all

  controller do
    def scoped_collection
      resource_class.for(current_user)
    end
  end

  member_action :report, method: :get do
    s3_client = Aws::S3::Client.new

    object = s3_client.get_object(bucket: Rails.env.to_sym, key: resource.report_storage_key)

    render locals: { assignment: resource.decorate(context: { raw_report: object.body.read }) }
  end

  member_action :trigger_processing, method: :post do
    assignment = Assignment.for(current_user).find(params[:id])

    Assignment::DetectJob.perform_later(assignment, nil)

    redirect_back_or_to root_path, notice: "Job was enqueued successfuly"
  end

  permit_params :title, :course_id, :ngram_size, :threshold

  index do
    selectable_column

    column :course
    column :title

    column :report do |assignment|
      if assignment.has_report?
        safe_join(
          [].tap do |links|
            links << link_to("view", report_admin_assignment_url(assignment), target: "_blank", rel: "noopener")
            links << link_to("download", assignment.report_url, target: "_blank", rel: "noopener")
          end, ", "
        )
      else
        "N/A"
      end
    end

    column :actions do |assignment|
      link_to("process", trigger_processing_admin_assignment_path(assignment), method: :post)
    end

    actions
  end

  form do |f|
    f.semantic_errors

    tabs do
      tab :Main do
        f.inputs do
          input :title
          input :course_id, as: :select,
            collection: Course.all.for(current_user).map { |c| [c.title, c.id] },
            include_blank: false
        end
      end

      tab :"Algorithm options" do
        f.inputs do
          f.input :ngram_size
          f.input :threshold
        end
      end
    end

    f.actions
  end
end

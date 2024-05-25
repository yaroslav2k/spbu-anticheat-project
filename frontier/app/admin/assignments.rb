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

    raw_report =
      s3_client
        .get_object(bucket: Storage::PRIMARY.bucket, key: resource.nicad_report_storage_key)
        .body
        .read

    render locals: { assignment: resource.decorate(context: { raw_report: }) }
  end

  member_action :trigger_processing, method: :post do
    assignment = Assignment.for(current_user).find(params[:id])

    Assignment::DetectJob.perform_later(assignment, assignment.submissions.take)

    redirect_back_or_to root_path, notice: "Job was enqueued successfuly. Please note that processing may take a few minutes."
  end

  permit_params :title, :course_id, :algorithm, *DetectionMethod::ALL.map(&:name)

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
          f.input :algorithm,
            as: :select,
            collection: DetectionMethod::ALL.map(&:name).map { [_1, _1] },
            wrapper_html: { class: "algorithm-selection" },
            include_blank: false

          DetectionMethod::ALL.each do |detection_method|
            f.inputs class: "inputs algorithm-selection-group", data: { algorithm: detection_method.name },
              for: detection_method.name do |ff|
              detection_method.parameters.each do |parameter|
                ActiveAdmin::ViewsHelper.algorithm_parameter_input(
                  ff,
                  parameter,
                  input_html: {
                    value: f.object.public_send(detection_method.name.to_s)[parameter[:name]],
                    data: { not: detection_method.name, then: :hide, target: ".algorithm-selection" }
                  }
                )
              end
            end
          end
        end
      end
    end

    f.actions
  end
end

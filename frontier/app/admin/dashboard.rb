# frozen_string_literal: true

ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Assignments" do
          ul do
            Assignment.active.for(current_user).take(20).map do |assignment|
              li link_to(assignment.title, admin_assignment_path(assignment))
            end
          end
        end
      end

      column do
        panel "Recent submissions" do
          ul do
            Submission.for(current_user).includes(:assignment).recent.take(5).map do |submission|
              li link_to(submission, admin_submission_path(submission))
            end
          end
        end
      end
    end
  end
end

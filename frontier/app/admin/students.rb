# frozen_string_literal: true

ActiveAdmin.register_page "Students" do
  content do
    groups = if params.key?(:group_id)
      Group.where(id: params[:group_id])
    else
      Group.where(course: current_user.courses)
    end

    telegram_chats = TelegramChat.where(group: groups.pluck(:title))

    table do
      thead do
        tr do
          %w[Name Username Actions].each { th _1 }
        end
      end

      tbody do
        telegram_chats.each do |telegram_chat|
          tr do
            td telegram_chat.name
            td telegram_chat.username
            td link_to("submissions", admin_submissions_url(author_name: telegram_chat.name))
          end
        end
      end
    end
  end
end

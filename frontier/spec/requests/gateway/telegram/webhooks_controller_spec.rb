# frozen_string_literal: true

describe Gateway::Telegram::WebhooksController do
  describe "#notify" do
    def perform(params)
      post "/gateway/telegram/webhooks/notify", params: params
    end

    let(:telegram_client_double) { instance_double(Telegram::Bot::Client, send_message: true) }

    let(:chat_id_param) { 983_390_842 }
    let(:message_text_param) { "/start" }
    let(:params) do
      {
        update_id: 571_662_017,
        message: {
          message_id: 175,
          from: {
            id: 983_390_842,
            is_bot: false,
            first_name: "Yaroslav",
            username: "viralpraxis",
            language_code: "en"
          },
          chat: {
            id: 983_390_842,
            first_name: "Yaroslav",
            username: "viralpraxis",
            type: "private"
          },
          date: 1_697_742_886,
          text: message_text_param,
          entities: [{ "offset" => 0, "length" => 6, "type" => "bot_command" }]
        },
        webhook: {
          update_id: 571_662_017,
          message: {
            message_id: 175,
            from: {
              id: 983_390_842,
              is_bot: false,
              first_name: "Yaroslav",
              username: "viralpraxis",
              language_code: "en"
            },
            chat: {
              id: 983_390_842,
              first_name: "Yaroslav",
              username: "viralpraxis",
              type: "private"
            },
            date: 1_697_742_886,
            text: message_text_param,
            entities: [{ "offset" => 0, "length" => 6, "type" => "bot_command" }]
          }
        }
      }
    end

    before do
      allow(Telegram::Bot::Client).to receive(:new).and_return(telegram_client_double)
    end

    context "with invalid request" do
      specify do
        perform({})

        expect(telegram_client_double).not_to have_received(:send_message)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with new chat" do
      let(:telegram_form) { nil }

      specify do
        perform(params)

        expect(response).to have_http_status(:ok)
        expect(TelegramForm.sole).to be_initial
        expect(telegram_client_double).to have_received(:send_message).with(
          chat_id: chat_id_param.to_s, text: "Пожалуйста, веберите курс"
        ).once
      end

      it "persists an instance of `TelegramForm` model" do
        expect { perform(params) }.to change(TelegramForm, :count).from(0).to(1)
      end
    end

    context "with telegram form on `initial` stage" do
      let!(:telegram_form) { create(:telegram_form, :initial, chat_identifier: chat_id_param) }
      let(:course) { create(:course, title: "advanced-haskell") }

      let(:message_text_param) { course.title }

      specify do
        perform(params)

        expect(response).to have_http_status(:ok)
        expect(telegram_client_double).to have_received(:send_message).with(
          chat_id: chat_id_param.to_s, text: "Пожалуйста, веберите задание"
        ).once
      end

      it "does not persist any instances of `TelegramForm` model" do
        expect { perform(params) }.not_to change(TelegramForm, :count)
      end
    end

    context "with telegram form on `course_provided` stage" do
      let!(:telegram_form) { create(:telegram_form, :course_provided, chat_identifier: chat_id_param, course: course) }
      let(:course) { create(:course, title: "advanced-haskell") }
      let(:assignment) { create(:assignment) }

      let(:message_text_param) { assignment.identifier }

      specify do
        perform(params)

        expect(response).to have_http_status(:ok)
        expect(telegram_client_double).to have_received(:send_message).with(
          chat_id: chat_id_param.to_s, text: "Введите ФИО и группу"
        ).once
      end

      it "does not persist any instances of `TelegramForm` model" do
        expect { perform(params) }.not_to change(TelegramForm, :count)
      end
    end

    context "with telegram form on `assignment_provided` stage" do
      let!(:telegram_form) do
        create(
          :telegram_form,
          :assignment_provided,
          chat_identifier: chat_id_param,
          course: course,
          assignment: assignment
        )
      end
      let(:course) { create(:course, title: "advanced-haskell") }
      let(:assignment) { create(:assignment) }

      let(:message_text_param) { "Имя Рек ЭФ0123" }

      specify do
        perform(params)

        expect(response).to have_http_status(:ok)
        expect(TelegramForm.sole).to have_attributes(
          author: message_text_param
        )
        expect(telegram_client_double).to have_received(:send_message).with(
          chat_id: chat_id_param.to_s, text: "Введите задание (одним файлом)"
        ).once
      end

      it "does not persist any instances of `TelegramForm` model" do
        expect { perform(params) }.not_to change(TelegramForm, :count)
      end
    end
  end
end

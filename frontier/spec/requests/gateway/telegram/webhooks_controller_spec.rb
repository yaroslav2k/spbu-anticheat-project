# frozen_string_literal: true

describe Gateway::Telegram::WebhooksController do
  describe "#notify" do
    def perform(params)
      post "/gateway/telegram/webhooks/notify", params: params
    end

    let(:telegram_client_double) { instance_double(Telegram::Bot::Client, send_message: true) }

    let(:chat_id_param) { 983_390_842 }
    let(:message_text_param) { "/start" }
    let(:message_document_param) { nil }

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
          document: message_document_param,
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

    shared_examples "it does not persist any instances of `TelegramForm` model" do
      specify do
        expect { perform(params) }.not_to change(TelegramForm, :count)
      end
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

      before do
        create(:course, :active, title: "haskell")
        create(:course, :active, title: "python")
      end

      specify do
        perform(params)

        expect(response).to have_http_status(:ok)
        expect(TelegramForm.sole).to be_initial
        expect(telegram_client_double).to have_received(:send_message).with(
          chat_id:
          chat_id_param.to_s,
          text: "Пожалуйста, введите название доступного курса:\n\nhaskell\npython"
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

      it_behaves_like "it does not persist any instances of `TelegramForm` model"

      specify do
        perform(params)

        expect(response).to have_http_status(:ok)
        expect(telegram_client_double).to have_received(:send_message).with(
          chat_id: chat_id_param.to_s, text: "Пожалуйста, веберите задание"
        ).once
      end
    end

    context "with telegram form on `course_provided` stage" do
      let!(:telegram_form) { create(:telegram_form, :course_provided, chat_identifier: chat_id_param, course: course) }
      let(:course) { create(:course, title: "advanced-haskell") }
      let(:assignment) { create(:assignment) }

      let(:message_text_param) { assignment.identifier }

      it_behaves_like "it does not persist any instances of `TelegramForm` model"

      specify do
        perform(params)

        expect(response).to have_http_status(:ok)
        expect(telegram_client_double).to have_received(:send_message).with(
          chat_id: chat_id_param.to_s, text: "Введите ФИО и группу"
        ).once
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

      it_behaves_like "it does not persist any instances of `TelegramForm` model"

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
    end

    context "with telegram form on `author_provided` stage" do
      let!(:telegram_form) do
        create(
          :telegram_form,
          :author_provided,
          chat_identifier: chat_id_param,
          course: course,
          assignment: assignment,
          author: "Анна Ц ЭФ0123"
        )
      end
      let(:course) { create(:course, title: "advanced-haskell") }
      let(:assignment) { create(:assignment, course: course) }

      let(:message_text_param) { nil }
      let(:message_document_param) do
        {
          file_name: "Аленова_София_01.py",
          mime_type: "text/x-python",
          file_id: "BQACAgIAAxkBAAPAZTKE2NJ5njiw3SbtNWT7nRevMqgAArEyAAIGrJlJ_Rd7mB_MgmkwBA",
          file_unique_id: "AgADsTIAAgasmUk",
          file_size: 2035
        }
      end

      it_behaves_like "it does not persist any instances of `TelegramForm` model"

      specify do
        perform(params)

        expect(response).to have_http_status(:ok)
        expect(telegram_client_double).to have_received(:send_message).with(
          chat_id: chat_id_param.to_s, text: "Файл принят (Аленова_София_01.py)"
        ).once
        expect(Submission::FilesGroup.sole).to have_attributes(
          assignment: assignment,
          author: telegram_form.author
        )
        expect(Upload.sole).to have_attributes(
          external_id: "BQACAgIAAxkBAAPAZTKE2NJ5njiw3SbtNWT7nRevMqgAArEyAAIGrJlJ_Rd7mB_MgmkwBA",
          external_unique_id: "AgADsTIAAgasmUk",
          filename: "Аленова_София_01.py",
          mime_type: "text/x-python"
        )
      end

      specify do
        expect { perform(params) }.not_to have_enqueued_job(Assignment::CreateJob)
      end
    end

    context "with `/submit` command" do
      let!(:telegram_form) do
        create(
          :telegram_form,
          :author_provided,
          chat_identifier: chat_id_param,
          course: course,
          assignment: assignment,
          submission: submission,
          author: "Анна Ц ЭФ0123"
        )
      end
      let(:course) { create(:course, title: "advanced-haskell") }
      let(:assignment) { create(:assignment) }
      let(:submission) { create(:submission, :files_group, assignment: assignment) }

      let(:message_text_param) { "/submit" }

      it_behaves_like "it does not persist any instances of `TelegramForm` model"

      specify do
        perform(params)

        expect(telegram_client_double).to have_received(:send_message).with(
          chat_id: chat_id_param.to_s, text: "Решение принято"
        ).once
        expect(TelegramForm.sole).to be_completed
      end

      specify do
        expect { perform(params) }.to have_enqueued_job(Assignment::CreateJob).once
      end
    end
  end
end

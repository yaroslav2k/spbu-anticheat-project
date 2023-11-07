# frozen_string_literal: true

class TelegramForm::ProcessRequestService::PreviewService < TelegramForm::ProcessRequestService::ApplicationService
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

# frozen_string_literal: true

class TelegramForm::PreviewService < ApplicationService
  FIELD_SEPARATOR = ": "

  subject :telegram_form

  result_on_success :preview

  def call
    success! preview: I18n.with_locale(:ru) { build_preview }
  end

  private

    def build_preview
      field_pairs = [].tap do |fields|
        fields << [I18n.t("course"), handle_blank(telegram_form.course&.title)]
        fields << [I18n.t("assignment"), handle_blank(telegram_form.assignment&.title)]
        fields << [I18n.t("author_name"), handle_blank(telegram_form.author_name)]
        fields << [I18n.t("author_group"), handle_blank(telegram_form.author_group)]
        fields << [I18n.t("uploads"), handle_blank(telegram_form.submission&.uploads&.count)]
      end

      field_pairs.map { |field_pair| field_pair.join(FIELD_SEPARATOR) }.join("\n")
    end

    def handle_blank(value)
      value.presence || I18n.t("unspecified")
    end
end

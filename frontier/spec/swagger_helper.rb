# frozen_string_literal: true

RSpec.configure do |config|
  config.openapi_strict_schema_validation = true
  config.openapi_root = Rails.root.join("swagger")
  config.openapi_format = :yaml

  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "API V1",
        version: "v1",
        description: "This is the first version of my API"
      },
      servers: [
        {
          url: "https://{defaultHost}",
          variables: {
            defaultHost: {
              default: "www.example.com"
            }
          }
        }
      ],
      components: {
        securitySchemes: {
          bearer: {
            type: :http,
            scheme: :bearer
          }
        }
      }
    }
  }

  config.after(:each, type: :request) do |example|
    next unless response.content_type&.include?("json")
    next if response.parsed_body.blank?

    example.metadata[:response][:content] = {
      "application/json" => {
        examples: {
          example.metadata[:example_group][:description] => {
            value: response.parsed_body
          }
        }
      }
    }
  rescue JSON::ParserError
    nil
  end
end

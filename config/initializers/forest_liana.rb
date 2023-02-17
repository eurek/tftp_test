require "ext/forest_liana"

forest_config = Rails.application.secrets.forest

if Rails.env.development?
  # each developer has a different set of tokens, so we scope them by developer username
  forest_config = forest_config[ENV["USER"].to_sym]
end

ForestLiana.env_secret = forest_config&.fetch(:env_secret, nil)
ForestLiana.auth_secret = forest_config&.fetch(:auth_secret, nil)
ForestLiana.application_url = forest_config&.fetch(:application_url, nil)

Forest::LOCKBOX_TYPES_CORRESPONDENCES = {
  date: "Dateonly",
  float: "Number",
  string: "String"
}.freeze

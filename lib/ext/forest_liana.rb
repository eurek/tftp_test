# frozen_string_literal: true

require "forest_liana"

Rails.application.config.to_prepare do
  ::ForestLiana::SchemaAdapter.send(:include, ForestLianaSchemaAdapterIgnoreLockbox)
end

module ForestLianaSchemaAdapterIgnoreLockbox
  extend ActiveSupport::Concern

  included do
    public :get_schema_for_column

    alias_method :super_get_schema_for_column, :get_schema_for_column

    def get_schema_for_column(column)
      if column.name.ends_with?("_ciphertext") || column.name.ends_with?("_bidx")
        # let's ignore lockbox and blind index columns to make sure they never appear in ForestAdmin
        return nil
      end

      super_get_schema_for_column(column)
    end
  end
end

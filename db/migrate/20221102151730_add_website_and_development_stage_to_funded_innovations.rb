class AddWebsiteAndDevelopmentStageToFundedInnovations < ActiveRecord::Migration[6.1]
  def change
    add_column :funded_innovations, :website, :string
    add_column :funded_innovations, :development_stage, :string
  end
end

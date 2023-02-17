class AddWeightAndShortTitleOnContents < ActiveRecord::Migration[5.2]
  def change
    add_column :contents, :short_title, :string
    add_column :contents, :weight, :integer, nullable: false, default: 0
  end
end

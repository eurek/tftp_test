class CreateEvaluations < ActiveRecord::Migration[6.1]
  def change
    create_table :evaluations do |t|
      t.belongs_to :user
      t.belongs_to :innovation

      t.timestamps
    end
  end
end

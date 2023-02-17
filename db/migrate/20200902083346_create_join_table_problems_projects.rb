class CreateJoinTableProblemsProjects < ActiveRecord::Migration[5.2]
  def change
    create_join_table :problems, :projects do |t|
      # Commented two lines below because rails 6 now raise an error in this case
      # See https://github.com/rails/rails/issues/35448
      # t.references :problem, foreign_key: true
      # t.references :project, foreign_key: true
    end
  end
end

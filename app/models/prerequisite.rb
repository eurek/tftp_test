class Prerequisite < ApplicationRecord
  # dependent as the parent roadmap_task
  # necessary as the child roadmap_task
  belongs_to :dependent, foreign_key: "dependent_id", class_name: "RoadmapTask"
  belongs_to :necessary, foreign_key: "necessary_id", class_name: "RoadmapTask"
end

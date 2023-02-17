class Notification < ApplicationRecord
  belongs_to :subject, polymorphic: true

  paginates_per 10
end

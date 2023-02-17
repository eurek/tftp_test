class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include DatabaseContentModifier

  def self.table_exists?
    super()
  rescue PG::ConnectionBad, ActiveRecord::NoDatabaseError
    false
  end
end

module StatisticsConcern
  extend ActiveSupport::Concern

  class_methods do
    def select_objects_between(attribute, start_date, end_date)
      where(
        "#{attribute} BETWEEN ? AND ?", start_date, end_date
      )
    end
  end
end

module ContentSearch
  extend ActiveSupport::Concern

  included do

    private

    ransacker :title do |parent|
      Arel::Nodes::InfixOperation.new("->>", parent.table[:title_i18n], Arel::Nodes::SqlLiteral.new("'#{I18n.locale}'"))
    end

    ransacker :body do |parent|
      Arel::Nodes::InfixOperation.new("->>", parent.table[:body_i18n], Arel::Nodes::SqlLiteral.new("'#{I18n.locale}'"))
    end
  end
end

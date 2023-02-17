class ProblemDecorator < ApplicationDecorator
  delegate_all

  def meta_description
    if object.description.present?
      h.strip_tags(object.description)[0..160]
    end
  end
end

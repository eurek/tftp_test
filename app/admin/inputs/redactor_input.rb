class RedactorInput < Formtastic::Inputs::TextInput
  def input_html_options
    begin
      value = object.try(method, fallback: false)
    rescue ArgumentError
      value = object.try(method)
    end

    {
      value: value,
      "data-controller": "wysiwyg",
      "data-model": object.class,
      "data-id": object.id,
      "data-attribute": method
    }.merge(super)
  end
end

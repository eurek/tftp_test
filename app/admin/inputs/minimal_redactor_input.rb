class MinimalRedactorInput < Formtastic::Inputs::TextInput
  def input_html_options
    {
      value: object.send(method, fallback: false),
      "data-controller": "wysiwyg",
      "data-wysiwyg-type-value": "minimal"
    }.merge(super)
  end
end

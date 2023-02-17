module TranslatableInput
  def input_html_options
    {
      value: object.send(method, fallback: false)
    }.merge(super)
  end

  def hint_text
    object.send("#{method}_fr")
  end
end

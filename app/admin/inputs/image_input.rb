class ImageInput < Formtastic::Inputs::FileInput
  def to_html
    input_wrapping do
      label_html <<
        image_preview_content <<
        builder.file_field(method, input_html_options.merge(accept: "image/*"))
    end
  end

  private

  def image_preview_content
    @object.send(method).attached? ? image_preview_html : image_placeholder_html
  end

  def image_preview_html
    if @object.send(method).is_a?(ActiveStorage::Attached::Many)
      html = ""
      @object.send(method).map do |image|
        html << template.image_tag(image, class: "ImagePreview")
      end
      html.html_safe
    else
      template.image_tag(@object.send(method), class: "ImagePreview")
    end
  end

  def image_placeholder_html
    template.content_tag(:span, "No image")
  end
end

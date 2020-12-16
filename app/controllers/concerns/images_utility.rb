module ImagesUtility

  private

  def download_image(type, image)
    send_data(image, type: 'image/jpg', filename: "#{type}.jpg")
  end

  def show_image(image_html)
    render html: image_html.html_safe
  end

  def create_image(type, width, app_config, object)
    image_html = image_html(type, app_config, object, render_to: :jpg)
    kit = build_kit(image_html, "#{type.tr('_', '-')}.css", width)
    kit.to_jpg
  end

  def image_html(image_type, app_config, object,
                 render_to: nil, context: nil)

    object_sym = object.class.to_s.downcase.to_sym

    render_to_string(partial: image_type,
                     formats: :html,
                     locals: { app_config: app_config,
                               render_to: render_to,
                               context: context,
                               object_sym => object })
  end

  def build_kit(image_html, image_css, width)
    kit = IMGKit.new(image_html, encoding: 'UTF-8', width: width, quality: 100)
    kit.stylesheets << Rails.root.join('app', 'assets', 'stylesheets',
                                       image_css)
    kit
  end


  def allow_iframe_request
    response.headers.delete('X-Frame-Options')
    # https://stackoverflow.com/questions/17542511/
    # cannot-display-my-rails-4-app-in-iframe-even-if-x-frame-options-is-allowall
  end
end

module ImagesUtility

  private

  def download_image(type, width, image_html)
    kit = build_kit(image_html, "#{type.tr('_', '-')}.css", width)
    send_data(kit.to_jpg, type: 'image/jpg', filename: "#{type}.jpeg")
  end

  def show_image(image_html)
    render html: image_html.html_safe
  end

  def image_html(image_type, app_config, object)
    object_sym = object.class.to_s.downcase.to_sym
    render_to_string(partial: image_type,
                     locals: { app_config: app_config, 
                               render_to: params[:render_to]&.to_sym,
                               context: params[:context]&.to_sym,
                               object_sym => object})
  end

  def build_kit(image_html, image_css, width)
    kit = IMGKit.new(image_html, encoding: 'UTF-8', width: width, quality: 100)
    kit.stylesheets << Rails.root.join('app', 'assets', 'stylesheets',
                                       image_css)
    kit
  end

  def set_app_config
    # Need app config items for proof-of-membership
    @app_configuration = AdminOnly::AppConfiguration.last
  end

  def allow_iframe_request
    response.headers.delete('X-Frame-Options')
    # https://stackoverflow.com/questions/17542511/
    # cannot-display-my-rails-4-app-in-iframe-even-if-x-frame-options-is-allowall
  end
end

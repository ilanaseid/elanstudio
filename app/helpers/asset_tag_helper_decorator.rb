ActionView::Helpers::AssetTagHelper.class_eval do
  # this is the standard HTML element, not yet implemented by RoR
  def picture_tag(sources, default_img, options = {})
    options.symbolize_keys!

    if size = options.delete(:size)
      options[:width], options[:height] = size.split("x") if size =~ %r{^\d+x\d+$}
    end

    if sources.is_a?(Array)
      content_tag("picture") do
        sources = sources.map {
          |source|
          tag("source", source, true)
        }.join.html_safe

        options[:srcset] = default_img
        img = image_tag(default_img, options)
        ie9_open = '<!--[if IE 9]><video style="display: none;"><![endif]-->'
        ie9_close = '<!--[if IE 9]></video><![endif]-->'
        "#{ie9_open} #{sources} #{ie9_close} #{img}".html_safe
      end
    else
      # only one source, so use shorthand
      options[:srcset] = sources[:srcset]
      options[:media] = sources[:media]
      image_tag(default_img,options)
    end
  end

  # this is an application specific shortcut
  def simple_picture_tag(asset_object, version = :medium, options = {})
    picture_tag([
      {:media => "(min-width: 521px)", :srcset => asset_object.mounted_file.send(version).url},
      {:media => "(max-width: 520px)", :srcset => "#{asset_object.mounted_file.grid.url} 1x, #{asset_object.mounted_file.medium.url} 2x"},
      {:srcset => "#{asset_object.mounted_file.grid.url}"}
    ], asset_object.mounted_file.grid.url, options)
  end
end

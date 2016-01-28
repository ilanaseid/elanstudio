module ContentHelper

  def friendly_path(content)
    "/content#{content.friendly_url}"
  end

end

class Volume < ClearCMS::Content
  form_field :volume_number, :type=>Integer
  form_field :short_description, :formtastic_options=>{:as=>:text, :input_html=>{:maxlength=>215, :rows=>3, :class=>'input-xxlarge'}}

  has_many :chapters
  has_many :apartments


#   def friendly_path
#     "/volume/#{basename}"
#   end

  def current_volume?
    Volume.published.first.id == self.id 
  end

  def first_chapter_pub_date
    chapters.published.min(:publish_at)
  end

  def last_chapter_pub_date
    chapters.published.max(:publish_at)
  end

end

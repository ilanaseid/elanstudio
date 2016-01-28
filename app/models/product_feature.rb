class ProductFeature < ClearCMS::Content
  form_field :short_description, :formtastic_options=>{:as=>:text, :input_html=>{:maxlength=>215, :rows=>3, :class=>'input-xxlarge'}}
  form_field :custom_css, :formtastic_options=>{:as=>:text, :input_html=>{:rows=>5, :class=>'input-xxlarge'}}

  self.linked_content_filter={:types=>'Product'}


  def meta_description
    if self.short_description.present?
      self.short_description
    elsif self.content_block('description').try(:body)
      self.content_block('description').try(:body)
    else
      ""
    end
  end
end

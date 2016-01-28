class PersonalSelection < ClearCMS::Content

  form_field :customer_email, :formtastic_options=>{:as=>:text, :input_html=>{:maxlength=>215, :rows=>1, :class=>'input-xxlarge'}}
  form_field :short_description, :formtastic_options=>{:as=>:text, :input_html=>{:maxlength=>215, :rows=>3, :class=>'input-xxlarge'}}
  form_field :custom_css, :formtastic_options=>{:as=>:text, :input_html=>{:rows=>5, :class=>'input-xxlarge'}}

  form_field :end_time, :type=>DateTime, :formtastic_options=>{:label=>"End Time (Optional)", :input_html=>{:class=>'datetimepicker', :hint=>'This is the time at which the Personal Selection becomes Archived'}}

  self.linked_content_filter={:types=>'Product'}

  def archived?
    (end_time <= Time.now) if end_time
  end

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

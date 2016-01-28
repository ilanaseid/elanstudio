class Event < ClearCMS::Content

  form_field :start_time, :type=>DateTime, :formtastic_options=>{:input_html=>{:class=>'datetimepicker'}}
  form_field :end_time, :type=>DateTime, :formtastic_options=>{:input_html=>{:class=>'datetimepicker'}}

  form_field :apartment_id, :formtastic_options=>{:collection=>Apartment.all}

  belongs_to :apartment

end

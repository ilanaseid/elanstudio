class Apartment < ClearCMS::Content
  form_field :apartment_number, :type=>Integer

  form_field :volume_id, :type => BSON::ObjectId, :formtastic_options => {:collection => Volume.all}
  form_field :address, :formtastic_options => {:as => :text, :input_html => {:maxlength => 215, :rows => 3, :class => 'input-xxlarge'}}
  form_field :reference_city, :formtastic_options => {:as => :text, :input_html => {:maxlength => 215, :rows => 1, :class => 'input-xxlarge'}}

  form_field :email, :formtastic_options => {:as=>:text, :input_html => {:maxlength => 215, :rows => 1, :class => 'input-xxlarge'}}
  form_field :phone_number, :formtastic_options => {:as => :text, :input_html => {:maxlength => 215, :rows => 1, :class => 'input-xxlarge'}}
  form_field :hours, :formtastic_options=>{:as => :text, :input_html => {:maxlength => 215, :rows => 3, :class => 'input-xxlarge'}}
  form_field :open_close_times, :formtastic_options=>{:as => :text, :input_html => {:maxlength => 215, :rows => 3, :class => 'input-xxlarge'}}
  form_field :map_url, :formtastic_options=>{:as => :text, :input_html => {:maxlength => 215, :rows => 3, :class => 'input-xxlarge'}}
  form_field :services, :formtastic_options=>{:as => :text, :input_html => {:maxlength => 1024, :rows => 3, :class => 'input-xxlarge'}}

  field :spree_stock_location_id, :type => Integer

  belongs_to :volume
  has_many :events

  def has_upcoming_events
    self.events.select { |event| event.start_time.to_date > Date.today }.any?
  end

end

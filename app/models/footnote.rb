class Footnote < ClearCMS::Content
  before_save :set_searchable
  form_field :footnote_number, :type=>Integer
  form_field :short_description, :formtastic_options=>{:as=>:text, :input_html=>{:maxlength=>215, :rows=>3, :class=>'input-xxlarge'}}
  form_field :linked_item_limit, :type=>Integer, :formtastic_options=>{:min=>4, :max=>24, :step=>1, :hint=>'if blank, limit is 8 items'}
  form_field :custom_css, :formtastic_options=>{:as=>:text, :input_html=>{:rows=>5, :class=>'input-xxlarge'}}
  form_field :remerch_selected, :type=>Boolean, :formtastic_options=>{:label=>'Always Show A Related Merchandise Grid for this Footnote', :hint=>'Otherwise footnote only shows remerch grid if more than half go out of stock'}
  form_field :end_time, :type=>DateTime, :formtastic_options=>{:label=>"End Time (Optional)", :input_html=>{:class=>'datetimepicker', :hint=>'This is the time at which the Footnote becomes Archived'}}

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

  def assets_for_placement(placement)
    assets=super
    if assets.blank?
      case placement
        when :feature
          assets=[default_content_block.content_assets[0]]
        when :primary
          assets=[default_content_block.content_assets[1]]
        when :secondary
          #no fallback for secondary
      end
    end
    assets
  end

  def next_content
    @next_content ||= site.contents.published.where(:footnote_number.gt=>self.footnote_number).and({:_type=>'Footnote'}).not.lt(end_time: Time.now).without_options.asc(:footnote_number).limit(1).first
  end

  def previous_content
    @previous_content ||= site.contents.published.where(:footnote_number.lt=>self.footnote_number).and({:_type=>'Footnote'}).not.lt(end_time: Time.now).without_options.desc(:footnote_number).limit(1).first
  end

  def related_products(limit=25)
    begin
      result = Sunspot.more_like_this(self, Product) do
        fields :tags #:content #:tags #:content,:tags,:categories
        with :sort_weight, 1  #using sort weight here so that it doesn't include sold out, discontinued, or onsale with 1 being the equivalent of available
        paginate per_page: limit
        with :site_id, self.site.id
        with :status, 'PUBLISHED'
        with(:publish_at).less_than Time.now
      end
      return result.results
    rescue => e
      Airbrake.notify(e) if defined?(Airbrake)
      return []
    end
  end

   def set_searchable
    if self.archived?
      self.searchable=false
    else
      self.searchable=true
    end
    return true
  end

end

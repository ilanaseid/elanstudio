class Chapter < ClearCMS::Content
  before_save :set_searchable
  form_field :chapter_number, :type=>Integer
  # form_field :byline
  form_field :volume_id, :type=>BSON::ObjectId, :formtastic_options=>{:collection=>Volume.all}
  form_field :short_description, :formtastic_options=>{:as=>:text, :input_html=>{:maxlength=>215, :rows=>3, :class=>'input-xxlarge'}}
  form_field :linked_item_limit, :type=>Integer, :formtastic_options=>{:min=>4, :max=>24, :step=>1, :hint=>'if blank, limit is 8 items'}
  form_field :custom_css, :formtastic_options=>{:as=>:text, :input_html=>{:rows=>5, :class=>'input-xxlarge'}}
  form_field :remerch_selected, :type=>Boolean, :formtastic_options=>{:label=>'Always Show A Related Merchandise Grid for this Chapter', :hint=>'Otherwise chapter only shows remerch grid if more than half go out of stock'}
  form_field :end_time, :type=>DateTime, :formtastic_options=>{:label=>"End Time (Optional)", :input_html=>{:class=>'datetimepicker', :hint=>'This is the time at which the Chapter becomes Archived'}}

  belongs_to :volume

  self.linked_content_filter={:types=>'Product'}

#   def friendly_path
#     "/chapter/#{basename}"
#   end

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
    @next_content ||= site.contents.published.where(:chapter_number.gt=>self.chapter_number).and({:_type=>'Chapter'}).not.lt(end_time: Time.now).without_options.asc(:chapter_number).limit(1).first
  end

  def previous_content
    @previous_content ||= site.contents.published.where(:chapter_number.lt=>self.chapter_number).and({:_type=>'Chapter'}).not.lt(end_time: Time.now).without_options.desc(:chapter_number).limit(1).first
  end

  def related_products(limit=25)
    begin
      result = Sunspot.more_like_this(self, Product) do
        fields :tags #:content #:tags #:content,:tags,:categories
        #fields :tags
        #minimum_term_frequency 5
        with :sort_weight, 1  #using sort weight here so that it doesn't include sold out, discontinued, or onsale with 1 being the equivalent of available
        paginate per_page: limit
        with :site_id, self.site.id
        with :status, 'PUBLISHED'

#         with :_type, type
        with(:publish_at).less_than Time.now
        #order_by :sort_weight, :asc
        #order_by :score, :desc
        #order_by :publish_at, :desc
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

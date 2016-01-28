class Selection < ClearCMS::Content
  before_save :set_featured_time
  before_save :set_sort_weight
  before_save :set_searchable

  validates_presence_of :short_title

  form_field :short_title, :formtastic_options=>{:as=>:text, :input_html=>{:rows=>1, :maxlength=>25}}
  form_field :short_description, :formtastic_options=>{:as=>:text, :input_html=>{:maxlength=>215, :rows=>3, :class=>'input-xxlarge'}}
  form_field :custom_css, :formtastic_options=>{:as=>:text, :input_html=>{:rows=>5, :class=>'input-xxlarge'}}

  form_field :end_time, :type=>DateTime, :formtastic_options=>{:label=>"End Time (Optional)", :input_html=>{:class=>'datetimepicker', :hint=>'This is the time at which the Selection becomes Archived'}}

  field :featured_start_time
  field :is_featured

  self.linked_content_filter={:types=>'Product'}

  def archived?
    (end_time <= Time.now) if end_time
  end

  def next_selection
    if self.archived?
      # this is stupid and keeps them trapped in archived, but it's what they wanted.
      @next_selection ||= site.contents.published.reorder.where(:_type=>'Selection', :end_time.lt=>Time.now, :publish_at.gte=>self.publish_at, :_id.gt=>self._id).order_by(:publish_at.asc, :_id.asc).limit(1).first
    else
      @next_selection ||= site.contents.published.reorder.where(:_type=>'Selection', :publish_at.gte=>self.publish_at, :_id.gt=>self._id).not.lt(end_time: Time.now).order_by(:publish_at.asc, :_id.asc).limit(1).first
    end
  end

  def previous_selection
    if self.archived?
      # this is stupid and keeps them trapped in archived, but it's what they wanted.
      @previous_selection ||= site.contents.published.reorder.where(:_type=>'Selection', :end_time.lt=>Time.now, :publish_at.lte=>self.publish_at, :_id.lt=>self._id).order_by(:publish_at.desc, :_id.desc).limit(1).first
    else
      @previous_selection ||= site.contents.published.reorder.where(:_type=>'Selection', :publish_at.lte=>self.publish_at, :_id.lt=>self._id).not.lt(end_time: Time.now).order_by(:publish_at.desc, :_id.desc).limit(1).first
    end
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

  def related_selections(limit=4, type: self._type)
    begin
      result = Sunspot.more_like_this(self) do
        fields :tags, :content, :categories
        minimum_term_frequency 5
        paginate per_page: limit
        with :site_id, self.site.id
        with :sort_weight, 1
        with :status, 'PUBLISHED'
        with :_type, type
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

  def set_sort_weight
    self.sort_weight = 1
    self.sort_weight += 1 if self.archived?
  end

  private

  def set_featured_time
    # Featured selections appear in order of how recently they were set to be featured.
    self.featured_start_time = Time.now if self.is_featured && self.is_featured_changed?
  end

end

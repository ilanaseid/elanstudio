ClearCMS::Content.class_eval do

  before_validation :ensure_unique_basename
  before_create :set_random_sort_key

  field :random_sort_key, overwrite: true
  field :searchable, :type=>Boolean, overwrite: true
  field :sort_weight, :type=>Integer, overwrite: true
  field :source, overwrite: true
  index random_sort_key: 1

  #overriding this here because CH is using status and state for a complicated query
  scope :published, ->{ all.where(:state=>'Finished', :publish_at.lte => Time.now).not.lte(:expire_at => Time.now).desc(:publish_at) }

  def set_random_sort_key
    self.random_sort_key = rand
  end

  def ensure_unique_basename
    rename_basename if basename_already_taken?
  end

  def basename_already_taken?
    ClearCMS::Content.where(basename: /^#{self.basename}$/i, site_id: self.site.id, :_id.ne => self._id).any?
  end

  def rename_basename
    self.basename += "_#{Time.now.to_f.to_s.gsub('.','')}"
  end

  def default_image
    if default_content_block && default_content_block.content_assets.any?
      default_content_block.content_assets.asc(:order).first
    end
  end

  def default_image_url(version)
    default_image.nil? ? '/assets/fallback/default.png' : default_image.mounted_file.send(version).url
  end

  def assets_for_placement(placement)
    assets=[]
    if content_blocks.any? && default_content_block
      if default_content_block.content_assets.any?
        assets=default_content_block.content_assets.asc(:order).where(:placement=>/^#{placement.to_s}$/i).to_a
      end
    end
    assets
  end

  def friendly_path
    "#{Routes.send("#{self.class.to_s.underscore.downcase}_path", :basename=>self.basename)}"
  end

  def friendly_url
  end

  def content_block_types
    ClearCMS::ContentBlock::TYPES + ['description','details','sizing','shipping','summary','news','historical_description','hero','stories_feature','objects_feature']
  end

  def default_content_block
    @default_content_block ||= content_blocks.where(type: 'raw').first
  end

  def extended_content_block
    @extended_content_block ||= content_blocks.where(type: 'more').first
  end

  def content_block(type)
    content_blocks.where(type: type).first
  end

  def default_category
    categories.any? ? categories.first : 'none'
  end

  def display_category
    case default_category
    when 'food-drink'
      default_category.gsub('-',' + ').titlecase
    else
      default_category.gsub(/[-_]/,' ').titlecase
    end
  end

  searchable do
    text :brightpearl_sku
    integer :sort_weight
    boolean :searchable
  end

  def self.boosted_search(params)
    search do
      fulltext params[:search] do
        boost_fields :title => 500.0, :subtitle => 500.0
      end
      paginate :page => params[:page], :per_page => (params[:per_page] || Settings.pagination.per_page_less)
      with :site_id, params[:site_id]
      with :status, 'PUBLISHED'
      with :categories, params[:category] if (params[:category] && params[:category] != 'any')
      with :_type, params[:type] if (params[:type] && params[:type] != 'any')
      with(:publish_at).less_than Time.now

      any_of do
        with(:searchable,true)
        with(:searchable,nil)
      end

      if params[:sort_by] == "date"
        order_by :publish_at, :desc
      else
        order_by :sort_weight, :asc
        order_by :score, :desc
        order_by :publish_at, :desc
      end
    end
  end

  def self.type_search(params, site_id, per_page_preference)
    type = params[:type] || ""
    case type.strip.downcase
    when "stories"
      # for stories search results, search through both chapters and footnotes
      self.boosted_search(type: ['Chapter', 'Footnote'], search: params[:search], page: params[:page], per_page: params[:per_page], site_id: site_id).results
    when "objects"
      Product.boosted_search(search: params[:search], page: params[:page], per_page: per_page_preference, site_id: site_id).results
    when "selections"
      Selection.boosted_search(search: params[:search], page: params[:page], per_page: params[:per_page], site_id: site_id).results
    else
      [] # if the type doesn't match, blank array (no results)
    end
  end

  def related(limit=25,type: self._type)
    result = Sunspot.more_like_this(self) do
      fields :content
      minimum_term_frequency 5
      paginate per_page: limit
      with :site_id, self.site.id
      with :status, 'PUBLISHED'
      with :_type, type
      with(:publish_at).less_than Time.now
      order_by :sort_weight, :asc
      order_by :score, :desc
      order_by :publish_at, :desc
    end
    result.results
  end

  def self.random(count)
    random = rand
    if where(:random_sort_key.gt => random).count >= count
      where(:random_sort_key.gt => random).order_by(random_sort_key: :asc)
    else
      where(:random_sort_key.lt => random).order_by(random_sort_key: :desc)
    end.limit(count)
  end

  class ContentCache
    def self.clear
      puts "Cache clearing is overriden in #{__FILE__} and #{__LINE__}"
    end
  end

end

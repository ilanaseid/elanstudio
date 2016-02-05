require 'net/ftp'

class ProductFeedGenerator
  attr_reader :email

  FILENAME = 'Product_Feed.csv'
  CREDENTIALS = {
    host: Settings.effective_spend_ftp.host,
    username: Settings.effective_spend_ftp.username,
    password: Settings.effective_spend_ftp.password
  }

  def initialize(email='rebecca@elanstudio.com')
    @email = email
  end

  def publish
    generate && upload && notify
  end

  def spree_product_ids
    Product.published.internal.pluck(:spree_product_id)
  end

  def variants
    Spree::Variant.where(product_id: spree_product_ids).select {|x| x.total_on_hand > 2 }
  end

  def rows
    variants.map {|v| Row.new(v) }
  end

  def tempfile
    @tempfile ||= Rails.root.join('tmp', FILENAME)
  end

  def generate
    CSV.open(tempfile,"wb", {:col_sep => "\t"}) do |csv|
      csv << GoogleFeed::HEADERS
      rows.each { |row| csv << row.to_a }
    end
  end

  def notify
    attachments=[{name: FILENAME, content: File.read(tempfile)}]
    SystemMailer.general("#{email}",'Product Feed', 'Please find attached the CSV of products', attachments).deliver
  end

  def upload
    3.attempts(Timeout::Error, Net::HTTPBadResponse, Net::ProtocolError, Net::FTPReplyError) do
      Net::FTP.open(CREDENTIALS[:host]) do |ftp|
        ftp.passive = true
        ftp.login(CREDENTIALS[:username], CREDENTIALS[:password])
        ftp.putbinaryfile(File.new(tempfile), FILENAME)
      end
      return true
    end
  end

  class Row
    using Sanitization
    include ActionView::Helpers::SanitizeHelper
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::NumberHelper

    attr_reader :variant, :product

    def initialize(variant)
      @variant, @product = variant, variant.cms_product
    end

    def to_a
      to_h.values
    end

    def to_h
      {
        id: variant.sku,
        title: title,
        description: description,
        google_taxonomy: google_taxonomy,
        product_type: categories,
        item_link: "https://www.elanstudio.com#{product.friendly_path}",
        image_link: product.default_image.mounted_file.medium.url,
        condition: 'new',
        availability: 'in stock',
        price: price,
        brand: product.brand.title,
        mpn: variant.sku,
        identifier_exists: identifier_exists?,
        gender: gender,
        age_group: 'adult',
        color: color,
        size: size,
        item_group_id: item_group_id,
        material: '',
        adwords_grouping: '',
        adwords_labels: product.categories.join(', '),
        adwords_redirect: ''
      }
    end

    def title
      truncate(product.title, length: 150).encode('utf-8')
    end

    def description
      body = strip_tags(product.content_block('description').body)
      truncate(body, length: 5000, separator: '.').sanitize
    end

    def gender
      fashion? ? 'female' : 'unisex'
    end

    def size
      variant.options_label.presence || 'OS'
    end

    def identifier_exists?
      ['Collected by The Line', 'The Line'].include?(product.brand.title) ? 'FALSE' : 'TRUE'
    end

    def name_segments
      @name_segments ||= product.title.split('-')
    end

    def item_group_id
      truncate(name_segments.first.sanitize, length: 50)
    end

    def top_level
      GoogleFeed::TAXONOMY[product.primary_category.downcase.to_sym]
    end

    def sub_level
      top_level.try(:[], product.first_subcategory.downcase.to_sym)
    end

    def google_taxonomy
      sub_level || top_level
    end

    def categories
      [product.primary_category, product.first_subcategory].map(&:titleize).join(' > ')
    end

    def price
      number_to_currency(product.spree_product.price, format: "%n USD", delimiter: '')
    end

    def fashion?
      product.categories.map(&:capitalize).include?('Fashion')
    end

    def color
      if fashion? && name_segments.length > 1
        name_segments.last.gsub('/', '&#47').sanitize.strip
      else
        'unknown'
      end
    end
  end
end

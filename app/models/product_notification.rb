class ProductNotification < ActiveRecord::Base

  belongs_to :spree_variant, class_name: 'Spree::Variant'
  has_many :spree_stock_items, class_name: 'Spree::StockItem', foreign_key: 'variant_id', primary_key: 'spree_variant_id'

  validates_presence_of :email, :name, :spree_variant_id
  before_save :normalize_email

  scope :unsent, -> { where(sent_at: nil) }
  scope :in_stock_at_default_location, -> { joins(:spree_stock_items).where('stock_location_id IN (?) AND count_on_hand > 0', Spree::StockLocation.default.id) }

  def prepopulate_attributes(user)
    if user
      self.name = user.firstname + " " + user.lastname
      self.email = user.email
    else
      self.name = nil
      self.email = nil
    end
  end

  def normalize_email
    self.email = self.email.strip.downcase
  end

  def self.ready_to_send
    unsent.in_stock_at_default_location
  end

end

class WishlistItem < ActiveRecord::Base
  #attr_accessible :user_id, :spree_variant_id
  belongs_to :user
  
  validates_presence_of :user_id, :spree_variant_id
  validates_uniqueness_of :spree_variant_id, :scope=>:user_id, :message=>"You've already added this item to your wishlist."
  
  def variant
    Spree::Variant.find(spree_variant_id)
  end
  
  def product
    ClearCMS::Content.find_by(:spree_product_id=>variant.product_id)
  end
end

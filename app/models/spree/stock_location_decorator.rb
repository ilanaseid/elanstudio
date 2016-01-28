Spree::StockLocation.class_eval do

  def abbr
    I18n.t("pos.location_abbr.loc_#{id}")
  end

  def cms_apartment
    return nil if default # e-comm location will not have an apartment.
    @cms_apartment ||= Apartment.find_by(spree_stock_location_id: id)
  end

end

class DeleteOldSpreeTaxRatesOnOrders < ActiveRecord::Migration
  def up
  	Spree::Adjustment.joins('join spree_orders on spree_orders.id=spree_adjustments.adjustable_id').where(adjustable_type: 'Spree::Order').where('spree_orders.state not in (\'complete\',\'canceled\',\'returned\')').delete_all
  end
end

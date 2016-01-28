class SystemsController < ApplicationController


  def index
    authorize! :submit, Brightpearl::ResetStockLevels
  end

  def sync_stock

    authorize! :submit, Brightpearl::ResetStockLevels

    unfulfilled_orders = Utility::Brightpearl.unfulfilled_order_list

    if unfulfilled_orders.empty?
      flash[:alert]="YEahhhhhhh boyyyyyyyy! Resetting stock levels because BP says all orders are fulfilled...it will take a couple of minutes."
      Brightpearl::ResetStockLevels.perform_async
      redirect_to :action=>:index
    else
      flash[:error]="Couldn't reset stock because of #{unfulfilled_orders.length} unfulfilled order(s) in BP."
      @unfulfilled_orders = unfulfilled_orders.inspect
      render :action=>:index
      #SystemMailer.general('retailalerts@theline.com', "Stock Levels Can't Sync Due to Open Orders", "The following orders are preventing stock syncing: #{unfulfilled_orders.inspect}").deliver
      #pp r
    end



  end


  def sync_products

    authorize! :submit, Brightpearl::ResetStockLevels
    flash[:alert]="Okay! A job to sync products has been submitted.  It usually takes 15+ minutes to finish!"

    Brightpearl::SyncProducts.perform_async

    redirect_to :action=>:index

  end

end

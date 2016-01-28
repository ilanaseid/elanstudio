class ProductNotificationsController < ApplicationController

  def show
    @product_notification = ProductNotification.find_by(id: params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product_notification }
    end
  end

  def new
    @product=current_site.contents.find_by({:spree_product_id => params[:spree_product_id].to_i, _type: "Product"})
    @product_notification = ProductNotification.new(:spree_variant_id=>@product.spree_product.master.id)
    @product_notification.prepopulate_attributes(spree_current_user)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product_notification }
    end
  end

  def create
    @product_notification_params = product_notification_params
    @spree_variant=Spree::Variant.find(@product_notification_params[:spree_variant_id])
    @product=current_site.contents.find_by({:spree_product_id=>@spree_variant.product_id, _type: "Product"})

    @product_notification = ProductNotification.new(@product_notification_params)

    respond_to do |format|
      if @product_notification.save
        format.html { redirect_to @product_notification, notice: 'Product notification was successfully created.' }
        format.json { render json: @product_notification, status: :created, location: @product_notification }
      else
        format.html { render action: "new" }
        format.json { render json: @product_notification.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def product_notification_params
    params.require(:product_notification).permit(:name, :email, :spree_variant_id)
  end

end

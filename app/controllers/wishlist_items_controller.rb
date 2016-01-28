class WishlistItemsController < ApplicationController



  # GET /wishlist_items
  # GET /wishlist_items.json
  def index
    authorize! :read, WishlistItem.new
    @wishlist_items = spree_current_user.wishlist_items.page(params[:page]).per(params[:per_page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @wishlist_items }
    end
  end

  # GET /wishlist_items/1
  # GET /wishlist_items/1.json
#   def show
#     @wishlist_item = WishlistItem.find(params[:id])
#
#     respond_to do |format|
#       format.html # show.html.erb
#       format.json { render json: @wishlist_item }
#     end
#   end

  # GET /wishlist_items/new
  # GET /wishlist_items/new.json
  def new
    authorize! :create, WishlistItem.new
    @product=current_site.contents.find_by({:spree_product_id => params[:spree_product_id].to_i, _type: "Product"})
    @wishlist_item = WishlistItem.new(:spree_variant_id=>@product.spree_product.master.id)
    @spree_variant = params[:spree_variant_id].to_i

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @wishlist_item }
    end
  end

  # GET /wishlist_items/1/edit
#   def edit
#     @wishlist_item = WishlistItem.find(params[:id])
#   end

  # POST /wishlist_items
  # POST /wishlist_items.json
  def create
    authorize! :create, WishlistItem.new

    @spree_variant=Spree::Variant.find(params[:wishlist_item][:spree_variant_id])
    @product=current_site.contents.find_by({:spree_product_id=>@spree_variant.product_id, _type: "Product"})
    @wishlist_item = spree_current_user.wishlist_items.build(:spree_variant_id=>@spree_variant.id)

    respond_to do |format|
      if @wishlist_item.save
        format.html { render action: "show", notice: 'Wishlist item was successfully created.' }
        format.json { render json: @wishlist_item, status: :created, location: @wishlist_item }
      else
        format.html { render action: "new" }
        format.json { render json: @wishlist_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /wishlist_items/1
  # PUT /wishlist_items/1.json
#   def update
#     @wishlist_item = WishlistItem.find(params[:id])
#
#     respond_to do |format|
#       if @wishlist_item.update_attributes(params[:wishlist_item])
#         format.html { redirect_to @wishlist_item, notice: 'Wishlist item was successfully updated.' }
#         format.json { head :no_content }
#       else
#         format.html { render action: "edit" }
#         format.json { render json: @wishlist_item.errors, status: :unprocessable_entity }
#       end
#     end
#   end

  # DELETE /wishlist_items/1
  # DELETE /wishlist_items/1.json
  def destroy
    #authorize! :destroy, WishlistItem.new

      @wishlist_item = spree_current_user.wishlist_items.where(id: params[:id]).first

      if @wishlist_item
        authorize! :destroy, @wishlist_item
        @wishlist_item.destroy
      end

      respond_to do |format|
        format.html { redirect_to wishlist_items_path }
        format.json { head :no_content }
      end
  end
end

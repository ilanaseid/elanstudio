class ApartmentVisitsController < ApplicationController
  # GET /apartment_visits
  # GET /apartment_visits.json
#   def index
#     @apartment_visits = ApartmentVisit.all
#
#     respond_to do |format|
#       format.html # index.html.erb
#       format.json { render json: @apartment_visits }
#     end
#   end

  # GET /apartment_visits/1
  # GET /apartment_visits/1.json
  def show
    #@apartment_visit = ApartmentVisit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      #format.json { render json: @apartment_visit }
    end
  end

  # GET /apartment_visits/new
  # GET /apartment_visits/new.json
  def new
    @apartment_visit = ApartmentVisit.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @apartment_visit }
    end
  end

  # GET /apartment_visits/1/edit
#   def edit
#     @apartment_visit = ApartmentVisit.find(params[:id])
#   end

  # POST /apartment_visits
  # POST /apartment_visits.json
  def create
    @apartment_visit = ApartmentVisit.new(apartment_visit_param)

    respond_to do |format|
      if @apartment_visit.save
        Apartment::VisitNotifier.perform_async(@apartment_visit.id)
        format.html { redirect_to @apartment_visit, notice: 'Apartment visit was successfully created.' }
        format.json { render json: @apartment_visit, status: :created, location: @apartment_visit }
      else
        format.html { render action: "new" }
        format.json { render json: @apartment_visit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /apartment_visits/1
  # PUT /apartment_visits/1.json
#   def update
#     @apartment_visit = ApartmentVisit.find(params[:id])
#
#     respond_to do |format|
#       if @apartment_visit.update_attributes(params[:apartment_visit])
#         format.html { redirect_to @apartment_visit, notice: 'Apartment visit was successfully updated.' }
#         format.json { head :no_content }
#       else
#         format.html { render action: "edit" }
#         format.json { render json: @apartment_visit.errors, status: :unprocessable_entity }
#       end
#     end
#   end

  # DELETE /apartment_visits/1
  # DELETE /apartment_visits/1.json
#   def destroy
#     @apartment_visit = ApartmentVisit.find(params[:id])
#     @apartment_visit.destroy
#
#     respond_to do |format|
#       format.html { redirect_to apartment_visits_url }
#       format.json { head :no_content }
#     end
#   end
  private

  def apartment_visit_param
    params.require(:apartment_visit).permit(:name, :email, :what_time, :note)
  end

end

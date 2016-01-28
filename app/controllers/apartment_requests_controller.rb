class ApartmentRequestsController < ApplicationController


  # GET /apartment_requests/new
  # GET /apartment_requests/new.json
  def new
    @apartment_request = ApartmentRequest.new(:newsletter=>true)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @apartment_request }
    end
  end


  # POST /apartment_requests
  # POST /apartment_requests.json
  def create
    @apartment_request = ApartmentRequest.new(params[:apartment_request].merge(:utm_source=>session[:utm_source],:utm_medium=>session[:utm_medium]).permit(:first_name, :last_name, :email, :newsletter, :utm_source, :utm_medium))
    @email_subscriber   = EmailSubscriber.new(email: @apartment_request.email, utm_source: @apartment_request.utm_source, utm_medium: @apartment_request.utm_medium)

    respond_to do |format|
      if @apartment_request.save && @email_subscriber.save
        format.html { redirect_to @apartment_request, notice: 'Apartment request was successfully created.' }
        format.json { render json: @apartment_request, status: :created, location: @apartment_request }
      else
        format.html { render action: "new" }
        format.json { render json: @apartment_request.errors, status: :unprocessable_entity }
      end
    end
  end

end

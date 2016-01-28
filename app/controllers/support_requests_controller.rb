class SupportRequestsController < ApplicationController

  # GET /support_requests/new
  # GET /support_requests/new.json
  def new
    @support_request = SupportRequest.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @support_request }
    end
  end


  # POST /support_requests
  # POST /support_requests.json
  def create
    @support_request = SupportRequest.new(params[:support_request].permit(:email,:comment,:request_type))
    
    @support_request.user_environment=(request.env.select {|k,v| k.start_with?('HTTP_') || k.start_with?('REMOTE_')}).to_s 
    #@support_request.user_environment=request.env.select{|k,v|
    respond_to do |format|
      if @support_request.save
        format.html { redirect_to @support_request, notice: 'Support request was successfully created.' }
        format.json { render json: @support_request, status: :created, location: @support_request }
      else
        format.html { render action: "new" }
        format.json { render json: @support_request.errors, status: :unprocessable_entity }
      end
    end
  end

end

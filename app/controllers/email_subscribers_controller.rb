class EmailSubscribersController < ApplicationController

  def new
    @email_subscriber = EmailSubscriber.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @email_subscriber }
    end
  end

  def create
    @email_subscriber = EmailSubscriber.new(params[:email_subscriber].merge(:utm_source=>session[:utm_source],:utm_medium=>session[:utm_medium]).permit(:email, :utm_source, :utm_medium))
    @apartment_subscriber = ApartmentRequest.new(params[:email_subscriber].merge(:utm_source=>session[:utm_source],:utm_medium=>session[:utm_medium]).permit(:first_name, :last_name, :email, :newsletter, :utm_source, :utm_medium))

    respond_to do |format|
      if @email_subscriber.save && @apartment_subscriber.save
        format.html {
          if request.xhr?
            render :action => :thank_you, :layout => nil
          else
            redirect_to :root, notice: 'Email subscriber was successfully created.'
          end
        }
        format.json { render json: @email_subscriber, status: :created, location: root_url }
      else
        format.html { render action: "new" }
        format.json { render json: @email_subscriber.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @email_subscriber = EmailSubscriber.find(params[:id])
    params[:email_subscriber][:interests].try(:delete,"")

    respond_to do |format|
      if @email_subscriber.update_attributes(params[:email_subscriber].permit(:zipcode,:interests=>[]))
        format.html {
          if request.xhr?
            render :action => :thank_you, :layout => nil
          else
            redirect_to :root, notice: 'Email subscriber was successfully updated.'
          end
        }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @email_subscriber.errors, status: :unprocessable_entity }
      end
    end
  end

end

class ContentController < ApplicationController
  #respond_to :html, :atom, :xml

  helper_method :time_till_event, :event_rsvp_date, :trim_contact_info

  def index
    @contents=current_site.contents.published.where(:_type=>'Editorial').limit(2).skip(1)
    @hero_contents=current_site.contents.published.where(:_type=>'Editorial').limit(1)
    @beauty_products=current_site.contents.published.where(:_type=>'Product').and(:categories=>'beauty').limit(3)
    @fashion_products=current_site.contents.published.where(:_type=>'Product').and(:categories=>'fashion').limit(3)
    @home_products=current_site.contents.published.where(:_type=>'Product').and(:categories=>'home').limit(3)
  end

  def show
    @content=current_site.contents.published.where(:basename=>params[:basename].gsub('-','_')).first
  end

  def category
    @contents=current_site.contents.published.where(:categories=>params[:category]).and(:_type=>'Editorial').page(params[:page]).per(params[:per_page])
    @hero_contents=[]
  end

  def brand
    #@content=current_site.contents.published.and({:_type=>'Brand'},{:basename=>params[:basename]}).first
    @content=current_site.contents.where(:_type=>'Brand').find_by(:basename=>params[:basename])
    @active_products = @content.products.published.visible.weighted.where(:product_state.in=>['Current','Preview','External']).page(params[:page]).per(per_page_preference)
    @archived_products = @content.products.published.visible.weighted.where(:product_state=>'Discontinued')
  end

  # def stories
  #   respond_to do |format|
  #     format.html { @stories=current_site.contents.published.where(:_type.in=>['Chapter','Footnote']).not.lt(end_time: Time.now).without_options.desc(:publish_at).page(params[:page]).per(params[:per_page]||12) }
  #     format.xml { @stories=current_site.contents.published.where(:_type.in=>['Chapter','Footnote']).not.lt(end_time: Time.now).without_options.desc(:publish_at).limit(30) }
  #   end
  # end

  def page
    if params[:basename]
      @content=current_site.contents.and({:_type=>'Page'},{:basename=>params[:basename]}).first
    else
      @content=current_site.contents.published.where(:_type=>'Page').first
    end

    #TBD: this doesn't really need to be in every "page" long term, but is needed for home page
    @homepage_beauty_category=current_site.contents.published.where(:_type=>'ProductCategory').where(:categories.in=>['homepage_beauty']).first
    @beauty_products = @homepage_beauty_category ? @homepage_beauty_category.resolve_linked_contents(3) : []

    @homepage_fashion_category=current_site.contents.published.where(:_type=>'ProductCategory').where(:categories.in=>['homepage_fashion']).first
    @fashion_products = @homepage_fashion_category ? @homepage_fashion_category.resolve_linked_contents(3) : []

    @homepage_home_category=current_site.contents.published.where(:_type=>'ProductCategory').where(:categories.in=>['homepage_home']).first
    @home_products = @homepage_home_category ? @homepage_home_category.resolve_linked_contents(3) : []

    @selections = current_site.contents.published.where(:_type=>'Selection').not.lte(end_time: Time.now).skip(1).limit(4)
  end

  # def anthology
  #   @volumes = current_site.contents.published.where(:_type=>'Volume').page(params[:page]).per(params[:per_page]||16)
  #   @footnote_count = current_site.contents.published.where(:_type=>'Footnote').not.lt(end_time: Time.now).count
  #   @footnote_creation_date = (@footnote_count < 1) ? nil : current_site.contents.published.where(:_type=>'Footnote').last.publish_at
  # end

  # def volume
  #   #@content=current_site.contents.published.and({:_type=>'Volume'},{:basename=>params[:basename]}).first
  #   @volume=current_site.contents.where(:_type=>'Volume').find_by(:basename=>params[:basename])
  #   @chapters=@volume.chapters.published.not.lt(end_time: Time.now).without_options.desc(:chapter_number).page(params[:page]).per(params[:per_page]||16)
  # end

  # def chapter
  #   #@content=current_site.contents.published.and({:_type=>'Chapter'},{:basename=>params[:basename]}).first
  #   @content=current_site.contents.where(:_type=>'Chapter').find_by(:basename=>params[:basename])
  # end

  # def footnotes
  #   @footnotes=current_site.contents.published.where(:_type=>'Footnote').not.lt(end_time: Time.now).without_options.desc(:footnote_number).page(params[:page]).per(params[:per_page]||10)
  # end

  # def footnote
  #   @footnote=current_site.contents.where(:_type=>'Footnote').find_by(:basename=>params[:basename])
  # end

  def showrooms
    @apartments = current_site.contents.published.where(:_type => 'Apartment').to_a.reverse
    @future_events = current_site.contents.published.and({:_type => 'Event', :end_time.gte => Time.now}).without_options.desc('start_time').limit(10)
    @past_events = current_site.contents.published.and({:_type => 'Event', :end_time.lt => Time.now}).without_options.desc('start_time').limit(10)
  end

  def showroom
    location = params[:basename].gsub('_', ' ').titleize
    @content = current_site.contents.published.where(:_type=>'Apartment').find_by(:basename=>params[:basename])
    @future_events = current_site.contents.published.and({:_type=>'Event', :end_time.gte=>Time.now}).without_options.desc('start_time').limit(2).select { |fevent| fevent.apartment.title == location }
    @past_events = current_site.contents.published.and({:_type=>'Event', :end_time.lt=>Time.now}).without_options.desc('start_time').limit(2).select { |fevent| fevent.apartment.title == location }
  end

  def event
    @event = current_site.contents.published.where(:_type => 'Event').find_by(:basename => params[:basename])
    @apartment = @event.apartment
    @address = @apartment.address.sub("<br>\r\n", ', ')
    @is_past = Date.parse(@event.subtitle) < Date.today
    if @is_past
      @future_events = current_site.contents.published.and({ :_type => 'Event', :end_time.gte => Time.now }).without_options.desc('start_time')
    end
  end

  def packaging_exceptions

  end

  def returns_policy
  end

  def sizechart_shoes
    #render :layout => 'lightbox'
  end

  def sizechart_rtw
    #render :layout => 'lightbox'
  end

  def feedback
    #render :layout => 'lightbox'
  end

  def contact
    #render :layout => 'lightbox'
  end

  private

    def time_till_event(event_subtitle)
      parsed_event_date = Date.parse(event_subtitle)
      today = Date.today
      if today < parsed_event_date
        return "#{(parsed_event_date - today).to_i} days away"
      elsif today > parsed_event_date
        return "This event has passed"
      else
        return "Today"
      end
    end

    def event_rsvp_date(event)
      event_date = event.subtitle
      rsvp_date = Date.parse(event_date) + 1.week
      return "#{rsvp_date.strftime("%A")}, #{rsvp_date.strftime("%B")} #{rsvp_date.day.ordinalize}"
    end

    def trim_contact_info(address)
      address = address.split("\r\n").slice(0, 2)
      address[1] = address[1].gsub("<br>", "") if address.length > 1
      return address.join('').html_safe
    end

end

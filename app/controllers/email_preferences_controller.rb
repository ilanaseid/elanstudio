class EmailPreferencesController < ApplicationController

  def edit
    @email_preference = EmailPreference.new(email_param)
    render 'shared/_newsletter_subscriptions_edit', locals: { email_preference: @email_preference, show_close_link: true }, layout: false if request.xhr?
  end

  def update
    flash.now[:notice] = t('msg.email_preferences_updated') if EmailPreference.new(email_param).update_user_subscriptions(subscription_params.keys, group_params.keys, email_param)
    @email_preference = EmailPreference.new(email_param)
    request.xhr? ? (render 'shared/_newsletter_subscriptions_show', locals: { email_preference: @email_preference}, layout: false) : (render 'edit')
  end

  private

  def email_param
    params[:email] || spree_current_user.try(:email)
  end

  def subscription_params
    params[:subscriptions] || {}
  end

  def group_params
    subscription_params['groups'] || {}
  end

end

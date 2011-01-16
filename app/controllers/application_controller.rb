class ApplicationController < ActionController::Base
  protect_from_forgery


  helper_method :current_user

  protected

  def authenticate_user!
    redirect_to '/auth/sweetsuite' unless access_token
  end

  def access_token
    session[:access_token]
  end

  def current_user
    @user ||= MultiJson.decode(ss_api.get('profile.json'))['user']
  end

  def ss_api
    @ss_api ||= OAuth2::AccessToken.new(ss_client, access_token) 
  end
  
  def ss_client
    @ss_client ||= OAuth2::Client.new(SweetSuite.config.app_key, SweetSuite.config.app_secret, {:site => SweetSuite.config.auth_server} )
  end
end

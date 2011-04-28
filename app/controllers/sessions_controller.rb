class SessionsController < ApplicationController

  def create
    session[:access_token] = auth_hash['credentials']['token']
    redirect_to root_url
  end
  
  def failure
  end

  private

  def auth_hash
    env['omniauth.auth']
  end

end

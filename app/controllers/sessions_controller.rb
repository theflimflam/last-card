class SessionsController < ApplicationController
  def create
    # attach user to a session
    session[:user_id] = user.id
    redirect_to "/"
  end

  def destroy
    reset_session
    redirect_to "/"
  end

  private

  def user
    User.find_or_create_by(email: oauth_info.email) do |new_user|
      new_user.firstname = oauth_info.first_name
      new_user.name = oauth_info.name
      new_user.image = oauth_info.image
    end
  end

  def oauth_info
    request.env["omniauth.auth"].info
  end
end

class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email(params[:email].downcase)
    if user && user.authenticate(params[:password])
      session = log_in(user)
      user.password_digest = nil
      render :json => {user: user, session: session}
    else
      render :json => {error: "Incorrect email address or password entered"}
    end
  end

  def delete
    log_out
    redirect_to root_path
  end
end

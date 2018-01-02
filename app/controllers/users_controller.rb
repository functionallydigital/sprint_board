class UsersController < ApplicationController
  def create
    user = User.new(user_params)
    user.password = params[:password]
    user.password_confirmation = params[:password_confirmation]
    if user.save!
      render :json => {success: true}
    else
      render :json => {error: 'Creation Failed'}
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    user = user_session.user
    updateUser = User.find(params[:id])
    if user_session.is_active? && user.id == updateUser.id
      user_session.refresh
      if updateUser.update(user_params)
        render :json => {success: true}
      else
        render :json => {error: 'Update Failed'}
      end
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  def selector_list
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    if user_session.is_active?
      user_session.refresh
      render :json => {users: User.all.map{|user| user.for_selector}, roles: ProjectsUser::ROLES_LIST }
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end
end

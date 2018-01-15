class SprintsController < ApplicationController
  def show
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    sprint = Sprint.find(params[:id])
    user = user_session.user
    if user_session.is_active? && user.is_on_project?(sprint.project.id)
      user_session.refresh
      render :json => sprint.for_dashboard
    else
      render :json => {error: 'Invalid Session'}
    end
  end
end

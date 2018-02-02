class SprintsController < ApplicationController
  def create
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    user = user_session.user
    if user_session.is_active? && user.is_on_project?(params[:project_id])
      user_session.refresh
      sprint = Sprint.new(sprint_params)
      if sprint.save
        if sprint.set_stories
          render :json => sprint.project.for_backlog
        else
          sprint.delete
          render :json => {error: 'Creation Failed'}
        end
      else
        render :json => {error: 'Creation Failed'}
      end
    else
      render :json => {error: 'Invalid Session'}
    end
  end

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

  private

    def sprint_params
      params.require(:sprint).permit(:id, :start_date, :end_date, :points, :project_id)
    end
end

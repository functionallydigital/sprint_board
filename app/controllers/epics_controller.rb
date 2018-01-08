class EpicsController < ApplicationController
  def index
    @epics = Epic.all
  end

  def create
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    user = user_session.user
    if user_session.is_active? && user.is_on_project?(params[:project_id])
      user_session.refresh
      epic = Epic.new(epic_params)
      epic.position = Epic.where(project_id: params[:project_id]).order(:position).last.position + 1
      if epic.save
        render :json => epic
      else
        render :json => {error: 'Creation Failed'}
      end
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  def show
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    user = user_session.user
    epic = Epic.find(params[:id])
    if user_session.is_active? && user.is_on_project?(epic.project_id)
      render :json => epic.for_dashboard
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  def edit
    @project = Project.find(params[:project_id])
    @buttonText = "Update"
    @submitPath = project_epic_path
    @epic = Epic.find(params[:id])
  end

  def update
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    user = user_session.user
    epic = Epic.find(params[:id])
    if user_session.is_active? && user.is_on_project?(epic.project_id)
      user_session.refresh
      if epic.update(epic_params)
        render :json => epic.for_dashboard
      else
        render :json => {error: 'Update Failed'}
      end
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  def update_sprint_number
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    user = user_session.user
    epic = Epic.find(params[:id])
    if user_session.is_active? && user.is_on_project?(epic.project_id)
      user_session.refresh
      if epic.update(sprint_number: params['sprintNumber'])
        render :json => {success: true}
      else
        render :json => {error: 'Update Failed'}
      end
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  private

    def epic_params
      params.require(:epic).permit(:name, :project_id, :priority)
    end
end

class ProjectsController < ApplicationController
  def index
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    if user_session.is_active?
      user_session.refresh
      render :json => user_session.user.projects.map{|project| project.for_index}
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  def create
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    if user_session.is_active?
      user_session.refresh
      project = Project.new(project_params)
      if project.save
        if ProjectsUser.create(project_id: project.id, user_id: user_session.user.id)
          render :json => {success: true, projectId: project.id}
        else
          project.delete
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
    user = user_session.user
    if user_session.is_active? && user.is_on_project?(params[:id])
      user_session.refresh
      render :json => Project.find(params[:id]).for_dashboard
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  def edit
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    user = user_session.user
    if user_session.is_active? && user.is_on_project?(params[:id])
      user_session.refresh
      render :json => Project.find(params[:id]).for_edit
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  def update
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    user = user_session.user
    if user_session.is_active? && user.is_on_project?(params[:id])
      user_session.refresh
      project = Project.find(params[:id])
      if project.update(project_params)
        render :json => {success: true}
      else
        render :json => {error: 'Update Failed'}
      end
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  def destroy
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    user = user_session.user
    if user_session.is_active? && user.is_on_project?(params[:id])
      user_session.refresh
      project = Project.find(params[:id])
      if project.delete
        render :json => {success: true}
      else
        render :json => {error: 'Update Failed'}
      end
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  def backlog
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    user = user_session.user
    if user_session.is_active? && user.is_on_project?(params[:id])
      user_session.refresh
      render :json => Project.find(params[:id]).for_backlog
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  def add_user
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    user = user_session.user
    if user_session.is_active? && user.is_on_project?(params[:id])
      user_session.refresh
      if ProjectsUser.create(project_id: params[:id], user_id: params[:user][:value], role: params[:role][:value])
        render :json => User.find(params[:user][:value])
      else
        render :json => {error: 'Creation Failed'}
      end
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  def users
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    user = user_session.user
    if user_session.is_active? && user.is_on_project?(params[:id])
      user_session.refresh
      render :json => Project.find(params[:id]).users_list
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  def add_step
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    user = user_session.user
    if user_session.is_active? && user.is_on_project?(params[:id])
      user_session.refresh
      current_last = Status.where(project_id: params[:id]).order(:order).last.order
      if status = Status.create(project_id: params[:id], name: params[:stepName], order: current_last + 1)
        render :json => status
      else
        render :json => {error: 'Creation Failed'}
      end
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  private

    def project_params
      params.require(:project).permit(:name, :description, :start_date, :end_date, :sprint_length)
    end
end

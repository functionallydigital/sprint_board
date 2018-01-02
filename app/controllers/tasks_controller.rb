class TasksController < ApplicationController
  def create
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    user = user_session.user
    project = Story.find(params[:storyId]).project
    if user_session.is_active? && user.is_on_project?(project.id)
      user_session.refresh
      task = Task.new(task_params)
      task.story_id = params[:storyId]
      previous_task = Story.where(epic_id: task.story_id).order(:position).last
      task.position = previous_task ? previous_task.position + 1 : 1
      task.status_id = project.status.order(:order).first.id
      if task.save
        render :json => task.for_overview
      else
        render :json => {error: 'Creation Failed'}
      end
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  def update
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    user = user_session.user
    task = Task.find(params[:id])
    if user_session.is_active? && user.is_on_project?(task.project.id)
      user_session.refresh
      if task.update(task_params)
        render :json => task.for_overview
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
    task = Task.find(params[:id])
    if user_session.is_active? && user.is_on_project?(task.project.id)
      user_session.refresh
      if task.delete
        render :json => {success: true}
      else
        render :json => {error: 'Delete Failed'}
      end
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  private

    def task_params
      params.require(:task).permit(:title, :description, :story_id)
    end
end

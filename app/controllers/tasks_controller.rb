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

  def assign_user
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    user = user_session.user
    task = Task.find(params[:id])
    if user_session.is_active? && user.is_on_project?(task.project.id)
      if task.update(user_id: params[:value])
        user_session.refresh
        render :json => {success: true}
      else
        render :json => {error: 'Update Failed'}
      end
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  def update_stage
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    user = user_session.user
    task = Task.find(params[:id])
    story = task.story
    story_step = story.status_id
    final_step_id = task.project.final_sprint_step.id
    if (final_step_id == params[:newStep] && story.tasks.where.not(status_id: params[:newStep], id: params[:id]).empty?)
      story_step = params[:newStep]
    elsif (final_step_id != params[:newStep] && story.status_id == final_step_id)
      story_step = task.project.status.order(:order).first.id
    end
    if user_session.is_active? && user.is_on_project?(task.project.id)
      if task.update(status_id: params[:newStep]) && story.update(status_id: story_step)
        user_session.refresh
        render :json => {story: story.for_sprint_board, completion: task.sprint.completion}
      else
        render :json => {error: 'Update Failed'}
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

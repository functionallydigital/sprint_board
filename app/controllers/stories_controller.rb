class StoriesController < ApplicationController
  def create
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    user = user_session.user
    project = Epic.find(params[:epicId]).project
    if user_session.is_active? && user.is_on_project?(project.id)
      user_session.refresh
      story = Story.new(story_params)
      previous_story = Story.where(epic_id: params[:epicId]).order(:position).last
      story.epic_id = params[:epicId]
      story.position = previous_story ? previous_story.position + 1 : 1
      story.status_id = project.status.order(:order).first.id
      if story.save
        render :json => story.for_backlog
      else
        render :json => {error: 'Creation Failed'}
      end
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  def show
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    story = Story.find(params[:id])
    user = user_session.user
    if user_session.is_active? && user.is_on_project?(story.project.id)
      user_session.refresh
      render :json => story.for_dashboard
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  def edit
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    story = Story.find(params[:id])
    user = user_session.user
    if user_session.is_active? && user.is_on_project?(story.project.id)
      user_session.refresh
      render :json => story.for_edit
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  def update
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    user = user_session.user
    story = Story.find(params[:id])
    if user_session.is_active? && user.is_on_project?(story.project.id)
      user_session.refresh
      if story.update(story_params)
        render :json => story.for_dashboard
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
    story = Story.find(params[:id])
    if user_session.is_active? && user.is_on_project?(story.project.id)
      user_session.refresh
      if story.delete
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
    story = Story.find(params[:id])
    if user_session.is_active? && user.is_on_project?(story.project.id)
      if story.update(user_id: params[:value])
        user_session.refresh
        render :json => {success: true}
      else
        render :json => {error: 'Update Failed'}
      end
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  private

    def story_params
      params.require(:story).permit(:title, :description, :estimate, :priority, :acceptance_criteria, :epic_id)
    end
end

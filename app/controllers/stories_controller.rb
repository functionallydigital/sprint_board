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
      user_session.refresh
      if story.update(user_id: params[:value])
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
    story = Story.find(params[:id])
    if user_session.is_active? && user.is_on_project?(story.project.id)
      user_session.refresh
      if story.update(status_id: params[:newStep])
        render :json => {completion: story.sprint.completion}
      else
        render :json => {error: 'Update Failed'}
      end
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  def update_position
    user_session = Session.find_by(session_key: request.headers['SessionKey'])
    user = user_session.user
    story = Story.find(params[:id])
    if user_session.is_active? && user.is_on_project?(story.project.id)
      user_session.refresh
      if adjust_story_list(story.project, params[:newPosition], story)
        render :json => story.project.for_backlog
      else
        render :json => {error: 'Update Failed'}
      end
    else
      render :json => {error: 'Invalid Session'}
    end
  end

  private

    def story_params
      params.require(:story).permit(:id, :title, :description, :estimate, :priority, :acceptance_criteria, :epic_id)
    end

    def adjust_story_list(project, new_position, moved_story)
      old_position = moved_story.position
      if new_position > old_position #moving down the list
        project.stories.where(position: old_position..new_position).each do |story|
          story.update(position: (story.position - 1))
        end
        moved_story.update(position: new_position)
        #clear stories from sprint of moved story, and all later sprints, and reassign stories to the sprint.
        if !moved_story.sprint_id.nil?
          original_sprint = moved_story.sprint_id
          project.stories.where(sprint_id: original_sprint..Float::INFINITY).update_all(sprint_id: nil)
          project.sprints.where(id: original_sprint..Float::INFINITY).map{|sprint| sprint.set_stories}
        end
      else #moving up the list
        replaced_story = project.stories.find_by_position(new_position)
        project.stories.where(position: new_position..old_position).each do |story|
          story.update(position: (story.position + 1))
        end
        moved_story.update(position: new_position)
        #clear stories from sprint of story currently at new_position, and all later sprints, and reassign stories to the sprint.
        if replaced_story && !replaced_story.sprint_id.nil?
          original_sprint = replaced_story.sprint_id
          project.stories.where(sprint_id: original_sprint..Float::INFINITY).update_all(sprint_id: nil)
          project.sprints.where(id: original_sprint..Float::INFINITY).map{|sprint| sprint.set_stories}
        end
      end
    end
end

class Story < ApplicationRecord
  belongs_to :epic
  belongs_to :user, optional: true
  belongs_to :status
  has_many :tasks
  delegate :project, to: :epic

  def for_backlog
    {id: id, epic_name: epic.name, epic_priority: epic.priority, user:  user.nil? ? nil : user.for_backlog, showDetails: false,
      title: title, priority: Priority.find_label(priority), estimate: estimate, description: description, acceptance_criteria: acceptance_criteria, tasks: tasks}
  end

  def for_dashboard
    {
      id: id, epic_name: epic.name, epic_priority: epic.priority, user:  user.nil? ? nil : user.for_backlog,
      title: title, priority: Priority.find_priority(priority), estimate: estimate.nil? ? 0 : estimate,
      description: description, acceptance_criteria: acceptance_criteria, tasks: tasks, progress: task_progress
    }
  end

  def for_edit
    {id: id, title: title, 
      description: description ? description : '', 
      estimate: estimate ? estimate : 0, 
      priority: priority ? priority : '', 
      acceptance_criteria: acceptance_criteria ? acceptance_criteria : ''}
  end

  def task_progress
    progress = []
    project.status.order(:order).each do |status|
      progress.push({status_name: status.name, count: status.tasks.where(story_id: id).count})
    end
    progress
  end
end

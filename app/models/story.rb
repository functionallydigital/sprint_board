class Story < ApplicationRecord
  belongs_to :epic
  belongs_to :user, optional: true
  belongs_to :status
  belongs_to :sprint, optional: true
  has_many :tasks
  delegate :project, to: :epic

  def for_backlog
    {id: id, epic_name: epic.name, epic_priority: epic.priority, user:  user.nil? ? nil : user.for_backlog, showDetails: false,
      title: title, priority: Priority.find_label(priority), estimate: estimate, description: description, acceptance_criteria: acceptance_criteria, tasks: tasks}
  end

  def for_dashboard
    {
      id: id, epic_name: epic.name, epic_priority: Priority.find_label(epic.priority), user:  user.nil? ? nil : user.for_backlog,
      title: title, priority: Priority.find_priority(priority), estimate: estimate.nil? ? 0 : estimate,
      description: description, acceptance_criteria: acceptance_criteria, tasks: tasks.map{ |task| task.for_overview}, progress: task_progress_overview
    }
  end

  def for_edit
    {id: id, title: title, 
      description: description ? description : '', 
      estimate: estimate ? estimate : 0, 
      priority: priority ? priority : '', 
      acceptance_criteria: acceptance_criteria ? acceptance_criteria : ''}
  end

  def for_sprint_board
    {
      id: id, user:  user.nil? ? nil : user.for_backlog, status_id: status_id, draggable: tasks.empty?, project_id: project.id,
      title: title, priority: Priority.find_priority(priority), estimate: estimate.nil? ? 0 : estimate,
      description: description, acceptance_criteria: acceptance_criteria, status: progress
    }
  end

  def progress
    steps = []
    project.status.order(:order).each do |step|
      steps.push({id: step.id, details: step, tasks: tasks.where(status_id: step.id).map{ |task| task.for_sprint_board } })
    end
    steps
  end

  def task_progress_overview
    progress = []
    project.status.order(:order).each do |status|
      progress.push({status_name: status.name, count: status.tasks.where(story_id: id).count})
    end
    progress
  end
end

class Sprint < ApplicationRecord
  belongs_to :project
  has_many :stories

  def is_active?
    today = Date.today
    start_date && end_date && start_date <= today && today <= end_date
  end

  def completion
    if !points.nil?
      final_project_step = project.final_sprint_step
      completed_points = stories.where(status_id: final_project_step.id).pluck(:estimate).sum
      display_string = "#{(completed_points / points.to_f * 100).round(2)}%"
    else
      display_string = 'N/A'
    end
    display_string
  end

  def epics
    Epic.where(id: stories.pluck(:epic_id))
  end

  def for_dashboard
    { id: id, start_date: start_date, end_date: end_date, points: points, active: is_active?, completion: completion,
      steps: project.status.order(:order), epics: epics.map{ |epic| epic.for_label }, stories: stories.map{ |story| story.for_sprint_board } }
  end

  def for_backlog
    { id: id, start_date: start_date, end_date: end_date, points: points,
     stories: stories.where.not(status_id: project.final_sprint_step.id).order(:position).map{|story| story.for_backlog}}
  end
end

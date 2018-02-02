class Sprint < ApplicationRecord
  belongs_to :project
  has_many :stories

  validates :points, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true

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

  def actual_points
    points = 0
    stories.pluck(:estimate).each do |estimate|
      points = points + estimate
    end
    points
  end

  def set_stories
    current_points = 0
    index = 0
    unassigned_stories = project.stories.where(sprint_id: nil).order(:position)
    while  index < unassigned_stories.count && ((current_points + unassigned_stories[index].estimate) <= points)
      unassigned_stories[index].update(sprint_id: id)
      current_points = current_points + unassigned_stories[index].estimate
      index = index + 1
    end
  end

  def epics
    Epic.where(id: stories.pluck(:epic_id))
  end

  def for_dashboard
    { id: id, start_date: start_date, end_date: end_date, points: points, active: is_active?, completion: completion,
      steps: project.status.order(:order), epics: epics.map{ |epic| epic.for_label }, stories: stories.map{ |story| story.for_sprint_board } }
  end

  def for_backlog
    { id: id, start_date: start_date, end_date: end_date, points: points, actual_points: actual_points,
     stories: stories.where.not(status_id: project.final_sprint_step.id).order(:position).map{|story| story.for_backlog} }
  end
end

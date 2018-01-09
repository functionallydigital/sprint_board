class Sprint < ApplicationRecord
  belongs_to :project
  has_many :stories

  def is_active?
    today = Date.today
    start_date && end_date && start_date <= today && today <= end_date
  end

  def completion
    if !points.nil?
      display_string = "#{points / points * 100}%"
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
      epics: epics.map{ |epic| epic.for_label }, stories: stories.map{ |story| story.for_sprint_board } }
  end
end

class Epic < ApplicationRecord
  belongs_to :project
  has_many :stories

  validates :name, presence: true
  validates :project_id, presence: true
  validates :priority, presence: true
  validates :position, presence: true

  def for_overview
    { id: id, name: name, priority: Priority.find_label(priority), story_count: stories.count}
  end

  def for_dashboard
    { id: id, name: name, priority: Priority.find_priority(priority), stories: stories.map{|story| story.for_backlog}, progress: story_progress}
  end

  def for_roadmap
    { id: id, name: name}
  end

  def story_progress
    progress = []
    project.status.order(:order).each do |status|
      progress.push({status_name: status.name, count: status.stories.where(epic_id: id).count})
    end
    progress
  end

  def estimate
    sum = 0
    stories.pluck(:estimate).compact.each { |a| sum+=a }
    sum
  end
end

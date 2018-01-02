class Project < ApplicationRecord
  has_many :epics, dependent: :destroy
  has_many :stories, through: :epics
  has_many :status, dependent: :destroy
  has_many :sprints, dependent: :destroy
  has_many :projects_users
  has_many :users, through: :projects_users

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true

  def has_active_sprint?
    @current_sprint.nil?
  end

  def start_new_sprint(start_date=nil)
    if (start_date)
      Sprint.create(start_date: start_date, end_date: calculate_end_date(start_date), project_id: id)
    else
      Sprint.create(start_date: Date.today, end_date: calculate_end_date(Date.today), project_id: id)
    end
  end

  def current_sprint
    @current_sprint ||= find_current_sprint
  end

  def find_current_sprint
    current = @current_sprint
    @active_sprints = []
    sprints.each do |sprint|
      if sprint.is_active?
        @active_sprints.push(sprint)
        if !current || sprint.end_date < current.end_date
          current = sprint
        end
      end
    end
    current
  end

  # Presenter prepers
  def for_index
    project_details = { id: id, name: name, description: description }
    if current_sprint
      project_details[:sprint_start] = current_sprint.start_date
      project_details[:sprint_end] = current_sprint.end_date
      project_details[:sprint_completion] = current_sprint.completion
    end
    project_details
  end

  def for_dashboard
    project_details = { id: id,
                        name: name,
                        description: description,
                        start_date: start_date,
                        end_date: end_date,
                        epics: epics.map{|epic| epic.for_overview},
                        users: projects_users.map{|user| user.for_dashboard} }
    if current_sprint
      project_details[:sprint_start] = current_sprint.start_date
      project_details[:sprint_end] = current_sprint.end_date
      project_details[:sprint_completion] = current_sprint.completion
    end
    project_details
  end

  def for_edit
    { id: id, name: name, description: description, start_date: start_date, end_date: end_date, sprint_length: sprint_length, steps: status }
  end

  def for_backlog
    story_details = []
    stories.sort_by{ |story| story.position}.each do |story|
      story_details << story.for_backlog
    end
    { id: id, name: name, stories: story_details }
  end

  def users_list
    user_list = []
    projects_users.each do |user|
      user_list << user.for_assignment
    end
    user_list
  end

  private

    def calculate_end_date(start_date)
      start_date + sprint_length.week - 1.day
    end
end

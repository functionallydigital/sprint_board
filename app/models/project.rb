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

  def final_sprint_step
    status.order(:order).last
  end

  # Presenter preppers
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
      project_details[:sprint_id] = current_sprint.id
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
    { id: id, name: name, stories:  stories.where(sprint_id: nil).where.not(status_id: final_sprint_step.id).order(:position).map{|story| story.for_backlog},
      sprints: sprints.where.not(end_date: Time.at(0)..(1.days.ago)).map{|sprint| sprint.for_backlog}, new_sprint: Sprint.new }
  end

  def for_roadmap
    { id: id, name: name, start_date: start_date, end_date: end_date, sprint_length: sprint_length,
      epics: epics.where(sprint_number: nil).map{|epic| epic.for_label}, sprints: roadmap_sprints, required_velocity: required_velocity }
  end

  def users_list
    user_list = []
    projects_users.each do |user|
      user_list << user.for_assignment
    end
    user_list
  end

  def required_velocity
    sum = 0
    stories.where(epic_id: epics.where.not(sprint_number: nil).pluck(:id)).pluck(:estimate).compact.each { |a| sum+=a }
    weeks_in_project = ((end_date - start_date).to_f / 7).ceil
    sprints_in_projects = (weeks_in_project.to_f / sprint_length).ceil
    sum == 0 ? 0 : (sum.to_f / sprints_in_projects).ceil
  end

  def roadmap_sprints
    sprints = []
    count = 1
    date = start_date
    while date < end_date
      sprint = {}
      sprint['id'] = count
      sprint['start_date'] = date
      sprint_end_date = date + sprint_length.weeks
      if sprint_end_date > end_date
        sprint_end_date = end_date
      end
      sprint['end_date'] = sprint_end_date
      sprint_epics = epics.where(sprint_number: count)
      sprint['epics'] = sprint_epics.map {|epic| epic.for_label }
      estimate = 0
      sprint_epics.each { |epic| estimate += epic.estimate }
      sprint['estimate'] = estimate
      sprints.push(sprint)
      count = count + 1
      date = sprint_end_date
    end
    sprints
  end

  private

    def calculate_end_date(start_date)
      start_date + sprint_length.week - 1.day
    end
end

class ProjectsUser < ApplicationRecord
  belongs_to :user
  belongs_to :project

  validates :project_id, presence: true
  validates :user_id, presence: true
  validates :role, presence: true

  ROLES_LIST = [{value: 1, label: 'Admin'}, {value: 2, label: 'Editor'}, {value: 3, label: 'Viewer'}]

  def role_label
    role ? ROLES_LIST.select{|option| option[:value] == role }.first[:label] : nil
  end

  def for_assignment
    {value: user.id, label: user.name}
  end

  def for_dashboard
    {id: user.id, name: user.name, role: role_label}
  end
end

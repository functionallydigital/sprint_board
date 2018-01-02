class User < ApplicationRecord
  has_many :sessions, dependent: :destroy
  has_many :projects_users
  has_many :projects, through: :projects_users
  has_many :stories
  has_many :tasks

  
  before_save { email.downcase! }
  validates :first_name, presence: true, length: {maximum: 50}
  validates :last_name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, presence: true, length: { minimum: 10 }, allow_nil: true

  def name
    [first_name, last_name].join(' ')
  end

  def is_on_project?(project_id)
    !ProjectsUser.find_by(user_id: id, project_id: project_id).nil?
  end

  def for_backlog
    {id: id, name: name}
  end

  def for_selector
    {value: id, label: name}
  end
end

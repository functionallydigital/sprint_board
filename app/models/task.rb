class Task < ApplicationRecord
  belongs_to :story
  belongs_to :user, optional: true
  belongs_to :status
  delegate :epic, to: :story
  delegate :project, to: :epic

  def for_overview
    {id: id, title: title, description: description, status: status, user: user.nil? ? nil : user.for_backlog}
  end
end

class Status < ApplicationRecord
  belongs_to :project
  has_many :stories
  has_many :tasks
end

class Sprint < ApplicationRecord
  belongs_to :project

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
end

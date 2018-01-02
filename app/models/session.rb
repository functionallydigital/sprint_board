class Session < ApplicationRecord
  belongs_to :user

  def self.generate_session_key
    SecureRandom.uuid
  end

  def is_active?
    Time.now < (last_action + 1.day)
  end

  def refresh
    self.update(last_action: Time.now)
  end
end

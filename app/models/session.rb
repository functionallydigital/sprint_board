class Session < ApplicationRecord
  belongs_to :user

  def self.generate_session_key
    SecureRandom.uuid
  end

  def is_active?
    id && created_at
  end

  def refresh
    self.update(last_action: Time.now)
  end
end

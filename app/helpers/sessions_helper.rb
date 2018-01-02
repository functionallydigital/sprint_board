module SessionsHelper
  def log_in(user)
    Session.create(user_id: user.id, session_key: Session.generate_session_key, last_action: Time.now)
  end

  def log_out(user)
    user.sessions.delete_all
  end
end

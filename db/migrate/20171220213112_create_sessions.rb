class CreateSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :sessions do |t|
      t.integer :user_id
      t.string :session_key
      t.datetime :last_action

      t.timestamps
    end
  end
end

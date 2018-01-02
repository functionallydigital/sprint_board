class CreateTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :tasks do |t|
      t.integer :story_id
      t.string :title
      t.string :description
      t.integer :status_id
      t.integer :user_id

      t.timestamps
    end
  end
end

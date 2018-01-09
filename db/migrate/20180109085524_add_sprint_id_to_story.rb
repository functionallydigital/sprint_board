class AddSprintIdToStory < ActiveRecord::Migration[5.0]
  def change
    add_column :stories, :sprint_id, :integer
  end
end

class AddSprintNumberToEpic < ActiveRecord::Migration[5.0]
  def change
    add_column :epics, :sprint_number, :integer
  end
end

class AddMissingFieldsToEpics < ActiveRecord::Migration[5.0]
  def change
    add_column :epics, :priority, :string
  end
end

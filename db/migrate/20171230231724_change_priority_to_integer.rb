class ChangePriorityToInteger < ActiveRecord::Migration[5.0]
  def change
    remove_column :epics, :priority
    add_column :epics, :priority, :integer
  end
end

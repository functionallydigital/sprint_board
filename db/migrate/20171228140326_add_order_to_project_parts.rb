class AddOrderToProjectParts < ActiveRecord::Migration[5.0]
  def change
    add_column :epics, :position, :integer
    add_column :stories, :position, :integer
  end
end

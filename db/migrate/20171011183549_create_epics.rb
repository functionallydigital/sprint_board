class CreateEpics < ActiveRecord::Migration[5.0]
  def change
    create_table :epics do |t|
      t.string :name
      t.integer :project_id

      t.timestamps
    end
  end
end

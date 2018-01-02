class CreateStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :statuses do |t|
      t.string :name
      t.integer :project_id
      t.integer :order

      t.timestamps
    end
  end
end

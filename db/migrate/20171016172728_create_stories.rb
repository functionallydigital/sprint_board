class CreateStories < ActiveRecord::Migration[5.0]
  def change
    create_table :stories do |t|
      t.integer :epic_id
      t.integer :status_id
      t.string :title
      t.string :description
      t.integer :estimate
      t.integer :priority
      t.string :acceptance_criteria

      t.timestamps
    end
  end
end

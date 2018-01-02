class CreateSprints < ActiveRecord::Migration[5.0]
  def change
    create_table :sprints do |t|
      t.date :start_date
      t.date :end_date
      t.integer :points

      t.timestamps
    end

    add_column :projects, :sprint_length, :integer
  end
end

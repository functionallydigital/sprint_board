class AddRoleToProjectsUser < ActiveRecord::Migration[5.0]
  def change
    add_column :projects_users, :role, :integer
  end
end

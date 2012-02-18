class AddOwnerIdToGithubRepository < ActiveRecord::Migration
  def change
    add_column :github_repositories, :owner_id, :integer
  end
end

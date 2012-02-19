class AddOwnerAccountNameToGithubRepository < ActiveRecord::Migration
  def change
    add_column :github_repositories, :owner_account_name, :string

  end
end

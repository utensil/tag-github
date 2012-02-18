class CreateGithubAccounts < ActiveRecord::Migration
  def change
    create_table :github_accounts do |t|
      t.string :type
      t.string :login_name
      t.string :avatar_url
      t.string :api_url
      t.string :html_url
      t.integer :following
      t.integer :public_repos
      t.integer :public_gists
      t.integer :followers
      t.datetime :registed_at

      t.timestamps
    end
  end
end

class CreateGithubRepositories < ActiveRecord::Migration
  def change
    create_table :github_repositories do |t|
      t.string :name
      t.text :description
      t.string :language
      t.boolean :fork
      t.boolean :private
      t.string :homepage_url
      t.string :api_url
      t.string :html_url
      t.string :clone_url
      t.string :ssh_url
      t.integer :watchers
      t.integer :forks
      t.text :readme

      t.timestamps
    end
  end
end

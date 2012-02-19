class CreateWatchings < ActiveRecord::Migration
  def change
    create_table :watchings do |t|
      t.belongs_to :github_account
      t.belongs_to :github_repository

      t.timestamps
    end
  end
end

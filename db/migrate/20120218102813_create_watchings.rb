class CreateWatchings < ActiveRecord::Migration
  def change
    create_table :watchings do |t|
      t.integer :github_account_id
      t.integer :github_repository_id

      t.timestamps
    end
  end
end

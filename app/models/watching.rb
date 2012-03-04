class Watching < ActiveRecord::Base
  belongs_to :github_account
  belongs_to :github_repository


end

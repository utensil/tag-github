class GithubRepository < ActiveRecord::Base
  #TODO premature
  #belongs_to :owner, :class_name => 'GithubAccount'

  has_many :watchings
  has_many :watched_accounts, :class_name => 'GithubAccount', :through => :watchings, :source => :github_account

  acts_as_taggable
end

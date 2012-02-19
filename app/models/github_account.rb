class GithubAccount < ActiveRecord::Base
  has_many :watchings, :dependent => :delete_all

  has_many :watched_repositories, :class_name => 'GithubRepository', :through => :watchings, :source => :github_repository

  validates_presence_of :login_name

  before_create :async_pull_info

  def to_s
    "<GithubAccount: #{login_name}>"
  end

  def async_pull_info
    WatchedReposUpdateWorker.perform_async self.login_name
  end
end

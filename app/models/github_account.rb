class GithubAccount < ActiveRecord::Base
  has_many :watchings

  has_many :watched_repositories, :class_name => 'GithubRepository', :through => :watchings, :source => :github_repository
end

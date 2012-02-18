class GithubAccount < ActiveRecord::Base
  has_many :watchings

  has_many :watched_repositories, :class_name => 'GithubRepository', :through => :watchings, :source => :github_repository

  validates_presence_of :login_name

  before_create :create_from_login_name

  def to_s
    login_name
  end

  #private

  def create_from_login_name

      uri = "https://api.github.com/users/#{self.login_name}"

      gu = JSON.parse(uri_get(uri))

      raise "login_name should be #{self.login_name}, got #{gu['login_name']}" if self.login_name != gu['login']

      self.type = gu['type'] == 'User' ? 'GithubUser' : 'GithubOrg'
      #avatar_url
      self.api_url = gu['url']
      #html_url
      #following
      #public_repos
      #public_gists
      #followers
      self.registed_at = gu['created_at']

      for field in %w[avatar_url html_url following public_repos public_repos public_gists followers] do
        self.send "#{field}=", gu[field]
      end

      1.upto 10 do |i|
        watched_uri = "https://api.github.com/users/#{self.login_name}/watched?per_page=100&page=#{i}"
        watched = JSON.parse(uri_get(watched_uri))
        logger.debug watched.to_json
        break if watched.empty?
        watched.each do |rep|
          self.watched_repositories.build(
            :name => rep['name'],
            :description => rep['description'],
            :language => rep['language'],
            :fork => rep['fork'],
            :private => rep['private'],
            :homepage_url => rep['homepage_url'],
            :api_url => rep['api_url'],
            :html_url => rep['html_url'],
            :clone_url => rep['clone_url'],
            :ssh_url => rep['ssh_url'],
            :watchers => rep['watchers'],
            :forks => rep['forks'],
            :readme => rep['readme']
          )
        end
      end
  end

  def uri_get(uri)
    response = nil
    uri = URI(uri)

    Net::HTTP.start(uri.host, uri.port,
      :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri.request_uri

      response = http.request request # Net::HTTPResponse object
    end

    response.body
  end
end

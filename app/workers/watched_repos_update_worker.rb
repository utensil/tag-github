require 'sidekiq/util'

class WatchedReposUpdateWorker
  include Sidekiq::Worker

  def perform(account_name)

      #first update user infos
      acc = GithubAccount.find_or_create_by_login_name(account_name)

      user_api_uri = "https://api.github.com/users/#{account_name}"
      gu = JSON.parse(MiscUtil.uri_get(user_api_uri))

      raise "login_name should be #{self.login_name}, got #{gu['login_name']}" if acc.login_name != gu['login']

      acc.type = gu['type'] == 'User' ? 'GithubUser' : 'GithubOrg'
      acc.api_url = gu['url']
      acc.registed_at = gu['created_at']

      for field in %w[avatar_url html_url following public_repos public_repos public_gists followers] do
        acc.send "#{field}=", gu[field]
      end
      acc.save

      #and then update repos that he/she watches
      i = 0
      loop do
        i += 1

        watched_api_uri = "https://api.github.com/users/#{account_name}/watched?per_page=100&page=#{i}"
        watched_reps = JSON.parse(MiscUtil.uri_get(watched_api_uri))

        #conditon to stop the loop
        break if watched_reps.empty?

        watched_reps.each do |rep|
            owner = rep['owner'] || { 'login' => ''}
            owner_account_name = owner['login']
            attr_hash = {
              :name => rep['name'],
              :description => rep['description'],
              :language => rep['language'],
              :fork => rep['fork'],
              :private => rep['private'],
              :homepage_url => rep['homepage'],
              :api_url => rep['url'],
              :html_url => rep['html_url'],
              :clone_url => rep['clone_url'],
              :ssh_url => rep['ssh_url'],
              :watchers => rep['watchers'],
              :forks => rep['forks'],
              :readme => rep['readme'],
              :owner_account_name => owner_account_name
            }
          #already watched?
          if acc.watched_repositories.exists?(:name => rep['name'])
            wr = acc.watched_repositories.find(:first, :conditions => {:name => rep['name']})
            wr.attributes = attr_hash
            wr.save
          #already watched by others?
          elsif GithubRepository.exists?(:name => rep['name'])
            acc.watched_repositories << GithubRepository.where(:name => rep['name']).first
          #brand new?
          else
            acc.watched_repositories.build(attr_hash)
          end
        end

        #save on every page so there won't be a peak
        acc.save
        #TODO should I sleep and let Github rest a while?
        sleep 0.1

        acc.watched_repositories.each do |repos|
          update_readme(repos.name)
          sleep 0.1
        end
      end
  end

  private


  def update_readme(repos_name)
    repos = GithubRepository.where(:name => repos_name).first

    return if repos.nil? || repos.html_url.blank? || !repos.readme.blank?

    h = Hpricot.parse(MiscUtil.uri_get(repos.html_url))
    repos.readme = h.search('#readme').to_s

    repos.save
  end
end

require 'sidekiq/util'

class WatchedReposUpdateWorker
  include Sidekiq::Worker

  def perform(account_name)

      acc = GithubAccount.find_or_create_by_login_name(account_name)

      if acc.new_record? || acc.type.nil?
        user_api_uri = "https://api.github.com/users/#{account_name}"

        gu = JSON.parse(uri_get(user_api_uri))

        raise "login_name should be #{self.login_name}, got #{gu['login_name']}" if acc.login_name != gu['login']

        acc.type = gu['type'] == 'User' ? 'GithubUser' : 'GithubOrg'
        acc.api_url = gu['url']
        acc.registed_at = gu['created_at']

        for field in %w[avatar_url html_url following public_repos public_repos public_gists followers] do
          acc.send "#{field}=", gu[field]
        end

        acc.save
      else
        #TODO update?
      end

      #TODO get 10 by calling user API

      i = 0
      loop do
        i += 1

        watched_api_uri = "https://api.github.com/users/#{account_name}/watched?per_page=100&page=#{i}"
        watched_reps = JSON.parse(uri_get(watched_api_uri))

        break if watched_reps.empty?
        watched_reps.each do |rep|
          unless acc.watched_repositories.exists?(:name => rep['name'])

            owner = rep['owner'] || { 'login' => ''}
            owner_account_name = owner['login']

            acc.watched_repositories.build(
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
            )
          end
        end

        acc.save
        #sleep?
      end


  end

  def uri_get(uri)
    response = nil
    uri = URI(uri)

    logger.info "Calling [#{uri.to_s}]"

    Net::HTTP.start(uri.host, uri.port,
      :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri.request_uri

      response = http.request request # Net::HTTPResponse object
    end

    logger.info "Got [#{response.body[0, 512]}]..."

    response.body
  end
end

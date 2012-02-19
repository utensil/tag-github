require 'sidekiq/util'

class ReposReadmeUpdateWorker
  include Sidekiq::Worker

  def perform(account_name = '')

  end
end

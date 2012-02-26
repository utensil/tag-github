class MiscUtil

  def self.uri_get(uri, logger = nil)
    response = nil
    uri = URI(uri)

    logger.info "Calling [#{uri.to_s}]" if logger

    Net::HTTP.start(uri.host, uri.port,
      :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri.request_uri

      response = http.request request # Net::HTTPResponse object
    end

    logger.info "Got [#{response.body[0, 512]}]..." if logger

    response.body
  end
end

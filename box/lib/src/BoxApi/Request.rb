module BoxApi
  require 'net/http'
  class Request
    def initialize(args={})
      @url          = args[:url].to_s
      @id           = args[:id].to_s
      @access_token = args[:access_token].to_s
    end

    def send
      uri = URI.parse(@url + @id)
      req = Net::HTTP::Get.new(uri.request_uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      req.add_field('Authorization', "Bearer #{@access_token}")
      return http.request(req)
    end
  end
end
module BoxApi
  class Response
    attr_reader :body, :json
    def initialize(args={})
      @response = args[:response]
      @body     = @response.body
      parse_json
    end

    private 
    def parse_json
      json = JSON.parse_nil(@body)
      if json.nil?
        raise Exception.new("invalid response body!")
      else
        @json = json
      end
    end
  end
end

module JSON
  def self.parse_nil(json)
    JSON.parse(json) if json && json.length >= 2
  end
end

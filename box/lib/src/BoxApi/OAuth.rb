module BoxApi
  class OAuth
    def initialize(args={})
      @record_id      = args[:id].to_s
      @client_id      = args[:client_id].to_s
      @client_secret  = args[:client_secret].to_s
      @state          = args[:state].to_s
      @oauth_code     = args[:oauth_code].to_s
      @base_url       = args[:base_url]       || def_base_url
      @response_type  = args[:response_type]  || def_response_type
      @redirect_uri   = args[:redirect_uri]   || def_redirect_uri
      @base_token_url = args[:base_token_url] || def_base_token_url
      @grant_type     = args[:grant_type]     || def_grant_type
    end

    def oauth_url
      @oauth_url = @base_url  + RESPONSETYPE + EQ + @response_type + AMP + REDIRECTURI + EQ + @redirect_uri + AMP
      @oauth_url = @oauth_url + CLIENTID     + EQ + @client_id     + AMP + STATE       + EQ + @state
    end

    def request_access_token
      data = Net::HTTP.post_form(URI.parse(@base_token_url), access_token_params)
      ActiveSupport::JSON.decode(data.body)
    end

    private

    def access_token_params
      params = {
        GRANTTYPE     => @grant_type,
        CODE          => @oauth_code,
        CLIENTID      => @client_id,
        CLIENTSECRET  => @client_secret,
      }
    end

    def def_base_url
      "https://app.box.com/api/oauth2/authorize?"
    end

    def def_response_type
      "code"
    end

    def def_redirect_uri
      "http://localhost:3000/box_users/oauth/validate/#{@record_id}"
    end

    def def_base_token_url
      "https://app.box.com/api/oauth2/token"
    end

    def def_grant_type
      "authorization_code"
    end
  end
end

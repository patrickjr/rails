
RESPONSETYPE  = "response_type"
REDIRECTURI   = "redirect_uri"
CLIENTID      = "client_id"
CLIENTSECRET  = "client_secret"
GRANTTYPE     = "grant_type"
CODE          = "code"
STATE         = "state"
EQ            = "="
AMP           = "&"

class BoxUser < ActiveRecord::Base
  validates :client_id, :client_secret, :presence => true

  def self.get_from(session) 
    validate_box_user BoxUser.where(:id => session[:box_id], :client_index => session[:client_index]).first
  end

  def request_folder(id)

    uri = base_folder_url + id.to_s
    box_auth = "Bearer" + self.access_token
    puts self.access_token
    request = Typhoeus::Request.new(
      uri,
      headers: { 
        "WWW-Authenticate" => box_auth.to_s }
    )
    request.on_complete do |response|
      if response.success?
        puts "-------->"
        puts 'yes'
      elsif response.timed_out?
        puts "-------->"
        puts "got a time out"
      elsif response.code == 0
        puts "response code -------->"
        puts response.return_message
      else
        puts "else -------->"
        puts response.code.to_s
      end
      puts response.headers
    end
    request.run
    puts '-----> fail'
  end
# https://api.box.com/2.0/folders/FOLDER_ID \

  def oauth_url
    @oauth_url = base_url+RESPONSETYPE+EQ+response_type+AMP+REDIRECTURI+EQ+redirect_uri+AMP
    @oauth_url = @oauth_url+CLIENTID+EQ+self.client_id+AMP+STATE+EQ+state
  end

  def set_authorization_code(oauth_code)
    self.update(oauth_code: oauth_code)
  end

  def request_access_token(oauth_code)
    data = Net::HTTP.post_form(URI.parse(base_token_url), access_token_params(oauth_code))
    save_access_token ActiveSupport::JSON.decode(data.body)
  end

  def access_token_params(oauth_code)
    params = {
      GRANTTYPE     => grant_type,
      CODE          => oauth_code,
      CLIENTID      => self.client_id,
      CLIENTSECRET  => self.client_secret,
    }
  end

  private

  def self.validate_box_user(user)
    if user.nil?
      return nil
    elsif user.access_token == ""
      return nil
    else
      return user
    end
  end

  def save_access_token(data)
    if data["error"].nil?
      self.update(access_token: data["access_token"])
    end
  end

  def base_url
    @base_url = "https://app.box.com/api/oauth2/authorize?"
  end

  def response_type
    @response_type = "code"
  end

  def redirect_uri
    @redirect_uri = "http://127.0.0.1:3000/box_users/oauth/validate/" + self.id.to_s
  end

  def state
    @state = self.client_index
  end

  def base_token_url
    @base_token_url = "https://app.box.com/api/oauth2/token"
  end

  def grant_type
    @grant_type = "authorization_code"
  end

  def base_folder_url
    @base_folder_url = "https://api.box.com/2.0/folders/"
  end


end
# GET https://app.box.com/api/oauth2/authorize?response_type=code&client_id=MY_CLIENT_ID&state=security_token%3DKnhMJatFipTAnM0nHlZA




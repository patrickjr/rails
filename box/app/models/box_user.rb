
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
    @file_names ||= []
    response = send_folder_request(base_folder_url, id)
    handle_response(response.body)
  end
  def request_file_info(id)
    @file ||= {}
    response = send_folder_request(base_file_url, id)
    get_file_attributes(response.body)
  end

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

  def file
    @file
  end
  def file_names
    @file_names
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


  def send_folder_request(base_url, id)
    uri = URI.parse(base_url + id.to_s)
    request = Net::HTTP::Get.new(uri.request_uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request.add_field('Authorization', "Bearer #{self.access_token}")
    response = http.request(request)
  end

  def get_file_attributes(data)
    json = JSON.parse_nil(data)
    unless json.nil?
      @file = json
    end
  end

  def handle_response(body)
    json = JSON.parse_nil(body)
    unless json.nil?
      # puts JSON.pretty_generate(json)
      item_collection = json["item_collection"]
      if item_collection["total_count"] > 0
        entries = item_collection["entries"]
        entries.each do |entry|
          if entry["type"] == "folder"
            request_folder(entry["id"])
          else
            @file_names << {name: entry["name"], id: entry["id"] }
          end
        end
      end
    end
  end

  def base_url
    @base_url = "https://app.box.com/api/oauth2/authorize?"
  end

  def response_type
    @response_type = "code"
  end

  def redirect_uri
    @redirect_uri = "http://localhost:3000/box_users/oauth/validate/" + self.id.to_s
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

  def base_file_url
    @base_file_url = "https://api.box.com/2.0/files/"
  end


end
# GET https://app.box.com/api/oauth2/authorize?response_type=code&client_id=MY_CLIENT_ID&state=security_token%3DKnhMJatFipTAnM0nHlZA



module JSON
  def self.parse_nil(json)
    JSON.parse(json) if json && json.length >= 2
  end
end
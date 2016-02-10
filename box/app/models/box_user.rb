require 'src/BoxApi/Request'
require 'src/BoxApi/Response'
require 'src/BoxApi/File'
require 'src/BoxApi/BoxApi'
require 'src/BoxApi/OAuth'

class BoxUser < ActiveRecord::Base
  validates :client_id, :client_secret, :presence => true
  attr_accessor :file, :file_names
  def self.get_from(session) 
    validate_box_user BoxUser.where(:id => session[:box_id], :client_index => session[:client_index]).first
  end

  def request_folder_recursively(id)
    @file_names ||= []
    request  = BoxApi::Request.new({url: base_folder_url, id: id, access_token: self.access_token})
    response = BoxApi::Response.new({response: request.send})
    handle_response(response.body) # a class insde the BoxApi module should encapsulate this behaivor
  end

  def request_file_info(id)
    request   = BoxApi::Request.new({url: base_file_url, id: id, access_token: self.access_token})
    response  = BoxApi::Response.new({response: request.send})
    @file     = BoxApi::File.new({json: response.json})
  end

  def oauth_url
    authenticate = BoxApi::OAuth.new({id: self.id, client_id: self.client_id, state: self.client_index})
    authenticate.oauth_url
  end

  def request_access_token(oauth_code)
    authenticate = BoxApi::OAuth.new({
      id: self.id,
      state: self.client_index,
      client_id: self.client_id,
      client_secret: self.client_secret,
      oauth_code: oauth_code,
    })
    token = authenticate.request_access_token
    save_access_token token
  end
  
  def set_authorization_code(oauth_code)
    self.update(oauth_code: oauth_code)
  end

 ### private methods ###
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

  # should be refactored, the recursion makes it tricky though....
  def handle_response(body)
    json = JSON.parse_nil(body)
    unless json.nil?
      item_collection = json["item_collection"]
      if item_collection["total_count"] > 0
        entries = item_collection["entries"]
        entries.each do |entry|
          if entry["type"] == "folder"
            request_folder_recursively(entry["id"])
          else
            @file_names << {name: entry["name"], id: entry["id"] }
          end
        end
      end
    end
  end

  # should be moved to another class/module
  def base_folder_url
    @base_folder_url = "https://api.box.com/2.0/folders/"
  end

  # should be moved to another class/module
  def base_file_url
    @base_file_url = "https://api.box.com/2.0/files/"
  end

end

module JSON
  def self.parse_nil(json)
    JSON.parse(json) if json && json.length >= 2
  end
end
class BoxUser < ActiveRecord::Base
  validates :client_id, :client_secret, :presence => true
end

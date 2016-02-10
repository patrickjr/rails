class AddAccessTokenToBoxUser < ActiveRecord::Migration
  def change
    add_column :box_users, :access_token, :string
  end
end

class AddClientIndexKeyToBoxUsers < ActiveRecord::Migration
  def change
    add_column :box_users, :client_index, :string
  end
end

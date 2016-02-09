class CreateBoxUsers < ActiveRecord::Migration
  def change
    create_table :box_users do |t|
      t.string :client_id
      t.string :client_secret

      t.timestamps null: false
    end
  end
end

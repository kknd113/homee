class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :fb_id
      t.string :room_type
      t.integer :budget
      t.string :shipping_type
      t.string :style_type
      t.string :picture_url
      t.string :special_request

      t.timestamps null: false
    end
  end
end

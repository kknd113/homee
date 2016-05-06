class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.references :user, index: true, foreign_key: true
      
      t.string :text
      t.boolean :archived
      
      t.timestamps null: false
    end
  end
end

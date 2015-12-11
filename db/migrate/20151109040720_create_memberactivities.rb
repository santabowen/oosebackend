class CreateMemberactivities < ActiveRecord::Migration
  def change
    create_table :memberactivities do |t|
      t.integer :user_id
      t.integer :activity_id

      t.timestamps null: false
    end
    add_index :memberactivities, :user_id
    add_index :memberactivities, :activity_id
    add_index :memberactivities, [:user_id, :activity_id], unique: true
  end
end

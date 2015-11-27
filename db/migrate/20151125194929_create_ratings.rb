class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :activity_id
      t.integer :user_id
      t.integer :member_id
      t.integer :rating

      t.timestamps null: false
    end
  end
end

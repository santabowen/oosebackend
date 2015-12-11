class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :activityType
      t.string :location
      t.integer :groupSize
      t.integer :memberNum

      t.timestamps null: false
    end
  end
end

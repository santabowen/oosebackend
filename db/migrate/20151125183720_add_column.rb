class AddColumn < ActiveRecord::Migration
  def change
  	add_column :activities, :startTime, :timestamp
  end
end

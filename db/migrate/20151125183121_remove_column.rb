class RemoveColumn < ActiveRecord::Migration
  def change
  	remove_column :activities, :startTime
  end
end

class ChangeColumnName < ActiveRecord::Migration
  def change
  	rename_column :activities, :startTime, :start_time
  	rename_column :activities, :activityType, :activity_type
  	rename_column :activities, :memberNum, :member_number
  	rename_column :activities, :groupSize, :group_size
  end
end

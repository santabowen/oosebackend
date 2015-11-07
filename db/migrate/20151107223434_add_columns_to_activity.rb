class AddColumnsToActivity < ActiveRecord::Migration
  def change
  	add_column :activities, :comments,  :string
  	add_column :activities, :duration,  :integer
  	add_column :activities, :startTime, :time
  	add_column :activities, :hostid,    :string
  end
end

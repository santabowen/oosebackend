class AddLatlngToActivity < ActiveRecord::Migration
  def change
  	add_column :activities, :longitude,  :decimal, :precision => 64, :scale => 12
  	add_column :activities, :latitude,   :decimal, :precision => 64, :scale => 12
  end
end

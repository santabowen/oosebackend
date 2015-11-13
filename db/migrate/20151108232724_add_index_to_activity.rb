class AddIndexToActivity < ActiveRecord::Migration
  def change
  	add_index :activities, [:user_id, :created_at]
  end
end
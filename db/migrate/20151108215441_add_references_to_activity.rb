class AddReferencesToActivity < ActiveRecord::Migration
  def change
  	add_reference :activities, :user, index: true
  end
end

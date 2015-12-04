class AddRateToUser < ActiveRecord::Migration
  def change
    add_column :users, :num_rating,   :integer
    add_column :users, :total_rating, :float
    add_column :users, :rating,       :float
  end
end

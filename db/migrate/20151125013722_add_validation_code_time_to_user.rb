class AddValidationCodeTimeToUser < ActiveRecord::Migration
  def change
    add_column :users, :validation_code, :string
    add_column :users, :validation_time, :datetime
  end
end

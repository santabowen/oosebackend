class CreateFilters < ActiveRecord::Migration
  def change
    create_table :filters do |t|
      t.string :filtertype
      t.references :user, index: true

      t.timestamps null: false
    end
  end
end

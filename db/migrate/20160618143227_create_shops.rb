class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops do |t|
      t.string :name
      t.string :address
      t.string :url
      t.string :category
      t.timestamps null: false
    end
  end
end

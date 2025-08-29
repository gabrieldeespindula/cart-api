class CreateCartItems < ActiveRecord::Migration[7.1]
  def change
    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 0
      t.decimal :unit_price, precision: 17, scale: 2, null: false, default: 0.0
      t.decimal :total_price, precision: 17, scale: 2, null: false, default: 0.0

      t.timestamps
    end
  end
end

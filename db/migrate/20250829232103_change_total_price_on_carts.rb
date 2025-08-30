class ChangeTotalPriceOnCarts < ActiveRecord::Migration[7.1]
  def change
    change_column_null :carts, :total_price, false, 0.0
    change_column_default :carts, :total_price, 0.0
  end
end

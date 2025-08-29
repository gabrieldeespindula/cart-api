class AddAbandonedFieldsToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :abandoned, :boolean, null: false, default: false
    add_column :carts, :last_interaction_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }

    add_index :carts, [:abandoned, :last_interaction_at]
  end
end

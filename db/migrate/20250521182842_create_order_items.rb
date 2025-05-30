class CreateOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, default: 1, null: false
      t.decimal :price_at_purchase, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end

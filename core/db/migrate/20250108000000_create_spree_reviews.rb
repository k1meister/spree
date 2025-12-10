class CreateSpreeReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :spree_reviews do |t|
      t.references :product, null: false, index: true
      t.references :user, null: false, index: true
      t.integer :rating, null: false
      t.string :title, null: false
      t.text :review, null: false
      t.boolean :approved, default: false, null: false

      t.timestamps
      t.datetime :deleted_at

      t.index [:product_id, :user_id, :deleted_at], unique: true, name: 'index_spree_reviews_on_product_user_deleted'
      t.index [:product_id, :approved]
      t.index :deleted_at
    end
  end
end


class AddFieldsToSpreeReviews < ActiveRecord::Migration[8.0]
  def change
    add_column :spree_reviews, :size_fit, :string
    add_column :spree_reviews, :usage_type, :string
    add_column :spree_reviews, :experience_level, :string
    
    add_index :spree_reviews, :size_fit
    add_index :spree_reviews, :usage_type
  end
end


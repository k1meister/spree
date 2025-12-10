module Spree
  module Admin
    class ReviewsController < ResourceController
      before_action :load_product, only: [:index]

      def approve
        @review.approve!
        flash[:success] = Spree.t('admin.reviews.approved')
        redirect_to collection_url
      end

      def unapprove
        @review.unapprove!
        flash[:success] = Spree.t('admin.reviews.unapproved')
        redirect_to collection_url
      end

      private

      def load_product
        @product = Spree::Product.friendly.find(params[:product_id]) if params[:product_id].present?
      end

      def collection_includes
        [:user, :product]
      end

      def collection_default_sort
        'created_at desc'
      end

      def scope
        if @product
          @product.reviews.includes(:user, :product)
        else
          Spree::Review.includes(:user, :product)
        end
      end

      def permitted_resource_params
        params.require(:review).permit(:rating, :title, :review, :approved, :product_id, :user_id)
      end

      def collection_url(options = {})
        if @product
          spree.admin_product_reviews_url(@product, options)
        else
          spree.admin_reviews_url(options)
        end
      end

      def new_object_url(options = {})
        # Reviews are created from storefront, not admin
        nil
      end
    end
  end
end


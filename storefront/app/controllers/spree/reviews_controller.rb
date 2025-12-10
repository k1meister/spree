module Spree
  class ReviewsController < StoreController
    before_action :load_product
    before_action :require_user, only: [:create]

    def create
      @review = @product.reviews.build(review_params)
      @review.user = spree_current_user
      @review.approved = false # Reviews need admin approval

      if @review.save
        flash[:success] = Spree.t('storefront.reviews.successfully_submitted')
        redirect_to spree.product_path(@product)
      else
        flash[:error] = @review.errors.full_messages.join(', ')
        redirect_to spree.product_path(@product)
      end
    end

    private

    def load_product
      @product = current_store.products.friendly.find(params[:product_id])
    end

    def review_params
      # Handle both nested and flat parameter formats
      if params[:review].present?
        if params[:review].is_a?(ActionController::Parameters) || params[:review].is_a?(Hash)
          params.require(:review).permit(:rating, :title, :review, :size_fit, :usage_type, :experience_level, images: [])
        else
          # If review is a string, try to get individual params
          {
            rating: params[:rating]&.to_i,
            title: params[:title],
            review: params[:review_text] || params[:review],
            size_fit: params[:size_fit],
            usage_type: params[:usage_type],
            experience_level: params[:experience_level],
            images: params[:images]
          }.compact
        end
      else
        # Fallback: try to get params directly
        {
          rating: params[:rating]&.to_i,
          title: params[:title],
          review: params[:review_text],
          size_fit: params[:size_fit],
          usage_type: params[:usage_type],
          experience_level: params[:experience_level],
          images: params[:images]
        }.compact
      end
    end
  end
end


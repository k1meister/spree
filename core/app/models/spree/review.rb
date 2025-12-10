module Spree
  class Review < Spree.base_class
    acts_as_paranoid

    belongs_to :product, class_name: 'Spree::Product', inverse_of: :reviews
    belongs_to :user, class_name: Spree.user_class(constantize: false), foreign_key: :user_id, inverse_of: :reviews

    has_many_attached :images, service: Spree.public_storage_service_name

    validates :product, presence: true
    validates :user, presence: true
    validates :rating, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
    validates :title, presence: true, length: { maximum: 255 }
    validates :review, presence: true
    validates :user_id, uniqueness: { scope: [:product_id, :deleted_at], message: :already_reviewed }, if: -> { user_id.present? && product_id.present? }
    validates :size_fit, inclusion: { in: %w[runs_small fit runs_large], allow_blank: true }
    validates :usage_type, inclusion: { in: %w[daily racing off_road touring], allow_blank: true }
    validates :experience_level, inclusion: { in: %w[beginner intermediate advanced expert], allow_blank: true }

    scope :approved, -> { where(approved: true) }
    scope :pending, -> { where(approved: false) }
    scope :recent, -> { order(created_at: :desc) }

    self.whitelisted_ransackable_attributes = %w[title rating approved created_at size_fit usage_type experience_level]
    self.whitelisted_ransackable_associations = %w[product user]

    after_create :update_product_rating

    def approve!
      update!(approved: true)
      update_product_rating
    end

    def unapprove!
      update!(approved: false)
      update_product_rating
    end

    private

    def update_product_rating
      product.update_rating_cache
    end
  end
end


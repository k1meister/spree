require_dependency 'spree/calculator'

module Spree
  class Calculator
    class PriceDiscount < Calculator
      preference :discount_percent, :decimal, default: 0

      validates :preferred_discount_percent, numericality: {
        greater_than_or_equal_to: 0,
        less_than_or_equal_to: 100
      }

      def self.description
        Spree.t(:price_discount_calculator, default: 'Price Discount Calculator')
      end

      # Calculates the sale price from regular price using discount percentage
      # @param price [Spree::Price] The price object to calculate discount for
      # @return [BigDecimal] The calculated sale price (amount)
      def compute_sale_price(price)
        return price.amount if preferred_discount_percent.zero? || price.amount.nil?

        regular_price = price.compare_at_amount || price.amount
        discount_amount = (regular_price * preferred_discount_percent / 100).round(2)
        sale_price = (regular_price - discount_amount).round(2)

        # Ensure sale price is not negative
        [sale_price, 0].max
      end

      # Calculates discount amount from regular price
      # @param price [Spree::Price] The price object
      # @return [BigDecimal] The discount amount
      def compute_discount_amount(price)
        return 0 if preferred_discount_percent.zero? || price.amount.nil?

        regular_price = price.compare_at_amount || price.amount
        (regular_price * preferred_discount_percent / 100).round(2)
      end
    end
  end
end


module Spree
  class SearchController < StoreController
    after_action :track, only: :show

    helper_method :query

    def show
      @current_page = current_theme.pages.find_by(type: 'Spree::Pages::SearchResults')
    end
    
    def storefront_products_scope
      # Override to use Searchkick if available and query is present
      if query.present? && defined?(Searchkick) && Spree::Product.respond_to?(:search)
        begin
          # Searchkick'te store_ids array olarak saklanıyor, bu yüzden 'in' kullanıyoruz
          search_results = Spree::Product.search(query,
            fields: [:name, :description, :meta_title],
            where: {
              store_ids: { in: [current_store.id] },
              status: 'active',
              available_on: { lte: Time.current }
            },
            misspellings: { below: 5 }
          )
          product_ids = search_results.map(&:id)
          
          # Eğer Searchkick sonuç vermezse, multi_search'e düş
          if product_ids.empty?
            Rails.logger.info "Searchkick returned no results for query '#{query}', falling back to multi_search."
            return super
          end
          
          # Return scope filtered by searchkick results
          current_store.products.active(current_currency).where(id: product_ids)
        rescue => e
          # Fallback to default if Searchkick fails (e.g., Elasticsearch not running)
          Rails.logger.warn "Searchkick error: #{e.message}. Falling back to multi_search."
          super
        end
      else
        # Fallback to default scope (multi_search)
        super
      end
    end

    def suggestions
      @products = []
      @taxons = []

      if query.present? && query.length >= Spree::Storefront::Config.search_min_query_length
        # Use Searchkick if available, otherwise fallback to multi_search
        if defined?(Searchkick) && Spree::Product.respond_to?(:search)
          begin
            search_results = Spree::Product.search(query,
              fields: [:name, :description, :meta_title],
              where: {
                store_ids: { in: [current_store.id] },
                status: 'active',
                available_on: { lte: Time.current }
              },
              limit: 10,
              misspellings: { below: 5 }
            )
            product_ids = search_results.map(&:id)
            
            if product_ids.empty?
              # Fallback to multi_search if no results
              products_scope = current_store.products.active(current_currency).multi_search(query)
              @products = products_scope.includes(storefront_products_includes)
            else
              @products = current_store.products.active(current_currency).where(id: product_ids).includes(storefront_products_includes)
            end
          rescue => e
            # Fallback to multi_search if Searchkick fails
            Rails.logger.warn "Searchkick error in suggestions: #{e.message}. Falling back to multi_search."
            products_scope = current_store.products.active(current_currency).multi_search(query)
            @products = products_scope.includes(storefront_products_includes)
          end
        else
          products_scope = current_store.products.active(current_currency).multi_search(query)
          @products = products_scope.includes(storefront_products_includes)
        end
        @taxons = current_store.taxons.search_by_name(query)
      end
    end

    private

    def query
      @query ||= params[:q].presence&.strip_html_tags&.strip
    end

    def track
      return if turbo_frame_request? || turbo_stream_request?
      return if query.blank?

      track_event('product_searched', { query: query })
    end

    def default_products_sort
      'manual'
    end
  end
end

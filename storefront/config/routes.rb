Spree::Core::Engine.add_routes do
  scope '(:locale)', locale: /#{Spree.available_locales.join('|')}/, defaults: { locale: nil } do
    # store password protection
    get '/password', to: 'password#show', as: :password
    post '/password', to: 'password#check', as: :check_password

    # Product Catalog - Türkçe slug: /urun
    resources :products, only: [:index, :show], path: '/urun' do
      member do
        get :related
      end
      resources :reviews, only: [:create]
    end
    get '/tx/:id', to: 'taxonomies#show', as: :taxonomy

    # Policies
    resources :policies, only: %i[show]

    # Page Sections (used for lazy loading, eg. product carousels)
    resources :page_sections, only: [:show]

    # Search
    get '/search', to: 'search#show', as: :search
    get '/search/suggestions', to: 'search#suggestions', as: :search_suggestions

    # Posts
    resources :posts, only: [:index, :show] do
      member do
        get :related_products
      end
    end
    get '/posts/tag/:tag', to: 'posts#index', as: :tagged_posts
    get '/posts/category/:category_id', to: 'posts#index', as: :category_posts

    # Cart
    resources :orders, except: [:index, :new, :create, :destroy]
    resources :line_items, only: [:create, :update, :destroy]
    get '/cart', to: 'orders#edit', as: :cart
    patch '/cart', to: 'orders#update', as: :update_cart

    # Checkout
    get '/checkout/:token/complete', to: 'checkout#complete', as: :checkout_complete
    patch '/checkout/:token/apply_coupon_code', as: :checkout_apply_coupon_code, to: 'checkout#apply_coupon_code'
    delete '/checkout/:token/remove_coupon_code', as: :checkout_remove_coupon_code, to: 'checkout#remove_coupon_code'
    patch '/checkout/:token/apply_store_credit', as: :checkout_apply_store_credit, to: 'checkout#apply_store_credit'
    delete '/checkout/:token/remove_store_credit', as: :checkout_remove_store_credit, to: 'checkout#remove_store_credit'
    get '/checkout/:token/:state', to: 'checkout#edit', as: :checkout_state
    patch '/checkout/:token/update/:state', to: 'checkout#update', as: :update_checkout
    get '/checkout/:token', to: 'checkout#edit', as: :checkout
    delete '/checkout/:token/remove_missing_items', to: 'checkout#remove_missing_items', as: :checkout_remove_missing_items

    # Account
    resources :addresses, except: [:index]
    resource :account, to: redirect('/account/orders')
    namespace :account do
      resource :profile, controller: :profile, only: [:edit, :update]
      resources :orders, only: [:index, :show]
      resources :addresses, only: [:index]
      resource :wishlist, only: [:show], controller: '/spree/wishlists' do
        resources :wished_items, only: [:create, :destroy]
      end
      resource :newsletter, only: [:edit, :update], controller: :newsletter
      resources :store_credits, only: [:index]
      resources :gift_cards, only: [:index]
    end

    # Wishlists
    resources :wishlists, only: [:show] # for sharing with ID and Token

    # Order Status
    resource :order_statuses, only: [:new, :create], path: 'order_status', as: :order_status, controller: 'order_status'

    # Settings
    resource :settings, only: [:update, :show]

    # Newsletter
    resources :newsletter_subscribers, only: [:create] do
      get :verify, on: :collection
    end

    # Contact form
    resources :contacts, only: [:new, :create]
    get '/contact', to: 'contacts#new', as: 'contact'

    # Digital Links
    resources :digital_links, only: [:show]

    # Pages - /pages/ prefix kaldırıldı, direkt slug kullanılıyor
    # Wildcard route'tan önce ama diğer route'lardan sonra
    get '/:id', to: 'pages#show', as: :page, constraints: lambda { |req|
      path = req.path
      
      # ActiveStorage path'lerini hariç tut
      return false if path.start_with?('/rails/active_storage')
      return false if path.start_with?('/rails/service_blob')
      return false if path.start_with?('/rails/disk')
      
      # Admin path'lerini kontrol et
      return false if path.start_with?('/admin')
      return false if path.include?('/admin/')
      
      # Excluded path'leri kontrol et
      excluded_paths = %w[urun posts cart checkout account search contact password settings order_status newsletter_subscribers contacts digital_links wishlists addresses policies page_sections tx robots.txt sitemap.xml.gz sitemap admin assets images javascripts stylesheets rails]
      first_segment = path.split('/').reject(&:blank?).first
      return false if excluded_paths.include?(first_segment)
      
      # Sayısal ID değilse ve path varsa
      # Page slug kontrolü - eğer bu bir page slug'ıysa true döndür
      if first_segment.present? && !first_segment.match?(/^\d+$/)
        page = Spree::Page.custom.friendly.find_by(slug: first_segment)
        return page.present?
      end
      
      false
    }

    # Taxon routes - /t/ prefix kaldırıldı, direkt slug kullanılıyor
    # Türkçe slug'lar: koleksiyon, kategori, marka vb.
    # En sona konuldu ki diğer route'lar öncelikli olsun
    get '/*id', to: 'taxons#show', as: :nested_taxons, constraints: lambda { |req|
      path = req.path
      
      # ActiveStorage path'lerini hariç tut
      return false if path.start_with?('/rails/active_storage')
      return false if path.start_with?('/rails/service_blob')
      return false if path.start_with?('/rails/disk')
      
      # Admin path'lerini kontrol et
      return false if path.start_with?('/admin')
      return false if path.include?('/admin/')
      
      # Excluded path'leri kontrol et
      excluded_paths = %w[urun posts cart checkout account search contact password settings order_status newsletter_subscribers contacts digital_links wishlists addresses pages policies page_sections tx robots.txt sitemap.xml.gz sitemap admin assets images javascripts stylesheets rails]
      first_segment = path.split('/').reject(&:blank?).first
      return false if excluded_paths.include?(first_segment)
      
      # Sadece sayısal ID değilse ve path varsa
      first_segment.present? && !first_segment.match?(/^\d+$/)
    }

    root to: 'home#index'
  end

  get '/forbidden', to: 'errors#show', code: 403, as: :forbidden
  if Rails.env.test?
    get '/errors', to: 'errors#show'
    get '/errors/:path', to: 'errors#show', as: :pathed_errors
  end

  get 'robots.txt' => 'seo#robots'
  get 'sitemap' => 'seo#sitemap'
  get 'sitemap.xml.gz' => 'seo#sitemap'
end

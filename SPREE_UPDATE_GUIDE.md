# Spree Güncelleme Rehberi

## 📋 Mevcut Durum
- **Spree Version:** 5.2.1
- **Git Remote:** k1meister/spree (fork)
- **Rails Version:** 8.0.4

## ⚠️ Override Edilen Dosyalar (Dikkat!)

Aşağıdaki dosyalar gem içinde doğrudan değiştirilmiş. Güncelleme sırasında bu dosyalar üzerinde merge conflict'ler oluşabilir:

### Admin Panel
- `admin/app/javascript/spree/admin/controllers/variants_form_controller.js`
- `admin/app/views/spree/admin/products/form/_variants.html.erb`
- `admin/app/views/spree/admin/products/form/variants/_variant_template.html.erb`
- `admin/app/controllers/spree/admin/products_controller.rb`
- `admin/app/views/spree/admin/shared/_head.html.erb`
- `admin/app/views/spree/admin/dashboard/show.html.erb`
- `admin/app/views/spree/admin/shared/sidebar/_store_dropdown.html.erb`
- `admin/config/initializers/spree_admin_navigation.rb`
- `admin/config/locales/en.yml`
- `admin/config/routes.rb`

### Core
- `core/app/models/spree/product.rb`
- `core/app/models/concerns/spree/user_methods.rb`
- `core/lib/spree/core/engine.rb`

### Storefront
- `storefront/app/views/spree/shared/_head.html.erb`
- `storefront/app/views/themes/default/spree/page_sections/_header.html.erb`
- `storefront/app/views/themes/default/spree/page_sections/_product_details.html.erb`
- `storefront/app/assets/config/spree_storefront_manifest.js`

## ✅ Korunan Dosyalar (sandbox/app/)

Bu dosyalar güncellemeden etkilenmez:
- `sandbox/app/models/` - Custom modeller
- `sandbox/app/controllers/` - Custom controller'lar
- `sandbox/app/views/` - Custom view'lar
- `sandbox/app/views/themes/one_rides/` - Custom theme
- `sandbox/app/views/spree/admin/payment_methods/descriptions/` - Payment method descriptions

## 🔄 Güncelleme Adımları

### 1. Yedekleme
```bash
# Git'te mevcut değişiklikleri commit edin
git add .
git commit -m "Backup before Spree update"

# Veritabanı yedeği alın
cd sandbox
bin/rails db:dump
```

### 2. Spree'nin Son Versiyonunu Kontrol Edin
```bash
# Resmi Spree repo'sunu remote olarak ekleyin
git remote add upstream https://github.com/spree/spree.git

# Son versiyonu kontrol edin
git fetch upstream
git tag | grep "^v" | sort -V | tail -5
```

### 3. Güncelleme
```bash
# Upstream'den son versiyonu çekin
git fetch upstream

# Merge yapın (conflict'ler olabilir)
git merge upstream/main  # veya upstream/master

# Conflict'leri çözün
# Her conflict için:
# 1. Değişikliklerinizi kontrol edin
# 2. Gerekirse decorator pattern kullanın
# 3. Ya da değişiklikleri sandbox/app/ altına taşıyın
```

### 4. Bağımlılıkları Güncelleyin
```bash
cd sandbox
bundle update spree spree_core spree_admin spree_storefront
bundle install
```

### 5. Migration'ları Çalıştırın
```bash
cd sandbox
bin/rails db:migrate
```

### 6. Test Edin
```bash
cd sandbox
bin/rails test
# veya
bin/rspec
```

## 💡 Öneriler

### Decorator Pattern Kullanın
Override ettiğiniz dosyaları decorator pattern ile değiştirin:

**Örnek:** `admin/app/controllers/spree/admin/products_controller.rb` yerine:
```ruby
# sandbox/app/controllers/spree/admin/products_controller_decorator.rb
module Spree
  module Admin
    module ProductsControllerDecorator
      def load_variants_data
        # Custom kodunuz
      end
    end
  end
end

Spree::Admin::ProductsController.prepend(Spree::Admin::ProductsControllerDecorator)
```

### View Override'ları
View dosyalarını override etmek yerine, theme kullanın:
- `sandbox/app/views/themes/one_rides/` altında custom view'lar

### Initializer Kullanın
Config değişiklikleri için initializer kullanın:
- `sandbox/config/initializers/spree.rb`

## 🚨 Dikkat Edilmesi Gerekenler

1. **Migration'lar:** Yeni migration'lar veritabanı yapısını değiştirebilir
2. **API Değişiklikleri:** Spree'nin API'si değişmiş olabilir
3. **Deprecated Özellikler:** Bazı özellikler kaldırılmış olabilir
4. **JavaScript Değişiklikleri:** Stimulus controller'lar değişmiş olabilir

## 📝 Güncelleme Sonrası Kontrol Listesi

- [ ] Admin paneli açılıyor mu?
- [ ] Ürün listesi görünüyor mu?
- [ ] Ürün düzenleme sayfası çalışıyor mu?
- [ ] Varyant fiyat güncelleme çalışıyor mu?
- [ ] Storefront açılıyor mu?
- [ ] Ürün sayfaları görünüyor mu?
- [ ] Sepet çalışıyor mu?
- [ ] Ödeme yöntemleri görünüyor mu?
- [ ] Review sistemi çalışıyor mu?
- [ ] Custom theme görünüyor mu?

## 🔗 Yararlı Linkler

- [Spree Releases](https://github.com/spree/spree/releases)
- [Spree Changelog](https://github.com/spree/spree/blob/main/CHANGELOG.md)
- [Spree Documentation](https://docs.spreecommerce.org/)

# Searchkick Entegrasyonu

## Mevcut Durum
Spree şu anda PostgreSQL'in `pg_search` gem'i ile arama yapıyor. Bu basit bir full-text search çözümü.

## Searchkick'in Avantajları
- **Daha iyi sonuçlar**: Stemming, misspellings, synonyms desteği
- **Hızlı**: Elasticsearch/OpenSearch ile çok hızlı arama
- **Akıllı öğrenme**: Kullanıcı davranışlarına göre sonuçları iyileştirir
- **Autocomplete**: Otomatik tamamlama desteği
- **"Did you mean"**: Yanlış yazımlar için öneriler

## Kurulum Adımları

### 1. Gemfile'a Ekle
```ruby
gem 'searchkick'
```

### 2. Elasticsearch veya OpenSearch Kurulumu

**macOS (Homebrew) - OpenSearch (Önerilen):**
```bash
brew install opensearch
brew services start opensearch
```

**macOS (Homebrew) - Elasticsearch (Formül yok, cask var):**
Elasticsearch artık Homebrew'da formül olarak yok. Alternatifler:

**Docker ile Elasticsearch (Önerilen):**
```bash
docker run -d -p 9200:9200 -p 9300:9300 \
  -e "discovery.type=single-node" \
  -e "xpack.security.enabled=false" \
  --name elasticsearch \
  elasticsearch:8.11.0
```

**Manuel İndirme:**
1. https://www.elastic.co/downloads/elasticsearch adresinden indirin
2. Arşivi açın ve `bin/elasticsearch` komutunu çalıştırın

**Elasticvue (GUI Tool):**
```bash
brew install --cask elasticvue
```

### 3. Product Model'ine Searchkick Ekle

`core/app/models/spree/product.rb` dosyasına ekle:

```ruby
class Spree::Product < Spree.base_class
  searchkick word_start: [:name, :description], 
             suggest: [:name],
             settings: { number_of_shards: 1 }

  def search_data
    {
      name: name,
      description: description,
      meta_title: meta_title,
      meta_description: meta_description,
      slug: slug,
      available_on: available_on,
      status: status,
      taxon_ids: taxon_ids,
      option_value_ids: option_value_ids,
      price: price_in(current_currency).amount,
      currency: current_currency.to_s
    }
  end
end
```

### 4. Search Controller'ı Güncelle

`storefront/app/controllers/spree/search_controller.rb`:

```ruby
def suggestions
  @products = []
  @taxons = []

  if query.present? && query.length >= Spree::Storefront::Config.search_min_query_length
    # Searchkick kullan
    @products = Spree::Product.search(query, 
      fields: [:name, :description],
      limit: 10,
      misspellings: { below: 5 }
    )
    
    @taxons = current_store.taxons.search_by_name(query)
  end
end
```

### 5. İlk Index Oluşturma

```bash
rails console
Spree::Product.reindex
```

### 6. Otomatik Reindex

Product güncellendiğinde otomatik reindex için:

```ruby
class Spree::Product < Spree.base_class
  after_commit :reindex, if: :saved_change_to_name?
  
  private
  
  def reindex
    Searchkick::ReindexJob.perform_later(self)
  end
end
```

## Alternatif: Spree Searchkick Extension

Spree için hazır bir extension var:
- h         

Bu extension'ı kullanmak daha kolay olabilir çünkü Spree ile tam entegre.

## Notlar

- Elasticsearch/OpenSearch ayrı bir servis olarak çalışmalı
- Production'da cluster kurulumu önerilir
- İlk index oluşturma uzun sürebilir (ürün sayısına bağlı)
- Searchkick gem'i Elasticsearch 7.x ve 8.x'i destekler


# 🚀 Spree Projesini Başka PC'ye Taşıma Rehberi

## 1️⃣ Mevcut PC'de (Bu PC)

### A. Git Push (Manuel)
```bash
cd /Users/metinaksoy/Dev/spreektm/spree
git push origin main
```

**SSL Hatası Alırsanız:**
```bash
# Geçici çözüm (dikkatli kullanın)
GIT_SSL_NO_VERIFY=true git push origin main

# VEYA sertifika path'ini düzeltin
git config --global http.sslCAInfo /etc/ssl/cert.pem
```

### B. .env Dosyalarını Yedekleyin

```bash
# .env dosyalarını bulun
cd /Users/metinaksoy/Dev/spreektm/spree
find . -name ".env*" -not -path "*/node_modules/*" -not -path "*/.git/*"

# Örnek dosyalar:
# - sandbox/.env
# - sandbox/.env.local
# - .env
```

**Yedekleme:**
```bash
# Tüm .env dosyalarını bir klasöre kopyalayın
mkdir ~/spree_env_backup
cp sandbox/.env ~/spree_env_backup/ 2>/dev/null || true
cp sandbox/.env.local ~/spree_env_backup/ 2>/dev/null || true
cp .env ~/spree_env_backup/ 2>/dev/null || true

# Veya tek zip dosyası yapın
tar -czf ~/spree_env_backup.tar.gz sandbox/.env* .env* 2>/dev/null || true
```

### C. Veritabanını Yedekleyin (Opsiyonel ama önemli)

```bash
# PostgreSQL backup
cd sandbox
RAILS_ENV=development rails db:dump

# Veya manuel export
pg_dump -U postgres spree_development > ~/spree_db_backup.sql
```

### D. Uploads/Assets Klasörlerini Yedekleyin

```bash
# ActiveStorage dosyaları
tar -czf ~/spree_storage_backup.tar.gz sandbox/storage/

# Public uploads (varsa)
tar -czf ~/spree_public_backup.tar.gz sandbox/public/uploads/ 2>/dev/null || true
```

### E. OpenSearch/Elasticsearch Verilerini Yedekleyin (Opsiyonel)

```bash
# OpenSearch snapshot
curl -X PUT "localhost:9200/_snapshot/my_backup/snapshot_1?wait_for_completion=true"

# Veya sadece reindex yapın yeni PC'de
```

---

## 2️⃣ Yeni PC'de (Hedef PC)

### A. Gerekli Yazılımları Kurun

```bash
# Homebrew (macOS)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Ruby (rbenv önerilen)
brew install rbenv ruby-build
rbenv install 3.3.0
rbenv global 3.3.0

# Node.js
brew install node

# PostgreSQL
brew install postgresql@14
brew services start postgresql@14

# Redis
brew install redis
brew services start redis

# OpenSearch (Searchkick için)
brew install opensearch
brew services start opensearch

# ImageMagick (image processing için)
brew install imagemagick
```

### B. Projeyi Clone Edin

```bash
cd ~/Dev
git clone https://github.com/k1meister/spree.git
cd spree
```

### C. .env Dosyalarını Geri Yükleyin

```bash
# USB/Cloud'dan .env backup'ını indirin
# Sonra kopyalayın:

cp ~/Downloads/spree_env_backup/.env sandbox/.env
cp ~/Downloads/spree_env_backup/.env.local sandbox/.env.local

# VEYA zip'den:
tar -xzf ~/Downloads/spree_env_backup.tar.gz -C .
```

**Önemli:** `.env` dosyasındaki path'leri yeni PC'ye göre güncelleyin!

### D. Bağımlılıkları Kurun

```bash
# Ruby gems
bundle install

# Node packages
cd sandbox
yarn install
# VEYA
npm install
```

### E. Veritabanını Kurun

```bash
cd sandbox

# Yeni DB oluştur
rails db:create

# Eğer backup varsa:
rails db:schema:load
psql -U postgres spree_development < ~/spree_db_backup.sql

# Veya sıfırdan:
rails db:migrate
rails db:seed
```

### F. ActiveStorage Dosyalarını Geri Yükleyin

```bash
# Storage backup'ını geri yükleyin
tar -xzf ~/spree_storage_backup.tar.gz -C sandbox/

# Public uploads (varsa)
tar -xzf ~/spree_public_backup.tar.gz -C sandbox/
```

### G. OpenSearch İndekslerini Oluşturun

```bash
cd sandbox
rails console

# Console'da:
Spree::Product.reindex
```

### H. Projeyi Çalıştırın

```bash
cd sandbox

# Sunucuyu başlatın
bin/dev

# VEYA manuel:
rails server -p 3000 & # Backend
bin/shakapacker-dev-server # Frontend assets
```

---

## 3️⃣ Kontrol Listesi

### Yedeklenmesi Gerekenler:
- ✅ Git repository (GitHub'da)
- ✅ `.env` dosyaları
- ✅ `sandbox/.env.local`
- ✅ Veritabanı dump'ı
- ✅ `sandbox/storage/` (ActiveStorage)
- ✅ `sandbox/public/uploads/` (varsa)
- ❌ `node_modules/` (HAYIR - bundle install ile gelir)
- ❌ `vendor/bundle/` (HAYIR - bundle install ile gelir)

### .env İçinde Olması Gerekenler:
```env
# Database
DATABASE_URL=postgresql://localhost/spree_development

# OpenSearch/Elasticsearch
OPENSEARCH_URL=http://localhost:9200
# VEYA
ELASTICSEARCH_URL=http://localhost:9200

# Redis (Sidekiq için)
REDIS_URL=redis://localhost:6379/0

# Rails
RAILS_ENV=development
SECRET_KEY_BASE=your_secret_key

# CDN (varsa)
CDN_HOST=your_cdn_host

# API Keys (varsa)
STRIPE_PUBLISHABLE_KEY=...
STRIPE_SECRET_KEY=...
```

---

## 4️⃣ GitHub Push Komutu (Manuel)

```bash
cd /Users/metinaksoy/Dev/spreektm/spree

# Push yap
git push origin main

# Eğer SSL hatası alırsanız:
export GIT_SSL_NO_VERIFY=true
git push origin main
unset GIT_SSL_NO_VERIFY
```

---

## 5️⃣ Hızlı Özet

**Mevcut PC:**
1. `git push origin main`
2. `.env` dosyalarını yedekle
3. `pg_dump > backup.sql`
4. `tar -czf storage.tar.gz sandbox/storage/`

**Yeni PC:**
1. Yazılımları kur (Ruby, Node, PostgreSQL, Redis, OpenSearch)
2. `git clone ...`
3. `.env` dosyalarını kopyala
4. `bundle install && npm install`
5. DB restore + `rails db:migrate`
6. Storage dosyalarını kopyala
7. `Spree::Product.reindex`
8. `bin/dev`

---

## 🆘 Sorun Giderme

### Problem: Bundle install hatası
```bash
# OpenSSL hatası
brew install openssl
export LDFLAGS="-L/opt/homebrew/opt/openssl@3/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openssl@3/include"
bundle install
```

### Problem: PostgreSQL bağlanma hatası
```bash
# PostgreSQL başlat
brew services restart postgresql@14

# Şifre yoksa ekle
psql postgres -c "ALTER USER postgres WITH PASSWORD 'postgres';"
```

### Problem: OpenSearch bağlanma hatası
```bash
# OpenSearch başlat
brew services restart opensearch

# Test et
curl http://localhost:9200
```

### Problem: ImageMagick hatası
```bash
brew reinstall imagemagick
```

---

## 📝 Notlar

- `.env` dosyaları **asla GitHub'a commit edilmez** (.gitignore'da)
- Her PC için `.env.local` farklı olabilir
- OpenSearch verileri reindex ile tekrar oluşturulabilir
- Veritabanı backup'ı **çok önemli** (production için)
- `sandbox/storage/` klasörü varsa mutlaka yedekleyin (ürün resimleri vb.)

---

## ✅ Tamamlandı!

Yeni PC'de proje çalışıyor olmalı: http://localhost:3000


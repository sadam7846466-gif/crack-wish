# 🦉 Arkadaş Sistemi — Implementation Plan

## Aşama 1: Modeller & Mock Servis
- `Friend` model (id, name, emoji, code, status)
- `Letter` model (id, from, to, message, sentAt, deliveredAt, isRead)
- `FriendRequest` model (id, from, to, status, createdAt)
- `MockOwlService` — tüm veriyi local tutar, backend gelince swap edilir

## Aşama 2: Arkadaş Ekleme UI
- "Baykuş Kodun: #OWL-XXXX" gösterimi (kendi kodun)
- Kod gir → arkadaş ekle dialog
- Kopyala butonu (kendi kodu paylaş)

## Aşama 3: Arkadaş İstekleri
- Gelen istekler listesi (kabul/red)
- Gönderilen istekler listesi (bekliyor)
- Badge sayısı

## Aşama 4: Mektup Sistemi Güncelleme
- Gönderilen mektuplar mock olarak inbox'a düşsün
- Okunmamış mektup badge'i
- Mektup detay görünümü (tam kağıt stili)
- "Baykuş yolda..." gecikme animasyonu

## Aşama 5: Backend Entegrasyonu (sonra)
- MockOwlService → FirebaseOwlService swap
- Auth ekleme
- Push notification

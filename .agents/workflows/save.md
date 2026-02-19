---
description: Uygulamayı GitHub'a kaydet (git commit + push)
---

# Uygulamayı Kaydet

Bu workflow projedeki değişiklikleri GitHub'a kaydeder.

// turbo-all

1. Değişiklikleri hazırla ve commit yap:
```bash
cd /Users/yusun/vlucky_flutter && git add -A && git commit -m "💾 güncelleme $(date '+%d-%m-%Y %H:%M')"
```

2. GitHub'a gönder:
```bash
cd /Users/yusun/vlucky_flutter && git push origin main
```

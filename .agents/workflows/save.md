---
description: Uygulamayı GitHub'a kaydet (git commit + push)
---

# Uygulamayı Kaydet

Bu workflow projedeki değişiklikleri GitHub'a kaydeder.
Önce son değişiklikleri çeker (eşin yaptığı değişiklikler varsa), sonra kaydeder.

// turbo-all

1. Önce son değişiklikleri çek (çakışma olmasın):
```bash
cd /Users/yusun/vlucky_flutter && git stash && git pull origin main --rebase && git stash pop || true
```

2. Değişiklikleri hazırla ve commit yap:
```bash
cd /Users/yusun/vlucky_flutter && git add -A && git commit -m "💾 gamze güncelleme $(date '+%d-%m-%Y %H:%M')"
```

3. GitHub'a gönder:
```bash
cd /Users/yusun/vlucky_flutter && git push origin main
```

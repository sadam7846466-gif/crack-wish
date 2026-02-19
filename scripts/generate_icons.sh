#!/bin/bash
# ─────────────────────────────────────────────────
# VLucky App Icon Generator
# ─────────────────────────────────────────────────
# Kullanım:
#   1. Yeni 1024x1024 ikonlarını assets/icons/ klasörüne koy:
#      - app_icon.png       (light mode)
#      - app_icon_dark.png  (dark mode)
#   2. Bu scripti çalıştır:
#      bash scripts/generate_icons.sh
# ─────────────────────────────────────────────────

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

LIGHT_SOURCE="$PROJECT_DIR/assets/icons/app_icon.png"
DARK_SOURCE="$PROJECT_DIR/assets/icons/app_icon_dark.png"
IOS_ICON_DIR="$PROJECT_DIR/ios/Runner/Assets.xcassets/AppIcon.appiconset"

# sips kontrolü (macOS yerleşik araç)
if ! command -v sips &> /dev/null; then
    echo "❌ 'sips' bulunamadı. Bu script sadece macOS'ta çalışır."
    exit 1
fi

echo "🍪 VLucky App Icon Generator"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Light mode ikonları ──
if [ -f "$LIGHT_SOURCE" ]; then
    echo ""
    echo "✅ Light mode ikonu bulundu: $LIGHT_SOURCE"
    echo "📐 iOS ikonları oluşturuluyor..."

    # Tüm gerekli boyutlar (size x scale = pixel)
    declare -a LIGHT_SIZES=(
        "20:1:20"
        "20:2:40"
        "20:3:60"
        "29:1:29"
        "29:2:58"
        "29:3:87"
        "38:2:76"
        "38:3:114"
        "40:1:40"
        "40:2:80"
        "40:3:120"
        "50:1:50"
        "50:2:100"
        "57:1:57"
        "57:2:114"
        "60:2:120"
        "60:3:180"
        "64:2:128"
        "64:3:192"
        "68:2:136"
        "72:1:72"
        "72:2:144"
        "76:1:76"
        "76:2:152"
        "83.5:2:167"
        "1024:1:1024"
    )

    for entry in "${LIGHT_SIZES[@]}"; do
        IFS=':' read -r size scale pixels <<< "$entry"
        filename="Icon-App-${size}x${size}@${scale}x.png"
        target="$IOS_ICON_DIR/$filename"
        
        cp "$LIGHT_SOURCE" "$target"
        sips -z "$pixels" "$pixels" "$target" --out "$target" > /dev/null 2>&1
        echo "   ✓ $filename (${pixels}x${pixels}px)"
    done

    echo "   🎉 Light mode: $(echo "${LIGHT_SIZES[@]}" | tr ' ' '\n' | wc -l | tr -d ' ') ikon oluşturuldu!"
else
    echo ""
    echo "⚠️  Light mode ikonu bulunamadı: $LIGHT_SOURCE"
    echo "   → assets/icons/app_icon.png dosyasını ekleyin"
fi

# ── Dark mode ikonları ──
if [ -f "$DARK_SOURCE" ]; then
    echo ""
    echo "✅ Dark mode ikonu bulundu: $DARK_SOURCE"
    echo "📐 Dark mode iOS ikonları oluşturuluyor..."

    declare -a DARK_SIZES=(
        "20:2:40"
        "20:3:60"
        "29:2:58"
        "29:3:87"
        "38:2:76"
        "38:3:114"
        "40:2:80"
        "40:3:120"
        "60:2:120"
        "60:3:180"
        "64:2:128"
        "64:3:192"
        "68:2:136"
        "76:2:152"
        "83.5:2:167"
        "1024:1:1024"
    )

    for entry in "${DARK_SIZES[@]}"; do
        IFS=':' read -r size scale pixels <<< "$entry"
        filename="Icon-App-Dark-${size}x${size}@${scale}x.png"
        target="$IOS_ICON_DIR/$filename"
        
        cp "$DARK_SOURCE" "$target"
        sips -z "$pixels" "$pixels" "$target" --out "$target" > /dev/null 2>&1
        echo "   ✓ $filename (${pixels}x${pixels}px)"
    done

    echo "   🎉 Dark mode: $(echo "${DARK_SIZES[@]}" | tr ' ' '\n' | wc -l | tr -d ' ') ikon oluşturuldu!"
else
    echo ""
    echo "⚠️  Dark mode ikonu bulunamadı: $DARK_SOURCE"
    echo "   → assets/icons/app_icon_dark.png dosyasını ekleyin"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Tamamlandı!"
echo ""
echo "📍 İkonlar: $IOS_ICON_DIR"
echo "💡 Xcode'da projeyi clean build yapmanız gerekebilir:"
echo "   flutter clean && flutter build ios"

#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# Recta Backend — Temiz Başlatma Script'i
# Kullanım: ./start.sh          (tercih edilen port: 5001)
#           ./start.sh 5005     (farklı port ile başlat)
# ─────────────────────────────────────────────────────────────

PREFERRED_PORT="${1:-5010}"
SEARCH_END=$((PREFERRED_PORT + 19))

echo ""
echo "╔══════════════════════════════════════╗"
echo "║      Recta Backend Başlatılıyor      ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── 0. TÜM eski backend süreçlerini temizle (zombie önleme) ──
echo "🧹 Önceki backend süreçleri temizleniyor..."
pkill -f "python.*app.py" 2>/dev/null
sleep 1
echo "   ✅ Temizlendi."

# ── 2. Tercih edilen port meşgul ise temizle ─────────────────
PORT_PID=$(lsof -ti :"$PREFERRED_PORT" 2>/dev/null)
if [ -n "$PORT_PID" ]; then
    # Hangi uygulama tutuyor?
    PORT_APP=$(lsof -i :"$PREFERRED_PORT" | awk 'NR==2{print $1}')
    echo "⚠️  Port $PREFERRED_PORT → '$PORT_APP' (PID: $PORT_PID) tarafından kullanılıyor."
    
    # Sistem süreçlerine (ControlCenter / AirPlay) dokunma
    if [[ "$PORT_APP" == "ControlCe" || "$PORT_APP" == "AirPlay" || "$PORT_APP" == "AirPlayXP" ]]; then
        echo "   ℹ️  Bu bir macOS sistem servisi — dokunulmadı."
        echo "   → app.py otomatik olarak $((PREFERRED_PORT + 1))–$SEARCH_END arasında boş port arayacak."
    else
        echo "   🔫 Kullanıcı süreci — sonlandırılıyor..."
        kill "$PORT_PID" 2>/dev/null
        sleep 1
        echo "   ✅ Port $PREFERRED_PORT boşaltıldı."
    fi
fi

# ── 3. Sanal ortamı aktif et ──────────────────────────────────
cd "$SCRIPT_DIR"

if [ ! -d "venv" ]; then
    echo "❌ 'venv' klasörü bulunamadı! Önce şunu çalıştır:"
    echo "   python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt"
    exit 1
fi

source venv/bin/activate

# ── 4. .env kontrol ───────────────────────────────────────────
if [ ! -f ".env" ]; then
    echo "❌ .env dosyası bulunamadı! Şunu çalıştır:"
    echo "   cp .env.example .env  →  sonra GEMINI_API_KEY değerini gir."
    exit 1
fi

# ── 5. Tercih edilen portu env'e aktar ve başlat ─────────────
echo ""
echo "🚀 python app.py başlatılıyor (tercih: port $PREFERRED_PORT)..."
echo "   (Port doluysa 5001–$SEARCH_END arasında otomatik arar)"
echo ""

PORT="$PREFERRED_PORT" python app.py
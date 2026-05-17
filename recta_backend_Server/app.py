"""
Recta Backend — Flask API Sunucusu
Flutter'dan gelen poz verilerini alır, Gemini API'ye gönderir, yanıtı döner.
"""

import os
import json
import re
import socket
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv

from gemini_service import GeminiService
from prompt_builder import PromptBuilder


def _find_free_port(preferred: int = 5001, search_range: int = 20) -> int:
    """
    preferred port'tan başlayarak boş bir port bulur.
    İşe yararsa preferred'i döndürür; dolu ise preferred+1, +2 ... dener.
    """
    for port in range(preferred, preferred + search_range):
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            try:
                s.bind(('', port))
                return port  # Bağlanabildi = port boş
            except OSError:
                continue
    raise RuntimeError(
        f"❌ {preferred}–{preferred + search_range - 1} aralığında boş port bulunamadı!"
    )

# ── .env dosyasını yükle ──
load_dotenv()

app = Flask(__name__)
CORS(app)  # Flutter'dan gelen cross-origin isteklerine izin ver

# ── Gemini servisi başlat ──
gemini = GeminiService(api_key=os.getenv("GEMINI_API_KEY"))


@app.route("/api/analyze", methods=["POST"])
def analyze():
    """
    Flutter'dan gelen poz açı verilerini analiz eder.
    
    Beklenen JSON formatı:
    {
        "exercise_type": "SQUAT",
        "frames": [
            {
                "frameIndex": 1,
                "timestampMs": 100,
                "angles": {
                    "left_knee_angle": 145.23,
                    "right_knee_angle": 142.87,
                    ...
                }
            },
            ...
        ]
    }
    """
    try:
        data = request.get_json()

        if not data:
            return jsonify({"error": "JSON verisi bulunamadı."}), 400

        exercise_type = data.get("exercise_type", "UNKNOWN")
        injury_history = data.get("injury_history", "Yok")
        user_name = data.get("user_name", "Kullanıcı")
        frames = data.get("frames", [])

        if not frames:
            return jsonify({"error": "Frame verisi boş."}), 400

        print(f"📥 Gelen istek: {exercise_type}, {len(frames)} frame, kullanıcı: {user_name}")

        # 1. Prompt oluştur
        prompt = PromptBuilder.build(exercise_type, injury_history, frames, user_name)
        print(f"📝 Prompt oluşturuldu ({len(prompt)} karakter)")

        # 2. Gemini'ye gönder
        gemini_response = gemini.analyze(prompt)
        print(f"✅ Gemini yanıtı alındı")

        # 3. Gemini yanıtını taglere göre parse et
        parsed_analysis = _parse_gemini_text(gemini_response)

        # 4. Yanıtı döndür
        return jsonify({
            "status": "success",
            "exercise_type": exercise_type,
            "total_frames": len(frames),
            "analysis": parsed_analysis,
        }), 200

    except Exception as e:
        print(f"❌ [HATA] analyze endpoint: {e}")
        return jsonify({"error": f"Sunucu hatası: {str(e)}"}), 500


@app.route("/api/health", methods=["GET"])
def health():
    """Sunucu sağlık kontrolü — Flutter bağlantı testi için."""
    return jsonify({"status": "ok", "service": "Recta Backend"}), 200


def _parse_gemini_text(raw_text: str):
    """
    Gemini'den gelen metin tabanlı yanıtı parse eder.
    Tag'leri split ile ayırır; geribildirimler'den madde listesi de çıkarır.

    Döndürdüğü alanlar (Flutter UI ile birebir uyumlu):
      skor, kritik_cumle, ozet, geribildirimler, tam_metin,
      guclu_yonler (list), zayif_yonler (list), oneriler (list)
    """
    text = raw_text.strip()

    result = {
        "skor": 0,
        "kritik_cumle": "",
        "ozet": "",
        "geribildirimler": "",
        "tam_metin": text,
        "guclu_yonler": [],
        "zayif_yonler": [],
        "oneriler": [],
    }

    # ── Skor ──────────────────────────────────────────────────────────────────
    skor_match = re.search(r'\[SKOR\]\s*(\d+)', text)
    if skor_match:
        result["skor"] = int(skor_match.group(1))

    # ── Metni [TAG] sınırlarına göre böl ─────────────────────────────────────
    sections = re.split(r'\[(SKOR|KRITIK_CUMLE|GENEL_ANALIZ|GUCLU_YONLER|ZAYIF_YONLER|GERIBILDIRIMLER)\]', text)

    current_tag = None
    guclu_text = ""
    zayif_text = ""
    
    for part in sections:
        part = part.strip()
        if part in ('SKOR', 'KRITIK_CUMLE', 'GENEL_ANALIZ', 'GUCLU_YONLER', 'ZAYIF_YONLER', 'GERIBILDIRIMLER'):
            current_tag = part
        elif current_tag == 'KRITIK_CUMLE' and not result["kritik_cumle"]:
            # Tek satır — sadece ilk satırı al, bold/italic işaretlerini temizle
            first_line = part.split('\n')[0].strip()
            cleaned = re.sub(r'^[\*\_]+|[\*\_]+$', '', first_line).strip()
            cleaned = re.sub(r'^["\']+|["\']+$', '', cleaned).strip()  # tırnak işaretlerini kaldır
            # Selamlama ile başlıyorsa geribildirimler'den ilk analitik cümleyi çıkar
            GREETING_WORDS = ('merhaba', 'sayın', 'sevgili', 'dear', 'hello')
            if any(cleaned.lower().startswith(w) for w in GREETING_WORDS) or not cleaned:
                cleaned = ''  # Boş bırak — geribildirimler'den sonra doldurulacak
            result["kritik_cumle"] = cleaned
            current_tag = None
        elif current_tag == 'GENEL_ANALIZ' and not result["ozet"]:
            result["ozet"] = part
            current_tag = None
        elif current_tag == 'GUCLU_YONLER' and not guclu_text:
            guclu_text = part
            current_tag = None
        elif current_tag == 'ZAYIF_YONLER' and not zayif_text:
            zayif_text = part
            current_tag = None
        elif current_tag == 'GERIBILDIRIMLER' and not result["geribildirimler"]:
            result["geribildirimler"] = part
            current_tag = None

    # ── Fallback ──────────────────────────────────────────────────────────────
    if not result["ozet"] and not result["geribildirimler"]:
        result["ozet"] = text

    # ── Madde listesi (bullet point) ayıklama fonksiyonu ──────────────────
    def _parse_list(text_block):
        if not text_block: return []
        text_for_split = "\n" + text_block
        raw_items = re.split(r'\n\s*(?:[*•\-]|\d+\.)\s*', text_for_split)
        items = []
        for item in raw_items:
            cleaned = re.sub(r'\*+', '', item).strip()
            cleaned = re.sub(r'^#+\s*', '', cleaned)
            cleaned = re.sub(r'\s+', ' ', cleaned)
            if len(cleaned) > 10:
                items.append(cleaned)
        return items

    if result["geribildirimler"]:
        result["oneriler"] = _parse_list(result["geribildirimler"])[:6]
        
    if guclu_text:
        result["guclu_yonler"] = _parse_list(guclu_text)[:4]
        
    if zayif_text:
        result["zayif_yonler"] = _parse_list(zayif_text)[:4]

    # ── kritik_cumle boşsa geribildirimler'den ilk analitik maddeyi çek ────────
    if not result["kritik_cumle"]:
        GREETING_WORDS = ('merhaba', 'sayın', 'sevgili')
        # Önce ozet'ten selamlama olmayan ilk cümleyi dene (Noktalama işaretlerini koruyarak böl)
        for s in re.split(r'(?<=[.!?])\s+', result["ozet"]):
            s = s.strip()
            if len(s) > 20 and not any(s.lower().startswith(w) for w in GREETING_WORDS):
                result["kritik_cumle"] = s[:80].rstrip() + ('...' if len(s) > 80 else '')
                break
        # Hâlâ boşsa oneriler'den ilk maddeyi al
        if not result["kritik_cumle"] and result["oneriler"]:
            s = result["oneriler"][0]
            result["kritik_cumle"] = s[:80].rstrip() + ('...' if len(s) > 80 else '')

    # ── Eski tip (Tag'siz) yanıtlar için Fallback ────────────────────────────
    if not result["guclu_yonler"] and not result["zayif_yonler"]:
        ozet = result["ozet"]
        guclu_keywords = ["iyi", "güçlü", "başarılı", "mükemmel", "stabil", "simetri", "doğru", "ideal"]
        # "dikkat" kelimesi çıkarıldı çünkü "dikkatle inceledim" cümlesini zayıf yön sanıyordu
        zayif_keywords = ["geliştirilmeli", "eksik", "yetersiz", "artırmalı", "sığ", "hata", "yanlış"]
    
        for s in re.split(r'(?<=[.!?])\s+', ozet):
            s = s.strip()
            if not s or len(s) < 20:
                continue
            lower = s.lower()
            is_guclu = any(k in lower for k in guclu_keywords)
            is_zayif = any(k in lower for k in zayif_keywords)
            if is_guclu and not is_zayif and len(result["guclu_yonler"]) < 3:
                result["guclu_yonler"].append(s)
            elif is_zayif and len(result["zayif_yonler"]) < 3:
                result["zayif_yonler"].append(s)

    return result



if __name__ == "__main__":
    preferred_port = int(os.getenv("PORT", 5010))
    port = _find_free_port(preferred=preferred_port)

    # Flutter ve diğer araçlar için aktif portu dosyaya yaz
    port_file = os.path.join(os.path.dirname(__file__), ".active_port")
    with open(port_file, "w") as f:
        f.write(str(port))

    print(f"🚀 Recta Backend başlatılıyor — port: {port}")
    if port != preferred_port:
        print(f"⚠️  Port {preferred_port} dolu, {port} kullanılıyor.")
    print(f"📡 Adres: http://0.0.0.0:{port}")
    print(f"💾 Aktif port → .active_port dosyasına yazıldı.")

    # use_reloader=False → Flask debug'ın ikinci "reloader" sürecini engeller.
    # Aksi hâlde her başlatmada 2 instance açılır ve port karmaşası yaşanır.
    # threaded=True → Birden fazla eş zamanlı Flutter isteğini karşılar.
    app.run(host="0.0.0.0", port=port, debug=True, use_reloader=False, threaded=True)

#!/usr/bin/env python3
"""
simulate_analysis.py — Recta Tam Pipeline Testi

Gerçek bir kamera oturumunu simüle eder:
  1. 12 frame'lik gerçekçi SQUAT açı verisi oluşturur
  2. Backend'e POST /api/analyze gönderir (Gemini'ye iletilir)
  3. Gelen analizi güzel formatta yazdırır
  4. Firestore'a Flutter uygulamasıyla AYNI yapıda kaydeder

Kullanım:
  cd recta_backend
  source venv/bin/activate
  python simulate_analysis.py
"""

import json
import math
import uuid
import httpx
import sys
from datetime import datetime, timezone

# ─────────────────────────────────────────────────────────────
# AYARLAR
# ─────────────────────────────────────────────────────────────
BACKEND_PORTS   = [5010, 5011, 5012, 5013, 5014, 5015]
HOST_IP         = "10.89.108.226"
FIREBASE_PROJECT = "recta-b2827"

# Test kullanıcısı (Firebase'deki gerçek kullanıcı UID'si)
# Uygulamada giriş yapan kullanıcının UID'sini buraya yaz
TEST_USER_ID    = "EabvEOwSSyPYZMgRAuDnYGUWYvh2"  # Firebase Auth'dan alınan UID
TEST_USER_NAME  = "Yağız"
EXERCISE_TYPE   = "SQUAT"
INJURY_HISTORY  = "Yok"

# ─────────────────────────────────────────────────────────────
# 1. BACKEND KEŞFİ
# ─────────────────────────────────────────────────────────────

def find_backend() -> str:
    print("🔍 Backend aranıyor...")
    for port in BACKEND_PORTS:
        url = f"http://{HOST_IP}:{port}"
        try:
            r = httpx.get(f"{url}/api/health", timeout=1.5)
            if r.status_code == 200:
                print(f"   ✅ Backend bulundu: {url}")
                return url
        except Exception:
            pass
    raise RuntimeError(
        f"❌ Backend bulunamadı! {HOST_IP}:{BACKEND_PORTS[0]}-{BACKEND_PORTS[-1]} "
        f"arasında hiçbir instance yanıt vermedi.\n"
        f"   → recta_backend klasöründe 'python app.py' komutunu çalıştır."
    )

# ─────────────────────────────────────────────────────────────
# 2. GERÇEKÇİ SQUAT FRAME VERİSİ OLUŞTUR (12 frame)
# ─────────────────────────────────────────────────────────────

def generate_squat_frames(n: int = 12) -> list:
    """
    Bir squat hareketini simüle eden gerçekçi açı değerleri üretir.
    Hareket evresi: Ayakta (frame 1-2) → İniş (3-6) → Dip (7-8) → Çıkış (9-12)
    """
    frames = []

    def lerp(a, b, t):
        return a + (b - a) * t

    def noisy(val, noise=2.0):
        import random
        return round(val + random.uniform(-noise, noise), 2)

    # Faz tanımları: (başlangıç frame indeksi, faz oranı 0→1, hedef açılar)
    phases = [
        # Ayakta bekleme (frame 1-2)
        {"frames": 2, "knee": (165, 155), "trunk": (175, 170)},
        # İniş (frame 3-6)
        {"frames": 4, "knee": (155, 88), "trunk": (170, 150)},
        # Dip noktası (frame 7-8)
        {"frames": 2, "knee": (88, 85), "trunk": (150, 148)},
        # Çıkış (frame 9-12)
        {"frames": 4, "knee": (85, 162), "trunk": (148, 172)},
    ]

    frame_idx = 1
    timestamp = 0

    for phase in phases:
        count = phase["frames"]
        for i in range(count):
            t = i / max(count - 1, 1)
            knee  = lerp(phase["knee"][0],  phase["knee"][1],  t)
            trunk = lerp(phase["trunk"][0], phase["trunk"][1], t)

            # Sol/sağ hafif asimetri (gerçekçilik için)
            frame = {
                "frameIndex":  frame_idx,
                "timestampMs": timestamp,
                "angles": {
                    "left_knee_angle":   noisy(knee, 3.0),
                    "right_knee_angle":  noisy(knee + 2.5, 2.5),
                    "left_trunk_angle":  noisy(trunk, 2.0),
                    "right_trunk_angle": noisy(trunk - 1.5, 2.0),
                    "left_hip_angle":    noisy(180 - knee * 0.3, 3.0),
                    "right_hip_angle":   noisy(180 - (knee + 2.5) * 0.3, 3.0),
                }
            }
            frames.append(frame)
            frame_idx  += 1
            timestamp  += 333  # ~3 fps (4 saniye / 12 frame)

    return frames

# ─────────────────────────────────────────────────────────────
# 3. BACKEND'E GÖNDER → GEMİNİ ANALİZİ
# ─────────────────────────────────────────────────────────────

def call_backend(base_url: str, frames: list) -> dict:
    payload = {
        "exercise_type": EXERCISE_TYPE,
        "user_name":     TEST_USER_NAME,
        "injury_history": INJURY_HISTORY,
        "frames":        frames,
    }

    print(f"\n📤 Backend'e gönderiliyor ({len(frames)} frame)...")
    print(f"   URL: {base_url}/api/analyze")

    response = httpx.post(
        f"{base_url}/api/analyze",
        json=payload,
        timeout=90.0,   # Gemini yavaş olabilir
        headers={"Content-Type": "application/json"},
    )

    if response.status_code != 200:
        raise RuntimeError(f"Backend HTTP {response.status_code}: {response.text}")

    return response.json()

# ─────────────────────────────────────────────────────────────
# 4. FİRESTORE'A KAYDET (REST API — Admin SDK gerektirmez)
# ─────────────────────────────────────────────────────────────

FIRESTORE_BASE = (
    f"https://firestore.googleapis.com/v1/projects/{FIREBASE_PROJECT}"
    f"/databases/(default)/documents"
)

def _fs_value(v):
    """Python değerini Firestore REST API formatına çevirir."""
    if isinstance(v, bool):
        return {"booleanValue": v}
    if isinstance(v, int):
        return {"integerValue": str(v)}
    if isinstance(v, float):
        return {"doubleValue": v}
    if isinstance(v, str):
        return {"stringValue": v}
    if isinstance(v, dict):
        return {"mapValue": {"fields": {k: _fs_value(val) for k, val in v.items()}}}
    if isinstance(v, list):
        return {"arrayValue": {"values": [_fs_value(item) for item in v]}}
    return {"nullValue": None}

def firestore_create(collection: str, doc_id: str, data: dict):
    """Firestore'a Public rules ile belge oluşturur."""
    url = f"{FIRESTORE_BASE}/{collection}?documentId={doc_id}"
    body = {"fields": {k: _fs_value(v) for k, v in data.items()}}

    r = httpx.post(url, json=body, timeout=15.0)
    if r.status_code not in (200, 201):
        print(f"   ⚠️  Firestore yazma hatası [{collection}/{doc_id}]: {r.status_code} {r.text[:200]}")
        return False
    return True

def save_to_firestore(analysis: dict, frames: list) -> str:
    """
    Flutter uygulamasıyla aynı şemada Firestore'a kaydeder:
      - Analyses/{analysisId}
      - AIFeedbacks/{feedbackId}
      - FrameData/{frameId}  (her frame için)
    """
    analysis_id = str(uuid.uuid4())
    feedback_id  = str(uuid.uuid4())
    now_iso      = datetime.now(timezone.utc).isoformat()

    print(f"\n💾 Firestore'a kaydediliyor...")
    print(f"   AnalysisId: {analysis_id}")

    # 1. Analyses
    ok1 = firestore_create("Analyses", analysis_id, {
        "AnalysisId":     analysis_id,
        "UserId":         TEST_USER_ID,
        "MovementTypeId": EXERCISE_TYPE,
        "OverallScore":   analysis.get("skor", 0),
        "VideoUrl":       "",
        "AnalysisDate":   now_iso,
        "SimulatedTest":  True,   # Bu simülasyon testi olduğunu işaretle
    })

    # 2. AIFeedbacks
    ok2 = firestore_create("AIFeedbacks", feedback_id, {
        "FeedbackId":       feedback_id,
        "AnalysisId":       analysis_id,
        "FeedbackText":     analysis.get("ozet", ""),
        "DetailedFeedback": analysis.get("geribildirimler", ""),
        "GeneratedAt":      now_iso,
    })

    # 3. FrameData
    ok3 = True
    for frame in frames:
        frame_id = str(uuid.uuid4())
        ok3 = ok3 and firestore_create("FrameData", frame_id, {
            "FrameId":    frame_id,
            "AnalysisId": analysis_id,
            "TimestampMs": frame["timestampMs"],
            "Angles":     frame["angles"],
        })

    if ok1 and ok2 and ok3:
        print(f"   ✅ Tüm koleksiyonlar kaydedildi.")
    else:
        print(f"   ⚠️  Bazı koleksiyonlar yazılamadı (yukarıdaki hata mesajlarına bak).")

    return analysis_id

# ─────────────────────────────────────────────────────────────
# 5. SONUÇLARI YAZDIR
# ─────────────────────────────────────────────────────────────

def print_results(backend_response: dict, analysis_id: str):
    analysis = backend_response.get("analysis", {})

    print("\n" + "═" * 60)
    print("  📊  GEMİNİ ANALİZ SONUCU")
    print("═" * 60)
    print(f"  Egzersiz  : {backend_response.get('exercise_type', '?')}")
    print(f"  Toplam Frame : {backend_response.get('total_frames', '?')}")
    print(f"  Skor      : {analysis.get('skor', 0)} / 100")
    print("─" * 60)
    print(f"\n🧠 GENEL ANALİZ:\n")
    print(analysis.get("ozet", "(boş)"))
    print("\n─" * 60)
    print(f"\n💡 GERİBİLDİRİMLER:\n")
    print(analysis.get("geribildirimler", "(boş)"))
    print("\n" + "═" * 60)
    print(f"\n✅ Firebase Analyses ID : {analysis_id}")
    print(f"   Proje              : {FIREBASE_PROJECT}")
    print(f"   Firestore Console  :")
    print(f"   https://console.firebase.google.com/project/{FIREBASE_PROJECT}/firestore")
    print()

# ─────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n╔══════════════════════════════════════════════╗")
    print("║   Recta — Tam Pipeline Simülasyon Testi      ║")
    print("╚══════════════════════════════════════════════╝\n")

    try:
        # 1. Backend'i bul
        base_url = find_backend()

        # 2. 12 frame SQUAT verisi oluştur
        frames = generate_squat_frames(12)
        print(f"\n📐 {len(frames)} frame SQUAT verisi oluşturuldu:")
        for f in frames:
            angles = f["angles"]
            print(f"   Frame {f['frameIndex']:>2} | {f['timestampMs']}ms | "
                  f"sol_diz={angles['left_knee_angle']:.1f}° "
                  f"sağ_diz={angles['right_knee_angle']:.1f}° "
                  f"gövde={angles['left_trunk_angle']:.1f}°")

        # 3. Gemini'den analiz al
        print(f"\n⏳ Gemini'den analiz bekleniyor (30-60 sn sürebilir)...")
        backend_response = call_backend(base_url, frames)
        print(f"   ✅ Gemini yanıtı alındı!")

        # 4. Firestore'a kaydet
        analysis_id = save_to_firestore(backend_response["analysis"], frames)

        # 5. Sonuçları yazdır
        print_results(backend_response, analysis_id)

    except KeyboardInterrupt:
        print("\n⚠️  Kullanıcı tarafından durduruldu.")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ HATA: {e}")
        sys.exit(1)

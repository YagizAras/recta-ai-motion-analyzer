"""
GeminiService — Google Gemini API ile iletişim kurar.
google-genai (v1.x) SDK kullanır.

503 / yoğunluk hatalarında otomatik yeniden dener (exponential backoff).
"""

import time
import random
from typing import Optional
from google import genai
from google.genai import types


class GeminiService:
    # Önce hızlı model, 503 alınırsa yedek modele geç
    _PRIMARY_MODEL   = "gemini-2.5-flash"
    _FALLBACK_MODEL  = "gemini-2.0-flash"

    # Retry ayarları
    _MAX_RETRIES = 4          # toplam deneme sayısı
    _BASE_DELAY  = 2.0        # ilk bekleme (saniye)
    _MAX_DELAY   = 30.0       # maksimum bekleme (saniye)

    def __init__(self, api_key: str):
        if not api_key:
            raise ValueError(
                "GEMINI_API_KEY tanımlı değil!\n"
                ".env dosyasını oluşturup içine GEMINI_API_KEY=... yazmalısın.\n"
                "Örnek: cp .env.example .env && nano .env"
            )

        self.client = genai.Client(api_key=api_key)

    def analyze(self, prompt: str) -> str:
        """
        Gemini'ye prompt gönderir ve metin yanıtını döner.
        503 / UNAVAILABLE hatalarında exponential backoff ile yeniden dener.
        """
        models_to_try = [self._PRIMARY_MODEL, self._FALLBACK_MODEL]

        for model_name in models_to_try:
            result = self._try_with_retry(prompt, model_name)
            if result is not None:
                return result
            print(f"⚠️  {model_name} tüm denemeler başarısız — yedek modele geçiliyor...")

        raise Exception(
            "Gemini API şu an çok yoğun (503). Lütfen birkaç dakika sonra tekrar deneyin."
        )

    def _try_with_retry(self, prompt: str, model_name: str) -> Optional[str]:
        """
        Belirtilen modelle en fazla _MAX_RETRIES kez dener.
        Başarılı olursa yanıt metnini, tamamen başarısız olursa None döner.
        """
        for attempt in range(1, self._MAX_RETRIES + 1):
            try:
                print(f"🤖 Gemini isteği [{model_name}] — deneme {attempt}/{self._MAX_RETRIES}")
                response = self.client.models.generate_content(
                    model=model_name,
                    contents=prompt,
                    config=types.GenerateContentConfig(
                        temperature=0.7,
                        max_output_tokens=3000,
                    ),
                )
                print(f"✅ Gemini yanıtı alındı [{model_name}] — deneme {attempt}")
                return response.text or "Analiz sonucu alınamadı."

            except Exception as e:
                error_str = str(e)
                is_503 = "503" in error_str or "UNAVAILABLE" in error_str or "high demand" in error_str

                if is_503 and attempt < self._MAX_RETRIES:
                    # Exponential backoff + jitter
                    delay = min(self._BASE_DELAY * (2 ** (attempt - 1)), self._MAX_DELAY)
                    delay += random.uniform(0, 1)  # jitter — aynı anda gelen istekleri dağıtır
                    print(f"⏳ 503 hatası [{model_name}] — {delay:.1f}s sonra yeniden denenecek... ({attempt}/{self._MAX_RETRIES})")
                    time.sleep(delay)
                else:
                    # 503 değil (başka hata) veya tüm denemeler bitti
                    print(f"❌ [HATA] Gemini API [{model_name}]: {e}")
                    return None  # Bir sonraki modeli dene

        return None

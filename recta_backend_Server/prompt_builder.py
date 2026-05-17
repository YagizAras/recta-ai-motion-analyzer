"""
PromptBuilder — Flutter'dan gelen frame/açı verisini
Gemini'nin anlayacağı yapılandırılmış bir prompt'a dönüştürür.
"""

import json


class PromptBuilder:
    # ── Egzersiz tipine göre ideal açı aralıkları (referans) ──
    EXERCISE_CONTEXT = {
        "SQUAT": {
            "name": "Squat",
            "ideal_ranges": {
                "left_knee_angle": (85, 100),
                "right_knee_angle": (85, 100),
                "left_trunk_angle": (140, 170),
                "right_trunk_angle": (140, 170),
            },
            "focus": "Diz açısı, gövde eğilimi, simetri",
        },
        "PUSH_UP": {
            "name": "Şınav",
            "ideal_ranges": {
                "left_elbow_angle": (80, 100),
                "right_elbow_angle": (80, 100),
                "left_trunk_angle": (160, 180),
            },
            "focus": "Dirsek bükülmesi, gövde hizası",
        },
        "SHOT_FORM": {
            "name": "Basketbol Şut Formu",
            "ideal_ranges": {
                "right_elbow_angle": (85, 100),
                "left_elbow_angle": (85, 100),
                "right_shoulder_angle": (80, 100),
                "left_shoulder_angle": (80, 100),
                "right_knee_angle": (140, 170),
            },
            "focus": "Dirsek açısı, omuz açısı, sıçrama mekaniği",
        },
        "SHOULDER_MOBILITY": {
            "name": "Omuz Mobilitesi",
            "ideal_ranges": {
                "left_shoulder_angle": (150, 180),
                "right_shoulder_angle": (150, 180),
            },
            "focus": "Omuz hareket açıklığı, simetri",
        },
    }

    @staticmethod
    def build(exercise_type: str, injury_history: str, frames: list, user_name: str = "Kullanıcı") -> str:
        """
        Frame listesinden Gemini'ye gönderilecek prompt'u oluşturur.
        """
        context = PromptBuilder.EXERCISE_CONTEXT.get(exercise_type, {})
        exercise_name = context.get("name", exercise_type)
        focus = context.get("focus", "genel form")
        ideal_ranges = context.get("ideal_ranges", {})

        # ── Frame verilerini özetleyerek metne dönüştür ──
        frame_summary = PromptBuilder._summarize_frames(frames, ideal_ranges)

        # ── İdeal aralıkları okunabilir formata çevir ──
        ideal_text = ""
        for angle_name, (low, high) in ideal_ranges.items():
            ideal_text += f"  - {angle_name}: {low}° – {high}°\n"

        prompt = f"""Sen uzman bir spor bilimci ve fizyoterapistsin. Recta adlı hareket analizi uygulamasından gelen, kullanıcının egzersiz performansını içeren 3D iskelet açı verilerini inceliyorsun.

Sana sunulan veri seti statik bir duruş değil; toplamda yaklaşık {len(frames)} kareden (frame) oluşan ve hareketin baştan sona akışını temsil eden ardışık bir video kesitidir. Analizini yaparken bu verileri tıpkı bir egzersiz videosunu izleyip değerlendiriyormuş gibi ele almalısın. Hareketin evrelerini (başlangıç, dip/tepe noktası, bitiş) göz önünde bulundurarak, sapmaları ve form bozukluklarını buna göre yorumla.

## KULLANICI ADI: {user_name}
## EGZERSİZ: {exercise_name}
## KULLANICI SAKATLIK GEÇMİŞİ: {injury_history}
## ODAK NOKTALARI: {focus}

## İDEAL AÇI ARALIKLARI (Referans):
{ideal_text}

## ÖLÇÜLEN VERİLER ({len(frames)} kare, 3 saniyelik kayıt):
{frame_summary}

## GÖREV:
1. Yukarıdaki açı verilerini ideal aralıklarla karşılaştır.
2. Formun güçlü ve zayıf yönlerini belirle.
3. Simetri analizi yap (sol vs sağ taraf).
4. Somut ve uygulanabilir 2-3 düzeltme önerisi ver.
5. Yanıtını Türkçe olarak yaz.
6. Kullanıcıya ismiyle hitap et: "{user_name}".
7. KESİNLİKLE METNİN HİÇBİR YERİNDE (Genel analiz, geribildirim vb.) sayısal derece/açı veya yüzde değerleri (örn: 90°, %20, 145 derece) KULLANMA. Kullanıcılar sayısal dereceleri (açıları) tam olarak hesaplayıp ölçemeyeceği için, bunları kullanıcının hemen anlayabileceği pratik bedensel yönlendirmelere çevir (örn: 'Dizlerini daha fazla bükmelisin', 'Gövdeni dik tutmalısın').

## YANIT FORMATI:
Yanıtını detaylı, okunaklı ve kullanıcıya hitap eden bir metin olarak yaz. Ancak verileri sistemin otomatik ayıklayabilmesi için SADECE aşağıdaki anahtar kelimeleri başlık olarak kullan ve yapıya birebir uy:

[SKOR]
(Sadece 0 ile 100 arası genel form skorunu sayı olarak yaz. Örn: 85)

[KRITIK_CUMLE]
(YALNIZCA 1 kısa cümle yaz — maksimum 12 kelime. Kurallar: 1) KESİNLİKLE selamlama, isim veya "Merhaba" ile BAŞLAMA. 2) Sayısal derece/açı veya yüzde belirtme, bunun yerine kullanıcının hemen uygulayabileceği fiziksel bir düzeltme sun. Örn: "Sağ omzunu yeterince açmıyorsun, simetriye odaklan." veya "Dizlerini tam bükmüyorsun, biraz daha derine inmelisin.")

[GENEL_ANALIZ]
(Buraya kullanıcıya ismiyle hitap ederek hareketi hakkında detaylı, motive edici ve genel bir değerlendirme paragrafı yaz. UYARI: KESİNLİKLE sayısal açı/derece değerleri kullanma, sadece bedensel duruş üzerinden geri bildirim ver.)

[GUCLU_YONLER]
(Hareketin iyi yapılan, başarılı kısımlarını kısa ve öz bir şekilde madde madde yaz. Her madde tek bir bedensel duruşu anlatsın ve KESİNLİKLE sayısal açı kullanma.)

[ZAYIF_YONLER]
(Hareketin hatalı, eksik veya geliştirilmesi gereken kısımlarını kısa ve öz bir şekilde madde madde yaz. Her madde tek bir hatayı anlatsın ve KESİNLİKLE sayısal açı kullanma.)

[GERIBILDIRIMLER]
(Buraya formun düzeltilmesi veya geliştirilmesi için nelerin yapılabileceğine dair detaylı, madde madde öneriler yaz. Önerilerini sunarken kullanıcının SAKATLIK GEÇMİŞİNİ KESİNLİKLE DİKKATE AL. UYARI: Sayısal dereceler kullanma, tamamen pratik ve fiziksel yönlendirmeler yap.)
"""
        return prompt

    @staticmethod
    def _summarize_frames(frames: list, ideal_ranges: dict) -> str:
        """Frame'leri okunabilir bir özet haline getirir."""
        if not frames:
            return "Veri yok."

        # Her açı için min, max, ortalama hesapla
        all_angles = {}
        for frame in frames:
            angles = frame.get("angles", {})
            for key, value in angles.items():
                if key not in all_angles:
                    all_angles[key] = []
                all_angles[key].append(value)

        lines = []
        for angle_name, values in all_angles.items():
            avg = sum(values) / len(values)
            min_val = min(values)
            max_val = max(values)
            
            # İdeal aralık kontrolü
            ideal = ideal_ranges.get(angle_name)
            status = ""
            if ideal:
                if avg < ideal[0]:
                    status = f" ⚠️ İdealin altında (ideal: {ideal[0]}°–{ideal[1]}°)"
                elif avg > ideal[1]:
                    status = f" ⚠️ İdealin üstünde (ideal: {ideal[0]}°–{ideal[1]}°)"
                else:
                    status = f" ✅ İdeal aralıkta"

            lines.append(
                f"  - {angle_name}: ort={avg:.1f}° | min={min_val:.1f}° | max={max_val:.1f}°{status}"
            )

        return "\n".join(lines)

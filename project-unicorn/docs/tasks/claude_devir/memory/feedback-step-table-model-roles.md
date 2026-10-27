---
name: feedback-step-table-model-roles
description: Erdem 2026-10-16 çalışma kuralı — her faz öncesi adım tablosu ve onay; model rolleri (Sonnet kod xhigh/max, Opus tasarım + kıdemli inceleme ve düzeltme hakkı, Haiku mekanik); plan önce güçlü ajana incelettirilir
metadata:
  type: feedback
---

Her iş ya da faz başlamadan Erdem'e adım tablosu verilir: Adım | Ne | Kim (ana / hangi alt ajan) | Model | Düşünme (low/medium/high) |
Süre | Neden; onayı beklenir. Plan Erdem'e gitmeden önce güçlü bir ajan (Opus) tarafından incelenir, eksikler işlenir.
- En ucuz yeterli model: okuma/döküm/komut koşturma Haiku; yorum gerektiren okuma ve araştırma Sonnet; Opus yalnız çözüm
  tasarımı, ödünleşim ve kıdemli kod incelemesinde. Basit iş için Opus yok.
- Kodu Sonnet yazar, düşünme xhigh ya da max. Commit'ten önce Opus 5.5 kodu kıdemli geliştirici gözüyle inceler; hatalı ya da
  daha iyi yazılabilir yeri kendisi düzeltebilir; onay verirse commit. Push yalnız Erdem'in sözüyle.
- Alt ajan ve iş akışı kullanımında kısıt yok, yeter ki model seçimi doğru olsun.
- Eski PRD'ler çöpe atılmaz: Erdem "yetersiz" dediğinde iyi parçaları yeniden kullanılır.

**Why:** iki $200 hesap bir hafta sonunda bitti; Erdem hem maliyeti hem kaliteyi aynı anda istiyor.
**How to apply:** her yeni fazda önce tabloyu yaz, güçlü ajana incelet, ExitPlanMode/onay bekle; ajan çağrılarında model ve
effort'u tabloya göre açıkça ver. Bkz. [[feedback-subagent-token-budget]].

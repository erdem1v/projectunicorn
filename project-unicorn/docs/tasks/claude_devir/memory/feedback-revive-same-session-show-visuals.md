---
name: feedback-revive-same-session-show-visuals
description: Erdem 2026-10-20 — kesilen oturum AYNI kimlikle açılır (claude -r <id> --remote-control), yeni oturum değil; bitmiş maket/kare MD değil görsel sunulur; öneriler toplu kabul edilmez, kararı Erdem verir
metadata:
  type: feedback
---

Erdem 2026-10-20 (bilgisayar kapandıktan sonra Q/C/D'yi toparlarken), sert tepkiyle:
- Kesilen oturumu kurtarırken yeni oturum açılmaz. Desktop'tan açılan "devam" yeni bir oturum yarattı (C için 7c80f6a9 = desktop-9a, 7a140906 değil), token yedi, uzaktan "bilgisayara erişilemiyor" dedi. Doğru yol terminalde `claude -r <id> --remote-control "<ad>"`: `--resume` varsayılan olarak AYNI kimliği sürdürür (`--fork-session` yoksa), `--remote-control` claude.ai/telefondan aynı sohbeti açar. Yerel süreç kapalıyken uzaktan erişim olmaz.
- Biten hazırlık (maket kareleri, PNG) MD dosyası olarak değil, görsel olarak önüne konur (SendUserFile / sayfa). "MD mi okuyacağım."
- "Önerilerin hiçbirini kabul etmiyorum, ben belirleyeceğim": karar sorularını toplu öneriyle kapatmayı teklif etme; kararları o verir.
- Ama soruları TEK TEK sorma ("tokenlerimi hiç ediyorsun"): hepsini tek mesajda, numaralı ve harfli seçenekle getir, o tek mesajla cevaplar; araştırma isteyen konular ve verilen kararlar ilgili ajanlara iletilir, iş sürer.
- Paralel fazlar ve plan içi "Erdem durakları" yalnız hazırlık + karar sayfası üretti, haftalık limitin %80'i gitti → üretim (kod) göstermeyen çalışma biçimi kabul edilemez.

**How to apply:** kurtarma için önce kimliği bul, aynı kimlikle resume komutunu ver; teslimde görseli önce göster; karar listesini öneriyle değil, Erdem'in cevaplayacağı biçimde getir. İlgili: [[lost-session-recovery]] · [[codirector-session-2026-10-07]]

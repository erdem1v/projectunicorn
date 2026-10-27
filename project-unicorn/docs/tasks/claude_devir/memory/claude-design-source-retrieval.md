---
name: claude-design-source-retrieval
description: "Claude Design projesindeki JS/HTML kaynak dosyalarını diske BYTE-GÜVENLİ almanın yolu (DesignSync + Chrome \"Copy\" düğmesi + Get-Clipboard)"
metadata:
  node_type: memory
  type: reference
  originSessionId: 95590330-4142-478e-87ee-77a5ab3838d0
  modified: 2026-09-27T13:39:17.697Z
---

**Sorun:** `DesignSync get_file` içeriği JSON olarak döndürür; ~60 KB üstü çıktılar `tool-results/<id>.txt`'e kalıcı yazılır (python `json.load` → `content` ile birebir dosya), ama küçük dosyalar bağlama satır içi gelir ve elle yazmak çalışır kod için güvenilmez.

**Çözüm (2026-09-27'de 6 dosya için işledi):**
1. `/design-login` sonrası `DesignSync list_files/get_file` ile envanter.
2. Chrome (claude-in-chrome): `https://claude.ai/design/p/<proje-id>?file=<dosya>` → sayfa başlığındaki **"Copy"** düğmesi (find: "Copy button in the file header toolbar") dosyanın TAMAMINI panoya koyar.
3. PowerShell: `Get-Clipboard -Raw` → CRLF gelir; `-replace "`r`n","`n"` ile LF'e çevir, `[IO.File]::WriteAllText(path, t, UTF8Encoding($false))` (BOM'suz). İlk satırı doğrula (dosya başlığı yorumu), `node --check` ile söz dizimi.
4. Tek response'ta `browser_batch[navigate, wait 3, find]` → sonra `click ref` → sonra kaydet; tık ile pano okuma aynı response'a konmaz (sıra garantisi yok).

Not: `support.js` Claude Design'ın kendi çalışma zamanıdır (dc-runtime), tasarım mantığı değildir; kopyalanmaz.

İlgili: [[office-3d-task-2026-09-27]] · [[ekip-rev11-closing-round]]

---
name: lost-session-recovery
description: "Kapanan/kesilen oturumu kaldığı yerden sürdürme — transkript nerede, köprü kimliği eşlemesi, workflow journal'ı, aynı-oturum resume sınırı, ağacın gated export'la eşliğini kanıtlama"
metadata:
  node_type: memory
  type: reference
  originSessionId: 64845f34-c90d-4622-b2d5-298a20db453f
  modified: 2026-10-12T03:13:27.756Z
---

Elektrik kesintisi 2026-10-04'te kullanılan yol (Erdem claude.ai/code/session_<id> linkini verdi):

- **Oturum bulma:** `~/.claude/projects/C--Users-erdem-Desktop-project-steam/<uuid>.jsonl`; linkteki `session_<X>`
  dosyada `bridge-session` satırında `bridgeSessionId: cse_<X>` olarak geçer → `grep -l <X> *.jsonl`.
- **Son durum:** ana döngü genelde bir Workflow başlatıp bekliyordur; gerçek iş
  `<uuid>/subagents/workflows/wf_*/journal.jsonl` (started/result satırları) ve `agent-*.jsonl` kayıtlarında.
  Düşünce metni kaydedilmez — gözlemler yalnız araç çağrısı/sonuçlarından çıkar.
- **Resume yalnız aynı oturumda:** `resumeFromRunId` yeni oturumda çalışmaz → eski betiği tool_use girdisinden çıkar,
  biten adımların sonucunu journal'dan al, devam betiğini elle yaz (yarım ajan için "devral" istemi + özet dosyası).
- **Ağaç eşliği kanıtı:** ajanın özel indeksine `GIT_INDEX_FILE=<o index> git write-tree` ile çalışma ağacından kurulan
  yeni indeksin `write-tree`'si aynıysa hiçbir şey kaybolmamıştır.
- Eski oturumun scratchpad'i (`%TEMP%/claude/<proj>/<uuid>/scratchpad`) yeniden başlatmadan sağ çıkar; yardımcı betikler
  oradan kullanılabilir.
- Commit trailer'ı yeni oturumun Claude-Session satırıyla yazılır (taslaktaki eskisi değiştirilir).
- 2026-10-05'te aynı oturum (64845f34) ikinci kez kesildi; aynı yol işledi. Uygulayıcı kod ortasında kesildiyse
  özet için `scratchpad/digest.py <agent.jsonl>` (Bash komutu + açıklama, Edit eski/yeni, Write yalnız yol) yeterli;
  ajanın anlatı metni kısa olduğundan asıl kayıt diff'tir. Kaydedilmiş betik `<proje>-project-unicorn/<uuid>/workflows/
  scripts/` altında olabilir (cwd alt klasördeyse proje dizini farklı adla açılır).

- 2026-10-10 dersi: "Compacted while idle" özeti son mesajın teslim edilmediğini İDDİA EDEBİLİR (analiz aslında
  compact_boundary'den 55 dk önce teslim edilmişti). Özete güvenme; sınırdan önceki son ASSIST satırını oku. Bu oturumun
  scratchpad'inde `digest.py <jsonl> users|tail|tools|assist|all [maxlen]` satır numaralı döküm verir; `awk -F'[][]'`
  ile satır aralığı süzülür.

- 2026-10-12: temiz kapanmış oturumu açmak için başka oturumdan PowerShell `Start-Process claude.exe -ArgumentList
  '--resume','<uuid>' -WorkingDirectory <proje kökü>` ayrı konsol penceresi açar. `~/.claude/sessions/<pid>.json` pid →
  sessionId + peer adı eşlemesini verir (`--resume` süreci json'u geç yazar). Aynı uuid'i iki süreçte açma.

İlgili: [[ui-redesign-menajer-2026-10-02]] · [[concurrent-session-hazard]] · [[partial-staging-shared-tree]]

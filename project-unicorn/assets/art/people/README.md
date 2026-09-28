# Ofis insanları varlıkları

Ofisteki kişilerin gövdeleri, kıyafetleri ve klipleri. Kaynak dosyalar değiştirilmez; oyunun okuduğu
gövdeler `tools/people/fix_rig.py` ile ham dosyalardan yeniden üretilir, içe aktarma ayarlarını
`tools/people/setup_import.gd` yazar (yeniden üretim: `tools/people/README.md`).

## `raw/q22/` (Godot okumaz, `.gdignore`)

Quaternius "Ultimate Modular Men" (Şubat 2022) ve "Ultimate Modular Women" (Nisan 2022) paketlerinin
`Individual Characters/glTF/` dosyaları, olduğu gibi, yalnız adları değişti. Her dosyadan yalnız
ofise uyan parçalar okunur (`PeopleParts.SURFACES`); uzay giysisi, SWAT, ortaçağ gibi baştan sona
kostüm olan karakterler alınmadı. Paketler quaternius.com'dan 2026-09-28'de indirildi; lisans CC0 1.0
(paketlerdeki `License.txt`, `LICENSES/`'da).

| Dosya | Paket | Kaynak dosya | sha256 |
|---|---|---|---|
| `m_suit.gltf` | Men | `Suit.gltf` | 6c89fbb31b96c1a63ad94e3dee0942bd7b34bc789a5d39fd6a6a1738a9214fb3 |
| `m_casual.gltf` | Men | `Casual_2.gltf` | 55c654d09a2a5ff6e3bd6158d4a1b462f181cd6f1e12a0f5e9d959f9c3abc438 |
| `m_hoodie.gltf` | Men | `Casual_Hoodie.gltf` | dd74886c26998a0fa888b4ce557a0932d7d97b0265dd4c763154d081b7a6cb98 |
| `m_beach.gltf` | Men | `Beach.gltf` | 76e001ea131fd76a1bd938a7862606cb8037f7049b632783580b9bf4da2371a8 |
| `m_punk.gltf` | Men | `Punk.gltf` | f9224072f5e6cbb207eca250faa7f1868614a1a984074fe79c7b2862df4feb42 |
| `m_adventurer.gltf` | Men | `Adventurer.gltf` | 21f7a61afb6bd6cef6961490c367594e3c2fc01ec1f041662131172ce763063e |
| `m_king.gltf` | Men | `King.gltf` | 659c7d84dcea8c6331698c3430484861944c83e629389425664b782d4aecd17c |
| `m_worker.gltf` | Men | `Worker.gltf` | e49f8ec0f8a7de72dd26b1c01e6413c9a87a9116eeee21f9364ccd36bc286335 |
| `w_suit.gltf` | Women | `Suit.gltf` | 937d5c8d08fb5570f6a4e1dd79a3878335444d175aae3b0e9e2babdac36a17f7 |
| `w_casual.gltf` | Women | `Casual.gltf` | b0fe6e92219cd71808844a20a1a8b960fd1cf640a6546dc6362b5add6604e87c |
| `w_formal.gltf` | Women | `Formal.gltf` | fdfcf454c4de037d31973eb28d8591bd7763035d49f46b380e63b1c832dc7ddf |
| `w_adventurer.gltf` | Women | `Adventurer.gltf` | 65094211e53b49f6a834c617cc056834686fe794a0b515a6b97faa3e1130cc95 |
| `w_soldier.gltf` | Women | `Soldier.gltf` | 37112e60af92ff84d882a34e21f0f78a2afc14282e950fb0e3652e51d06e0b2d |
| `w_worker.gltf` | Women | `Worker.gltf` | e2bfc1039f429e870a0119e274c2dd45f6304f00c39f4570dfeb9ed4d97a063d |
| `m_farmer.gltf` | Men | `Farmer.gltf` | 46d3e85fa8d848ee479ab8e4672c16724ee4ea51f3af5733705a153937f93555 |
| `w_punk.gltf` | Women | `Punk.gltf` | 61cc7f85a8e9b700cdb92ae8ebd6e3bdd1e8a510b57027f6c7d8c2b6ff3b0e0f |
| `w_scifi.gltf` | Women | `SciFi.gltf` | 86bcb11a1bc18c744a23abe5e7bd4cc95e636ba1f405cecdbd5a0e2f7214b802 |
| `w_witch.gltf` | Women | `Witch.gltf` | d886c8c134a92b2013529edf7352e286ef386ca7c0f5fa3a568039d7c11b05fe |

## `q22/`

`raw/q22/`'nin düzeltilmiş hâli (`fix_rig.py`): metre, Y yukarı, kemik rest'i bind (T-pozu),
`Foot.L/R` baldırın altında; yalnız dört kıyafet parçası, karakterin kendi klipleri ve düz renklerin
UV'leri atılmış. İçe aktarma
iskeleti `%GeneralSkeleton` (SkeletonProfileHumanoid adları) olarak retarget eder.

## `anims/`

| Dosya | Kaynak | Sürüm, tarih | sha256 |
|---|---|---|---|
| `ual1.glb` | Quaternius Universal Animation Library, Standard (`Unreal-Godot/UAL1_Standard_RM.glb`), itch.io | 2026-09-28 | be684571ed655a1b892c2c07e6e2aeca053b606c442d34004adaf1d944090d01 |
| `ual2.glb` | Quaternius Universal Animation Library 2, Standard (`Unreal-Godot/UAL2_Standard_RM.glb`), itch.io | 2026-09-28 | 814eee878f82934992d3ea746c539df25e981487109c591f5efbb8dd03286f99 |
| `m2m_addon.glb` | Mesh2Motion (`static/animations/human-addon-animations.glb`), GitHub `faaebc8` | 2026-09-28 | a0d64d555e0d492026b72d58bf8e16c5e86779295f9093e376dcc001915c2c95 |

Her paket içe aktarımda kendi `AnimationLibrary`'si olur (klip adlarındaki `_Loop` eki düşer).
Mesh2Motion'ın `CarnegieMellonAnimations/` klasörü CC0 değildir, alınmadı.

## `LICENSES/`

Paketlerle gelen lisans metinleri; hepsi CC0 1.0 (Quaternius Ultimate Modular Men ve Women, UAL1,
UAL2, Mesh2Motion). Atıf gerekmez.

# Faz Q · kapanış hız kıyası (MRR bin $ 26/52/104. hf, A = Series A Avı'na giriş haftası, son)
Q0b = eski kod tabanı; bd9a5ed = K9b (CORE_2 1,5); son = 910ad1f (K9c, CORE_2 1,25). Betik scratchpad/k9_speed.py.

```
fix_none                7 | Q0b: 38/72/175k A=80 running_on_fumes@104 | bd9a5ed: 16/38/115k A=yok running_on_fumes@104 | son: 16/60/147k A=91 running_on_fumes@104
fix_none               11 | Q0b: 41/63/154k A=83 running_on_fumes@104 | bd9a5ed: 28/59/132k A=95 running_on_fumes@104 | son: 28/66/147k A=89 running_on_fumes@104
fix_worst               7 | Q0b: 42/96/190k A=66 running_on_fumes@104 | bd9a5ed: 19/51/117k A=yok running_on_fumes@104 | son: 19/62/147k A=88 running_on_fumes@104
fix_worst              11 | Q0b: 43/98/201k A=65 running_on_fumes@104 | bd9a5ed: 27/63/133k A=94 running_on_fumes@104 | son: 27/65/131k A=96 running_on_fumes@104
fix_due                 7 | Q0b: 43/98/185k A=64 running_on_fumes@104 | bd9a5ed: 19/49/130k A=99 running_on_fumes@104 | son: 19/52/114k A=yok running_on_fumes@104
fix_due                11 | Q0b: 47/110/223k A=57 running_on_fumes@104 | bd9a5ed: 28/62/135k A=97 running_on_fumes@104 | son: 28/62/134k A=98 running_on_fumes@104
fix_off                 7 | Q0b: 45/98/193k A=65 running_on_fumes@104 | bd9a5ed: 19/53/111k A=yok running_on_fumes@104 | son: 19/62/147k A=88 running_on_fumes@104
fix_off                11 | Q0b: 44/98/200k A=65 running_on_fumes@104 | bd9a5ed: 27/63/133k A=94 running_on_fumes@104 | son: 27/65/131k A=96 running_on_fumes@104
fix_worst_desk          7 | Q0b: - | bd9a5ed: 19/90/400k A=62 running_on_fumes@104 | son: 19/112/424k A=56 running_on_fumes@104
fix_worst_desk         11 | Q0b: - | bd9a5ed: 30/125/427k A=52 running_on_fumes@104 | son: 30/139/439k A=50 running_on_fumes@104
quality_core            7 | Q0b: - | bd9a5ed: 15/22/67k A=yok running_on_fumes@104 | son: 15/29/87k A=yok running_on_fumes@104
quality_core           11 | Q0b: - | bd9a5ed: 12/27/95k A=yok running_on_fumes@104 | son: 13/36/83k A=yok running_on_fumes@104
quality_core_desk       7 | Q0b: - | bd9a5ed: 15/37/114k A=yok running_on_fumes@104 | son: 15/46/109k A=yok running_on_fumes@104
quality_core_desk      11 | Q0b: - | bd9a5ed: 12/25/37k A=yok running_on_fumes@104 | son: 13/23/33k A=yok running_on_fumes@104
vc_cautious             7 | Q0b: 44/102/129k A=64 series_a_close@67 | bd9a5ed: 17/57/130k A=86 series_a_close@89 | son: 17/59/128k A=89 series_a_close@92
vc_cautious            11 | Q0b: 43/105/129k A=61 series_a_close@64 | bd9a5ed: 29/61/114k A=yok running_on_fumes@104 | son: 29/62/125k A=98 series_a_close@101
vc_product              7 | Q0b: - | bd9a5ed: 17/57/130k A=86 series_a_close@89 | son: 17/59/128k A=89 series_a_close@92
vc_product             11 | Q0b: - | bd9a5ed: 29/61/114k A=yok running_on_fumes@104 | son: 29/62/127k A=98 series_a_close@101
b2c_fix_none            7 | Q0b: 6/37/63k A=yok running_on_fumes@104 | bd9a5ed: 6/42/456k A=76 running_on_fumes@104 | son: 6/45/137k A=75 running_on_fumes@104
b2c_fix_none           11 | Q0b: 5/38/219k A=73 running_on_fumes@104 | bd9a5ed: 5/52/337k A=65 running_on_fumes@104 | son: 5/53/265k A=68 running_on_fumes@104
b2c_fix_worst           7 | Q0b: 4/27/1040k A=75 running_on_fumes@104 | bd9a5ed: 4/41/1428k A=67 running_on_fumes@104 | son: 4/43/1372k A=67 running_on_fumes@104
b2c_fix_worst          11 | Q0b: 3/29/625k A=77 running_on_fumes@104 | bd9a5ed: 5/45/1055k A=69 running_on_fumes@104 | son: 5/50/1287k A=65 running_on_fumes@104
b2c_fix_due             7 | Q0b: 3/25/741k A=79 running_on_fumes@104 | bd9a5ed: 4/40/1511k A=69 running_on_fumes@104 | son: 4/44/1545k A=67 running_on_fumes@104
b2c_fix_due            11 | Q0b: 3/27/949k A=77 running_on_fumes@104 | bd9a5ed: 4/46/1348k A=67 running_on_fumes@104 | son: 4/51/1324k A=65 running_on_fumes@104
b2c_fix_off             7 | Q0b: 4/28/1308k A=74 running_on_fumes@104 | bd9a5ed: 4/47/1877k A=65 running_on_fumes@104 | son: 4/47/1995k A=65 running_on_fumes@104
b2c_fix_off            11 | Q0b: 3/29/964k A=76 running_on_fumes@104 | bd9a5ed: 5/47/1946k A=65 running_on_fumes@104 | son: 5/52/2105k A=64 running_on_fumes@104
b2c_vc_cautious         7 | Q0b: 3/21/197k A=81 series_a_close@84 | bd9a5ed: 3/37/184k A=72 series_a_close@75 | son: 3/42/203k A=68 series_a_close@71
b2c_vc_cautious        11 | Q0b: 3/22/193k A=79 series_a_close@82 | bd9a5ed: 3/37/195k A=74 series_a_close@77 | son: 3/41/180k A=70 series_a_close@73
b2c_vc_product          7 | Q0b: - | bd9a5ed: 3/40/140k A=71 series_a_close@72 | son: 3/42/154k A=68 series_a_close@69
b2c_vc_product         11 | Q0b: - | bd9a5ed: 3/37/195k A=74 series_a_close@77 | son: 3/41/180k A=70 series_a_close@73
```

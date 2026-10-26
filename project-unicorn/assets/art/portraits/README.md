# Portreler

Frank'in ve on bir kurucunun önceden render edilmiş portreleri: ofisin 3B karakterleri, büst stüdyosunda
(`PersonBust`), ışıklı portre zemininde. Görünüşler `LookSystem.FRANK_LOOK` ve `LookSystem.FOUNDER_LOOKS`.
Kurucunun `<id>.png`'si 4:5 ana görüntüdür (260×325 için kesilir); `<id>_<boy>.png` daha küçük yerler için
kırpımdır, adındaki boy kesildiği mantıksal boydur ve yerler onu yakın bir boyda gösterir. Frank'in ana görüntüsü
yoktur: maillerinin portre kuyusu (256×320) ve diskleri vardır. Dosya mantıksal boyun iki katıdır ve çizimde
doğrusal süzgeçle iner (mipmap yok). Kare kırpımlar
daireye kesilmiş disklerdir, kenarları düz (premultiply edilmemiş) alfadır; kartlar opaktır.

Bu dosyayı ve görüntüleri `tools/people/bake_portraits.gd` yazar (`project-unicorn/`'dan, pencereli, tek Godot):

    "$GODOT" --path . -s res://tools/people/bake_portraits.gd
    "$GODOT" --headless --path . --import

Gövdeler Quaternius Ultimate Modular Men/Women 2022, poz Universal Animation Library'dendir: CC0 1.0
(`../people/LICENSES/`), atıf gerekmez.

| Dosya | Piksel | Görünüş imzası | Araç | sha256 |
|---|---|---|---|---|
| `frank_256x320.png` | 512×640 | `body=m_suit\|bottom=-1\|feet=m_suit\|girth=2\|glasses=false\|hair=7\|head=m_king\|height=3\|legs=m_suit\|sex=m\|shoe=1\|skin=2\|tie=0\|top=2\|top2=0` | `tools/people/bake_portraits.gd` | `066a94906a1d6f57bae1f02065912ada32665ea4e10ea85e682c9991b73dfc63` |
| `frank_24.png` | 48×48 | `body=m_suit\|bottom=-1\|feet=m_suit\|girth=2\|glasses=false\|hair=7\|head=m_king\|height=3\|legs=m_suit\|sex=m\|shoe=1\|skin=2\|tie=0\|top=2\|top2=0` | `tools/people/bake_portraits.gd` | `ebc6125f61029a60a7fbf44e978ff3d17b74b7704a30301e10a03ca551ebc7e9` |
| `frank_32.png` | 64×64 | `body=m_suit\|bottom=-1\|feet=m_suit\|girth=2\|glasses=false\|hair=7\|head=m_king\|height=3\|legs=m_suit\|sex=m\|shoe=1\|skin=2\|tie=0\|top=2\|top2=0` | `tools/people/bake_portraits.gd` | `bac70938de5a3c30020662370e0ecb045a7a50976fe00f1898e974da540bb427` |
| `frank_40.png` | 80×80 | `body=m_suit\|bottom=-1\|feet=m_suit\|girth=2\|glasses=false\|hair=7\|head=m_king\|height=3\|legs=m_suit\|sex=m\|shoe=1\|skin=2\|tie=0\|top=2\|top2=0` | `tools/people/bake_portraits.gd` | `f11db3fe0d0125be94c78d86056da5296ae09efeee1f635728b78e00642e1593` |
| `frank_48.png` | 96×96 | `body=m_suit\|bottom=-1\|feet=m_suit\|girth=2\|glasses=false\|hair=7\|head=m_king\|height=3\|legs=m_suit\|sex=m\|shoe=1\|skin=2\|tie=0\|top=2\|top2=0` | `tools/people/bake_portraits.gd` | `6781130ad0a53556211a10b1718815eb0f7ef6b90b2773f04a120de96630f15f` |
| `founder_01.png` | 520×650 | `body=w_casual\|bottom=2\|feet=w_casual\|girth=1\|glasses=false\|hair=1\|head=w_scifi\|height=2\|legs=w_casual\|sex=w\|shoe=1\|skin=4\|tie=0\|top=3\|top2=3` | `tools/people/bake_portraits.gd` | `27b8a83a50d1ed547404b0d9fc940a6b4675104533409c06f92ab86300c44340` |
| `founder_01_132x165.png` | 264×330 | `body=w_casual\|bottom=2\|feet=w_casual\|girth=1\|glasses=false\|hair=1\|head=w_scifi\|height=2\|legs=w_casual\|sex=w\|shoe=1\|skin=4\|tie=0\|top=3\|top2=3` | `tools/people/bake_portraits.gd` | `808f0eaeb1ad1d4e0e67e23f1133663256c03e96de4af8d804bf714a31866f83` |
| `founder_02.png` | 520×650 | `body=m_suit\|bottom=-1\|feet=m_suit\|girth=1\|glasses=false\|hair=0\|head=m_adventurer\|height=3\|legs=m_suit\|sex=m\|shoe=1\|skin=5\|tie=-1\|top=2\|top2=0` | `tools/people/bake_portraits.gd` | `358613e059e7e4b32c30e9ed1400de7ff69f1cd6229f313b4d5bb9daa01e8915` |
| `founder_02_132x165.png` | 264×330 | `body=m_suit\|bottom=-1\|feet=m_suit\|girth=1\|glasses=false\|hair=0\|head=m_adventurer\|height=3\|legs=m_suit\|sex=m\|shoe=1\|skin=5\|tie=-1\|top=2\|top2=0` | `tools/people/bake_portraits.gd` | `a8523839c3df8c4ad9ec205a6d3037c6503afafca62b4e3972e57508a7099086` |
| `founder_03.png` | 520×650 | `body=w_suit\|bottom=-1\|feet=w_suit\|girth=1\|glasses=false\|hair=4\|head=w_witch\|height=2\|legs=w_suit\|sex=w\|shoe=1\|skin=1\|tie=0\|top=2\|top2=3` | `tools/people/bake_portraits.gd` | `a4711b02ea3e66a8753634673a2054ac818a3ff30a20b4b1b4703afa345d3de2` |
| `founder_03_132x165.png` | 264×330 | `body=w_suit\|bottom=-1\|feet=w_suit\|girth=1\|glasses=false\|hair=4\|head=w_witch\|height=2\|legs=w_suit\|sex=w\|shoe=1\|skin=1\|tie=0\|top=2\|top2=3` | `tools/people/bake_portraits.gd` | `47706a9e84ab9e8dc43e082c3264980659f1112b9841413ef883894eec972d3f` |
| `founder_04.png` | 520×650 | `body=m_adventurer\|bottom=1\|feet=m_casual\|girth=1\|glasses=false\|hair=3\|head=m_casual\|height=2\|legs=m_casual\|sex=m\|shoe=0\|skin=0\|tie=0\|top=4\|top2=3` | `tools/people/bake_portraits.gd` | `0cbffeb17710f62e1166d1264bdbd56074eeb6682547b4b531960f8f5ab21e32` |
| `founder_04_132x165.png` | 264×330 | `body=m_adventurer\|bottom=1\|feet=m_casual\|girth=1\|glasses=false\|hair=3\|head=m_casual\|height=2\|legs=m_casual\|sex=m\|shoe=0\|skin=0\|tie=0\|top=4\|top2=3` | `tools/people/bake_portraits.gd` | `9505a34b1845ff005d1368e1387d1b1c6fadbec57f1c0854fa50b24e5c298e0d` |
| `founder_05.png` | 520×650 | `body=w_casual\|bottom=2\|feet=w_casual\|girth=0\|glasses=false\|hair=0\|head=w_suit\|height=1\|legs=w_casual\|sex=w\|shoe=1\|skin=0\|tie=0\|top=3\|top2=3` | `tools/people/bake_portraits.gd` | `c33f3f67bfa400d5c7463f39b4be959813c25f3bb997a26e04ef933f40539eea` |
| `founder_05_132x165.png` | 264×330 | `body=w_casual\|bottom=2\|feet=w_casual\|girth=0\|glasses=false\|hair=0\|head=w_suit\|height=1\|legs=w_casual\|sex=w\|shoe=1\|skin=0\|tie=0\|top=3\|top2=3` | `tools/people/bake_portraits.gd` | `ededa7aef70fa970c4dbfae1e461fa76a366bc2fb79d2fc2edc780a50c998120` |
| `founder_06.png` | 520×650 | `body=m_adventurer\|bottom=1\|feet=m_casual\|girth=1\|glasses=true\|hair=0\|head=m_casual\|height=2\|legs=m_casual\|sex=m\|shoe=3\|skin=1\|tie=0\|top=1\|top2=0` | `tools/people/bake_portraits.gd` | `e41965afa0d608ad06be84bf78b44c635bc09b1d259a9f7144a1c5e010e91780` |
| `founder_06_132x165.png` | 264×330 | `body=m_adventurer\|bottom=1\|feet=m_casual\|girth=1\|glasses=true\|hair=0\|head=m_casual\|height=2\|legs=m_casual\|sex=m\|shoe=3\|skin=1\|tie=0\|top=1\|top2=0` | `tools/people/bake_portraits.gd` | `c2eda9a86c501516d851080883376c35ef16b583292c4ac0863e87750c392456` |
| `founder_07.png` | 520×650 | `body=w_casual\|bottom=1\|feet=w_casual\|girth=1\|glasses=false\|hair=0\|head=w_suit\|height=2\|legs=w_casual\|sex=w\|shoe=3\|skin=3\|tie=0\|top=1\|top2=1` | `tools/people/bake_portraits.gd` | `a74bba2ec949049d20b75da2eac668c28149c9bdd0776ddff965c0ed14774373` |
| `founder_07_132x165.png` | 264×330 | `body=w_casual\|bottom=1\|feet=w_casual\|girth=1\|glasses=false\|hair=0\|head=w_suit\|height=2\|legs=w_casual\|sex=w\|shoe=3\|skin=3\|tie=0\|top=1\|top2=1` | `tools/people/bake_portraits.gd` | `1677006fa84e45ed72d61b0db04a4b5e86dc7337aa6063278b38a031a99d07d0` |
| `founder_08.png` | 520×650 | `body=m_adventurer\|bottom=2\|feet=m_casual\|girth=1\|glasses=false\|hair=0\|head=m_hoodie\|height=2\|legs=m_casual\|sex=m\|shoe=0\|skin=2\|tie=0\|top=3\|top2=0` | `tools/people/bake_portraits.gd` | `c8c3b444cdfd48d90e7238589b35ebbbdbf5462722a8d2a196dfcb888dfa71b5` |
| `founder_08_132x165.png` | 264×330 | `body=m_adventurer\|bottom=2\|feet=m_casual\|girth=1\|glasses=false\|hair=0\|head=m_hoodie\|height=2\|legs=m_casual\|sex=m\|shoe=0\|skin=2\|tie=0\|top=3\|top2=0` | `tools/people/bake_portraits.gd` | `565191c623d0bd451da465a9665fdb23e52beb3ff72ce4804203a6b496492a04` |
| `founder_09.png` | 520×650 | `body=w_suit\|bottom=-1\|feet=w_suit\|girth=2\|glasses=false\|hair=7\|head=w_adventurer\|height=1\|legs=w_suit\|sex=w\|shoe=1\|skin=5\|tie=0\|top=0\|top2=3` | `tools/people/bake_portraits.gd` | `1e67bfcc3035b2df6507b2f3309a9f7c3b9685baada37bb7247755e8733bb08a` |
| `founder_09_132x165.png` | 264×330 | `body=w_suit\|bottom=-1\|feet=w_suit\|girth=2\|glasses=false\|hair=7\|head=w_adventurer\|height=1\|legs=w_suit\|sex=w\|shoe=1\|skin=5\|tie=0\|top=0\|top2=3` | `tools/people/bake_portraits.gd` | `2345f758309166e9eb5dfbedc5b3860b9745746835645484baebf3ddc2d40722` |
| `founder_10.png` | 520×650 | `body=w_suit\|bottom=3\|feet=w_suit\|girth=1\|glasses=false\|hair=0\|head=w_suit\|height=2\|legs=w_suit\|sex=w\|shoe=1\|skin=1\|tie=0\|top=7\|top2=5` | `tools/people/bake_portraits.gd` | `5810ca66a037d55e8dc862ca7b900544c25b5a47ff4b1a9702067fbe045b742f` |
| `founder_10_132x165.png` | 264×330 | `body=w_suit\|bottom=3\|feet=w_suit\|girth=1\|glasses=false\|hair=0\|head=w_suit\|height=2\|legs=w_suit\|sex=w\|shoe=1\|skin=1\|tie=0\|top=7\|top2=5` | `tools/people/bake_portraits.gd` | `32ff16ef38b69738f6ba071967308bef680e09e0200ae9416db579e3e1747adb` |
| `founder_11.png` | 520×650 | `body=w_suit\|bottom=-1\|feet=w_suit\|girth=1\|glasses=false\|hair=1\|head=w_formal\|height=2\|legs=w_suit\|sex=w\|shoe=2\|skin=3\|tie=0\|top=4\|top2=3` | `tools/people/bake_portraits.gd` | `76fc406bf58b619c3fd36ba8f1b615c14165f38c4bbfa48b0736b1d992411c4a` |
| `founder_11_132x165.png` | 264×330 | `body=w_suit\|bottom=-1\|feet=w_suit\|girth=1\|glasses=false\|hair=1\|head=w_formal\|height=2\|legs=w_suit\|sex=w\|shoe=2\|skin=3\|tie=0\|top=4\|top2=3` | `tools/people/bake_portraits.gd` | `3afdb59299f679b185cf6975b7e8db36d78f2adf6a77aceb2e21607af04b3f06` |

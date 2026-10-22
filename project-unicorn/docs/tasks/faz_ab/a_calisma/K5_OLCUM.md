
== bilgi: fix_worst açýk hata (geç dönem, sprint sonu ve sürüm aný medyaný) ==
b2b  sprint sonu 10.0 (n=141), sürüm aný 7.0 (n=143)
b2c  sprint sonu 17.0 (n=123), sürüm aný 13.0 (n=125)

== koþular ==
b2b  due    tohum 7  bitiþ 104 v1.0 7 hata satýrý 0
b2b  due    tohum 11 bitiþ 104 v1.0 7 hata satýrý 0
b2b  none   tohum 7  bitiþ 104 v1.0 7 hata satýrý 0
b2b  none   tohum 11 bitiþ 104 v1.0 7 hata satýrý 0
b2b  off    tohum 7  bitiþ 104 v1.0 7 hata satýrý 0
b2b  off    tohum 11 bitiþ 104 v1.0 7 hata satýrý 0
b2b  worst  tohum 7  bitiþ 104 v1.0 7 hata satýrý 0
b2b  worst  tohum 11 bitiþ 104 v1.0 7 hata satýrý 0
b2c  due    tohum 7  bitiþ 104 v1.0 7 hata satýrý 0
b2c  due    tohum 11 bitiþ 104 v1.0 7 hata satýrý 0
b2c  none   tohum 7  bitiþ 104 v1.0 7 hata satýrý 0
b2c  none   tohum 11 bitiþ 104 v1.0 7 hata satýrý 0
b2c  off    tohum 7  bitiþ 104 v1.0 7 hata satýrý 0
b2c  off    tohum 11 bitiþ 104 v1.0 7 hata satýrý 0
b2c  worst  tohum 7  bitiþ 104 v1.0 7 hata satýrý 0
b2c  worst  tohum 11 bitiþ 104 v1.0 7 hata satýrý 0

== (a) haftada yeni hata ==
pazar dönem  kol    | tohum 7  med/ort/n  tohum 11 med/ort/n
b2b  early  none   | 2.0/2.8/20          2.5/2.9/20        
b2b  early  worst  | 1.0/2.4/20          1.0/2.4/20        
b2b  early  due    | 1.0/2.8/20          1.0/2.4/20        
b2b  early  off    | 1.0/2.5/20          1.0/2.4/20        
b2b  late   none   | 4.0/3.7/77          3.0/3.5/77        
b2b  late   worst  | 3.0/2.9/77          3.0/2.9/77        
b2b  late   due    | 3.0/3.0/77          3.0/3.0/77        
b2b  late   off    | 3.0/2.9/77          3.0/2.9/77        
b2c  early  none   | 1.0/1.4/20          1.0/1.4/20        
b2c  early  worst  | 1.0/1.1/20          1.0/1.1/20        
b2c  early  due    | 1.0/1.1/20          1.0/1.1/20        
b2c  early  off    | 1.0/1.1/20          1.0/1.1/20        
b2c  late   none   | 3.0/3.5/77          3.0/3.5/77        
b2c  late   worst  | 3.0/4.7/77          3.0/4.5/77        
b2c  late   due    | 3.0/5.4/77          3.0/5.2/77        
b2c  late   off    | 3.0/5.3/77          3.0/4.9/77        

== (b1) açýk hata, sprint sonunda (kapanýþtan hemen önce) ==
pazar dönem  kol    | tohum 7  med/ort/n  tohum 11 med/ort/n
b2b  early  none   | 25.0/22.9/12        26.0/25.2/13      
b2b  early  worst  | 17.5/15.0/12        15.0/13.2/12      
b2b  early  due    | 5.0/8.8/11          3.5/7.6/12        
b2b  early  off    | 18.0/14.9/11        18.0/13.5/11      
b2b  late   none   | 189.0/196.4/71      190.0/193.3/71    
b2b  late   worst  | 11.0/11.3/71        10.0/10.7/70      
b2b  late   due    | 8.0/8.6/71          7.0/7.6/71        
b2b  late   off    | 12.0/11.8/71        9.0/10.8/72       
b2c  early  none   | 12.0/12.6/11        15.0/14.5/13      
b2c  early  worst  | 4.5/4.8/12          5.0/5.5/13        
b2c  early  due    | 5.0/5.0/11          4.0/4.1/12        
b2c  early  off    | 4.5/4.8/12          5.0/5.5/13        
b2c  late   none   | 49.0/57.8/68        49.0/61.1/65      
b2c  late   worst  | 16.0/24.2/63        17.0/22.3/60      
b2c  late   due    | 9.0/12.7/59         10.0/12.9/58      
b2c  late   off    | 16.0/27.1/63        17.5/25.4/60      

== (b2) açýk hata, sürüm anýnda (kapanýþtan sonra) ==
pazar dönem  kol    | tohum 7  med/ort/n  tohum 11 med/ort/n
b2b  early  none   | 9.0/17.5/8          0.0/9.1/7         
b2b  early  worst  | 15.0/13.4/11        7.0/9.2/11        
b2b  early  due    | 3.0/5.7/9           1.0/2.5/10        
b2b  early  off    | 17.0/13.6/10        5.5/9.5/10        
b2b  late   none   | 101.0/124.9/8       104.0/126.8/9     
b2b  late   worst  | 7.0/8.1/72          7.0/7.7/71        
b2b  late   due    | 5.0/5.1/62          4.0/4.3/65        
b2b  late   off    | 8.0/8.4/72          6.0/7.8/73        
b2c  early  none   | 10.0/10.0/6         14.5/13.8/8       
b2c  early  worst  | 1.0/2.4/9           3.0/3.3/11        
b2c  early  due    | 2.0/2.3/7           2.0/1.7/9         
b2c  early  off    | 1.0/2.4/9           3.0/3.3/11        
b2c  late   none   | 47.0/56.2/69        47.5/60.2/64      
b2c  late   worst  | 12.5/19.6/64        14.0/17.7/61      
b2c  late   due    | 5.0/6.0/60          6.0/6.4/58        
b2c  late   off    | 13.0/22.3/64        14.0/20.6/61      

== (c1) düzeltme payý (sprint baþýnda düzeltme yükü / kapasite) ==
pazar dönem  kol    | tohum 7  med/ort/n  tohum 11 med/ort/n
b2b  early  none   | 0.000/0.000/12      0.000/0.000/13    
b2b  early  worst  | 0.104/0.108/12      0.071/0.116/12    
b2b  early  due    | 0.000/0.203/11      0.000/0.163/12    
b2b  early  off    | 0.083/0.099/11      0.122/0.125/11    
b2b  late   none   | 0.000/0.000/71      0.000/0.000/71    
b2b  late   worst  | 0.048/0.055/71      0.049/0.054/70    
b2b  late   due    | 0.048/0.058/71      0.049/0.065/71    
b2b  late   off    | 0.047/0.055/71      0.050/0.054/72    
b2c  early  none   | 0.000/0.000/11      0.000/0.024/13    
b2c  early  worst  | 0.500/0.389/12      0.500/0.436/13    
b2c  early  due    | 0.500/0.424/11      0.250/0.417/12    
b2c  early  off    | 0.500/0.389/12      0.500/0.436/13    
b2c  late   none   | 0.057/0.074/68      0.056/0.064/65    
b2c  late   worst  | 0.102/0.101/63      0.102/0.098/60    
b2c  late   due    | 0.102/0.148/59      0.119/0.140/58    
b2c  late   off    | 0.102/0.103/63      0.102/0.101/60    

== (c2) hata sprinti oraný (pay > %50) ==
pazar dönem  kol    | tohum 7  med/ort/n  tohum 11 med/ort/n
b2b  early  none   | 0.000/0.000/12      0.000/0.000/13    
b2b  early  worst  | 0.000/0.000/12      0.000/0.000/12    
b2b  early  due    | 0.000/0.000/11      0.000/0.000/12    
b2b  early  off    | 0.000/0.000/11      0.000/0.000/11    
b2b  late   none   | 0.000/0.000/71      0.000/0.000/71    
b2b  late   worst  | 0.000/0.000/71      0.000/0.000/70    
b2b  late   due    | 0.000/0.000/71      0.000/0.000/71    
b2b  late   off    | 0.000/0.000/71      0.000/0.000/72    
b2c  early  none   | 0.000/0.000/11      0.000/0.000/13    
b2c  early  worst  | 0.000/0.000/12      0.000/0.000/13    
b2c  early  due    | 0.000/0.000/11      0.000/0.000/12    
b2c  early  off    | 0.000/0.000/12      0.000/0.000/13    
b2c  late   none   | 0.000/0.000/68      0.000/0.000/65    
b2c  late   worst  | 0.000/0.000/63      0.000/0.000/60    
b2c  late   due    | 0.000/0.000/59      0.000/0.000/58    
b2c  late   off    | 0.000/0.000/63      0.000/0.000/60    

== (c3) arka arkaya iki hata sprinti oraný ==
pazar dönem  kol    | tohum 7  med/ort/n  tohum 11 med/ort/n
b2b  early  none   | 0.000/0.000/11      0.000/0.000/12    
b2b  early  worst  | 0.000/0.000/11      0.000/0.000/11    
b2b  early  due    | 0.000/0.000/10      0.000/0.000/11    
b2b  early  off    | 0.000/0.000/10      0.000/0.000/10    
b2b  late   none   | 0.000/0.000/71      0.000/0.000/71    
b2b  late   worst  | 0.000/0.000/71      0.000/0.000/70    
b2b  late   due    | 0.000/0.000/71      0.000/0.000/71    
b2b  late   off    | 0.000/0.000/71      0.000/0.000/72    
b2c  early  none   | 0.000/0.000/10      0.000/0.000/12    
b2c  early  worst  | 0.000/0.000/11      0.000/0.000/12    
b2c  early  due    | 0.000/0.000/10      0.000/0.000/11    
b2c  early  off    | 0.000/0.000/11      0.000/0.000/12    
b2c  late   none   | 0.000/0.000/68      0.000/0.000/65    
b2c  late   worst  | 0.000/0.000/63      0.000/0.000/60    
b2c  late   due    | 0.000/0.000/59      0.000/0.000/58    
b2c  late   off    | 0.000/0.000/63      0.000/0.000/60    

== churn: kayýp müþteri (B2B ayrýlan hesap, B2C kitleden giden kullanýcý), MRR farký fix_off'a göre ==
pazar kol    tohum | erken (kayýp, %)                   | geç (kayýp, %)                     | toplam %  kitle/MRR farký
b2b  none   7     | 26, 44.07%                         | 36, 11.04%                         | 17.61%  MRR 157844 (off -50783)
b2b  none   11    | 22, 37.93%                         | 57, 17.33%                         | 22.51%  MRR 171812 (off -29347)
b2b  worst  7     | 16, 27.12%                         | 0, 0.00%                           | 4.62%  MRR 206248 (off -2379)
b2b  worst  11    | 23, 39.66%                         | 1, 0.30%                           | 6.78%  MRR 265728 (off +64569)
b2b  due    7     | 13, 22.03%                         | 0, 0.00%                           | 3.75%  MRR 191481 (off -17146)
b2b  due    11    | 15, 25.86%                         | 1, 0.30%                           | 4.55%  MRR 241125 (off +39966)
b2b  off    7     | 11, 18.97%                         | 2, 0.60%                           | 3.76%  MRR 208627 (off +0)
b2b  off    11    | 14, 23.33%                         | 1, 0.30%                           | 4.27%  MRR 201159 (off +0)
b2c  none   7     | 749, 39.83%                        | 12292, 17.94%                      | 18.82%  MRR 269944 (off -1060448), kitle 56239 (off -220925)
b2c  none   11    | 672, 33.73%                        | 12673, 20.21%                      | 21.06%  MRR 240176 (off -774392), kitle 50037 (off -161331)
b2c  worst  7     | 778, 45.28%                        | 16140, 7.40%                       | 7.73%  MRR 969800 (off -360592), kitle 202042 (off -75122)
b2c  worst  11    | 794, 47.54%                        | 12920, 7.58%                       | 8.01%  MRR 755648 (off -258920), kitle 157427 (off -53941)
b2c  due    7     | 778, 46.95%                        | 8177, 3.56%                        | 3.88%  MRR 1063528 (off -266864), kitle 221568 (off -55596)
b2c  due    11    | 763, 46.99%                        | 8688, 3.84%                        | 4.16%  MRR 1044720 (off +30152), kitle 217651 (off +6282)
b2c  off    7     | 774, 45.09%                        | 777, 0.28%                         | 0.56%  MRR 1330392 (off +0), kitle 277165 (off +0)
b2c  off    11    | 791, 47.32%                        | 868, 0.41%                         | 0.78%  MRR 1014568 (off +0), kitle 211368 (off +0)

== E1 sec. 9 hedefleri ==
PASS fix_due b2b early haftada yeni hata (medyan) <= 1.5                                              1.00  n=40
PASS fix_due b2b early açýk hata, sürüm anýnda (medyan) <= 4                                          2.00  n=19
PASS fix_due b2b early açýk hata, sprint sonu (medyan) <= 8                                           4.00  n=23
PASS fix_due b2b late haftada yeni hata (medyan) <= 4                                                 3.00  n=154
PASS fix_due b2b late açýk hata, sürüm anýnda (medyan) <= 8                                           5.00  n=127
PASS fix_due b2b late açýk hata, sprint sonu (medyan) <= 16                                           8.00  n=142
PASS fix_due b2c early haftada yeni hata (medyan) <= 1.5                                              1.00  n=40
PASS fix_due b2c early açýk hata, sürüm anýnda (medyan) <= 4                                          2.00  n=16
PASS fix_due b2c early açýk hata, sprint sonu (medyan) <= 8                                           4.00  n=23
PASS fix_due b2c late haftada yeni hata (medyan) <= 3                                                 3.00  n=154
PASS fix_due b2c late açýk hata, sürüm anýnda (medyan) <= 8                                           6.00  n=118
PASS fix_due b2c late açýk hata, sprint sonu (medyan) <= 16                                           9.00  n=117
PASS fix_worst b2b late düzeltme payý medyaný <= 15%                                                  4.80  n=141
PASS fix_worst b2b early düzeltme payý medyaný <= 30%                                                 8.20  n=24
PASS fix_worst b2c late düzeltme payý medyaný <= 15%                                                 10.20  n=123
MISS fix_worst b2c early düzeltme payý medyaný <= 30%                                                50.00  n=25
PASS fix_due b2b late düzeltme payý medyaný <= 20%                                                    4.90  n=142
PASS fix_due b2b early düzeltme payý medyaný <= 30%                                                   0.00  n=23
PASS fix_due b2c late düzeltme payý medyaný <= 20%                                                   10.60  n=117
MISS fix_due b2c early düzeltme payý medyaný <= 30%                                                  50.00  n=23
PASS fix_due b2b late hata sprinti oraný <= 5%                                                        0.00  n=142
PASS fix_due b2b early hata sprinti oraný <= 15%                                                      0.00  n=23
PASS fix_due b2c late hata sprinti oraný <= 5%                                                        0.00  n=117
PASS fix_due b2c early hata sprinti oraný <= 15%                                                      0.00  n=23
PASS fix_worst b2b late üst üste iki hata sprinti oraný <= 0%                                         0.00  n=141
PASS fix_worst b2b early üst üste iki hata sprinti oraný <= 1%                                        0.00  n=22
PASS fix_worst b2c late üst üste iki hata sprinti oraný <= 0%                                         0.00  n=123
PASS fix_worst b2c early üst üste iki hata sprinti oraný <= 1%                                        0.00  n=23
PASS fix_due b2b late üst üste iki hata sprinti oraný <= 0%                                           0.00  n=142
PASS fix_due b2b early üst üste iki hata sprinti oraný <= 1%                                          0.00  n=21
PASS fix_due b2c late üst üste iki hata sprinti oraný <= 0%                                           0.00  n=117
PASS fix_due b2c early üst üste iki hata sprinti oraný <= 1%                                          0.00  n=21
PASS churn b2b tohum 7: fix_worst kaybý <= fix_off + 10 puan                                          0.87  worst 4.62% off 3.76%
PASS churn b2b tohum 7: fix_none kaybý >= 2 x fix_off                                                17.61  none 17.61% off 3.76%
PASS churn b2b tohum 11: fix_worst kaybý <= fix_off + 10 puan                                         2.51  worst 6.78% off 4.27%
PASS churn b2b tohum 11: fix_none kaybý >= 2 x fix_off                                               22.51  none 22.51% off 4.27%
PASS churn b2c tohum 7: fix_worst kaybý <= fix_off + 10 puan                                          7.17  worst 7.73% off 0.56%
PASS churn b2c tohum 7: fix_none kaybý >= 2 x fix_off                                                18.82  none 18.82% off 0.56%
PASS churn b2c tohum 11: fix_worst kaybý <= fix_off + 10 puan                                         7.24  worst 8.01% off 0.78%
PASS churn b2c tohum 11: fix_none kaybý >= 2 x fix_off                                               21.06  none 21.06% off 0.78%

ÖZET: 40 hedef, 2 MISS

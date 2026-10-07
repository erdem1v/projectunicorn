# Gönderen eşlemesi (Olaylar mail dönüşümü, A4)

Erdem kararı 15: her olay bir göndericiden gelmiş bir mail. Bu tablo her canlı kartın bugünkü konuşmacısını ve önerilen
göndericiyi verir. Kaynak: `data/events/cards/**/*.json` (fikstürler hariç), salt okunur; `tools/senders.py` yeniden üretir.
Durum sütunu kartın git durumunu yazar: başka oturumun izlenmeyen kartları da tabloda (onlar da canlı sayılır).

## Gönderen türleri (öneri, onay bekliyor)

| Tür | Kim | Avatar | İmza | Kaynak (motor) |
|---|---|---|---|---|
| FRANK | Frank Köseoğlu, Operating Partner | aday A portresi (disk + kuyu) | ad, unvan | `char_mentor_frank` |
| EMPLOYEE | kartın bağladığı çalışan (`{employee}`, `{rep}`) ya da rolle seçilen | büst (disk + kuyu) | ad, unvan, şirket | `EvScope` slotu; slot yoksa yeni seçici |
| CONTACT | hesabın muhatabı | **öneri:** satış masasında tanışılan alıcı, `CounterpartSystem` aynı adı ve görünüşü hesabın lead kimliğinden yeniden çeker (`Customer.id = "co_" + lead id`). Fikstür ve başlangıç hesaplarında lead yok: şirket monogramı | unvan (`B2B_CONTACT_*`, `musteri.sector_contact`) ya da alıcı unvanı, şirket | `CounterpartSystem._people_for(lead_id, [buyer])` |
| PROSPECT | adayın alıcısı | `CounterpartSystem.prospect_people(p)[0]` büstü | ad, unvan, şirket | aynı |
| VC | fonun ortağı (lead) | `CounterpartSystem.lead(vc_id)` büstü | ad, `InvestorRegistry.role_line`, fon | `GameState.investor_people` |
| PRESS | dört yayından biri (Sektör Telgrafı, Ekonomi Postası, TeknoGündem, Girişim Bülteni) | yayın rengiyle monogram | yayın adı | `outlet-*` token'ları |
| DESK | şirket içi masa, kişi yok: **Muhasebe** (dönem özeti), **Destek** (destek ve kullanıcı geri bildirimi) | rapor glifi | masa adı, şirket adı | yeni anahtarlar, adlar Erdem'in onayına |
| SELF | kurucunun kendi notu | kurucu portresi | yok | kurucu |
| OUTSIDE | kişisiz dış gönderen (alan adı aracısı, fuar, uygulama ağı) ya da çekilmiş adlı kişi (eski arkadaş, içerik üreticisi) | monogram | ad ya da kurum | yeni: ad havuzundan çekim |

Kurallar (öneri):
- Bir mailin tek göndericisi vardır. İki sesli kartlar (`funding.acquisition_offer`, `funding.seed_offer`) bir konuşma
  zincirine bölünür: ilk mail VC'den, Frank'in tek satırı aynı zincirde ikinci mail.
- Kartta `speaker` alanı yalnız Frank için dolu. Mail için kart metin bloğuna `sender` ve `subject` gelir (plan, Faz E
  "Motor"); `sender` yoksa kategoriden türetilir: customer → CONTACT, team → EMPLOYEE, funding → FRANK, world → PRESS ya
  da OUTSIDE, founder → SELF, product → EMPLOYEE ya da DESK.
- Konu etiketi (pill) gönderenden değil kategoriden gelir; Frank → MENTOR.

## Kart kart

| Kart | Kategori | Sınıf | Durum | Bugün `speaker` | Önerilen gönderen | Neden (metnin bugünkü sesi) |
|---|---|---|---|---|---|---|
| `customer.b2c_refunds` | customer | paper | untracked WIP | none | DESK Destek (Support) | B2C refund requests reach the support desk; no person in the text, the desk relays the volume. |
| `customer.cs_escalation` | customer | interrupt | tracked | none | EMPLOYEE {rep} (the account's rep) | Body is the rep's own voice ("Patron, ... Tutabildiğim kadar tuttum"); the slot already binds the rep. |
| `customer.expansion` | customer | paper | tracked | none | CONTACT of {customer} | The account asks for seats in the first person plural; the contact writes it. |
| `customer.frank_intro` | customer | interrupt | tracked | none | FRANK | Speaker missing in the card but the text is Frank's call; badge reads the speaker, so the card should name him. |
| `sales.price_break` | customer | interrupt | tracked | none | EMPLOYEE the rep working {prospect}, else PROSPECT buyer | Text is PH. At the table the buyer waits; when a rep works the lead the rep reports it. |
| `customer.request_complaint` | customer | paper | tracked | none | EMPLOYEE {rep} (support_lead) | Body is the rep's voice ("Şimdilik oyaladım. Onlara ne diyeyim?") quoting the customer. |
| `customer.request_feature` | customer | paper | tracked | none | EMPLOYEE {rep} (support_lead) | Body is the rep's voice ("Öğrenip döneceğimi söyledim"). |
| `customer.request_renewal` | customer | paper | tracked | none | EMPLOYEE {rep} (support_lead) | "Karşılarında bizden birini görmek istiyorlar" is our side speaking; the rep slot is bound. |
| `customer.retention` | customer | interrupt | tracked | none | CONTACT of {customer} | Today narrator plus the account's quote; the quote becomes the contact's mail. |
| `customer.security_review` | customer | paper | untracked WIP | none | CONTACT of {customer}, buyer role | The procurement team sends the questionnaire; CounterpartSystem's buyer is the procurement lead. |
| `sales.weekly_summary` | customer | info | tracked | none | EMPLOYEE the sales rep (SalesRepSystem) | Plan: the rep's row snapshot becomes a message; the card itself is deleted with it (Faz E). |
| `founder.company_of_one` | founder | interrupt | untracked WIP | none | SELF (founder's note) | Quiet observation about the founder's own week; nobody else would write it. |
| `founder.domain_name` | founder | paper | untracked WIP | none | OUTSIDE domain reseller (no person) | The reseller offers the short address; a company sender with no name. |
| `founder.friends_test` | founder | paper | untracked WIP | none | OUTSIDE an old friend (name drawn from the run's pool) | Friends ask to try it; needs a drawn name like CounterpartSystem, or the group label. |
| `founder.meetup_talk` | founder | paper | untracked WIP | none | OUTSIDE meetup organisers (no person) | "organizatörler sana soruyor". |
| `founder.savings_note` | founder | interrupt | untracked WIP | none | SELF (founder's note) | The founder reads their own balance; a bank sender would be a new institution. |
| `founder.side_contract` | founder | paper | untracked WIP | none | OUTSIDE a former colleague (name drawn from the run's pool) | "Eski bir iş arkadaşının şirketinde ... aklına sen gelmişsin". |
| `founder.unseen_build` | founder | interrupt | untracked WIP | none | SELF (founder's note) | Observation only the founder can make. |
| `funding.acquisition_offer` | funding | interrupt | tracked | Frank (speaker) | VC lead of {investor} (seed lead), then FRANK as a second mail | Two voices: the investor brings the buyer, Frank adds one line. A mail has one sender, so Frank's line becomes a reply in the same thread. |
| `funding.frank_approach_close` | funding | interrupt | tracked | Frank (speaker) | FRANK | Already a message from Frank. |
| `funding.frank_approach_half` | funding | interrupt | tracked | Frank (speaker) | FRANK | Already a message from Frank. |
| `funding.frank_approach_near` | funding | interrupt | tracked | Frank (speaker) | FRANK | Already a message from Frank. |
| `funding.frank_cheque` | funding | interrupt | tracked | Frank (speaker) | FRANK | His offer, his money. |
| `funding.frank_door_open` | funding | interrupt | tracked | Frank (speaker) | FRANK | Already a message from Frank. |
| `funding.frank_office_move` | funding | interrupt | tracked, ea | Frank (speaker) | FRANK | "Frank'ten mesaj" (EA scope). |
| `funding.gate_series_a` | funding | interrupt | tracked | Frank (speaker) | FRANK | Speaker is Frank; body is a scene ("Frank telefonunu ters çevirip masaya koyuyor") that a mail cannot show: needs a rewrite in the full pass. |
| `funding.gate_traction` | funding | interrupt | tracked | Frank (speaker) | FRANK | "Frank'ten mesaj". |
| `funding.hire_nudge` | funding | interrupt | tracked | Frank (speaker) | FRANK | "Frank'ten mesaj". |
| `funding.last_answer` | funding | interrupt | tracked | Frank (speaker) | FRANK | Narrator line plus Frank's quote; Frank writes both. |
| `funding.seed_closed` | funding | interrupt | tracked | Frank (speaker) | FRANK | "Frank'ten mesaj"; the narrator line becomes his first sentence. |
| `funding.seed_door` | funding | interrupt | tracked | Frank (speaker) | FRANK | Frank calls; the call becomes his mail. |
| `funding.seed_offer` | funding | interrupt | tracked | Frank (speaker) | VC lead of {investor}, FRANK's line as a reply in the thread | "{investor} teklifi gönderdi" plus Frank's comment; same two-voice rule as the acquisition offer. |
| `funding.seed_stalled` | funding | paper | tracked | none | VC lead of {investor} | Literally "{investor} bir mail göndermiş". |
| `funding.sheet_decision` | funding | interrupt | tracked | none | VC lead of {investor} | The fund wants an answer; no speaker today. |
| `funding.sheet_expiry` | funding | interrupt | tracked | Frank (speaker) | FRANK | Frank's warning quotes the deadline. |
| `funding.shutter_warning` | funding | interrupt | tracked | Frank (speaker) | FRANK | Frank calls about the red account. |
| `product.b2c_floor_churn` | product | interrupt | untracked WIP | none | DESK Destek (Support) | Exit survey result; the support desk reads it. |
| `product.b2c_floor_signal` | product | interrupt | untracked WIP | none | DESK Destek (Support) | Reviews summary; same desk. |
| `product.bug_pile` | product | interrupt | untracked WIP | none | EMPLOYEE support lead if staffed, else DESK Destek | "Destek aynı özrü günde birkaç kez yazıyor": the support desk speaks. |
| `product.outage` | product | interrupt | untracked WIP | none | EMPLOYEE most senior engineer if any, else DESK Destek | An incident report; the engineer on call is the natural writer. Needs a slot. |
| `product.paid_tier` | product | interrupt | tracked | none | FRANK | Frank calls (subtitle "Mutfak masası"). |
| `product.sprint_contractor` | product | paper | untracked WIP | none | EMPLOYEE the Ürün Yöneticisi, else the person on the card | A sprint card question; needs a slot binding (none today). |
| `product.sprint_late` | product | paper | untracked WIP | none | EMPLOYEE the Ürün Yöneticisi, else the person on the card | Same: the sprint's owner raises it. |
| `product.sprint_two_paths` | product | paper | untracked WIP | none | EMPLOYEE the Ürün Yöneticisi, else the person on the card | Same. |
| `product.working_parts` | product | interrupt | untracked WIP | none | SELF (founder's note) | Early solo build observation. |
| `rival.funding_round` | rival | interrupt | untracked WIP | none | PRESS Girişim Bülteni | Funding news is that outlet's beat; "Kurucuları bu hafta her röportajda". |
| `rival.price_cut` | rival | interrupt | untracked WIP | none | CONTACT of {customer}, buyer role | "Satın alma sorumluları teklifi iletti": the buyer forwards the rival's quote. |
| `team.demo_day` | team | interrupt | untracked WIP | none | EMPLOYEE most senior (slot to add) | "Biri ... öneriyor": someone on the team; a mail needs a named one. |
| `team.first_weeks` | team | interrupt | untracked WIP | none | SELF (founder's note) | An observation about the new hire; the hire would not write it about themself. |
| `team.outside_offer` | team | interrupt | untracked WIP | none | EMPLOYEE {employee} | "cevap vermeden önce sana söyledi": the employee tells you. |
| `team.resignation` | team | interrupt | tracked | none | EMPLOYEE {employee} | The resignation is the employee's own line. |
| `product.design_round_intro` | product | interrupt | tracked, unwired | Frank (speaker) | FRANK (unwired) | Unwired card, scene at the prototype; rewrite needed if it ever ships. |
| `product.first_ship` | product | interrupt | tracked, unwired | Frank (speaker) | FRANK (unwired) | A message from Frank on the phone; already message-shaped. |
| `product.version_ship` | product | interrupt | tracked, unwired | Frank (speaker) | FRANK (unwired) | Scene ("Frank ekrana bakıyor"); rewrite needed if it ships. |
| `world.app_placement` | world | paper | untracked WIP | none | OUTSIDE the app network (no person) | The network offers the slot. |
| `world.b2c_creator_feature` | world | paper | untracked WIP | none | OUTSIDE the creator (name drawn from the run's pool) | A person with a rate card; needs a name source. |
| `world.final_stretch_comment` | world | interrupt | tracked | none | PRESS Sektör Telgrafı, reporter | Same arc as the annual file; the reporter writes for a comment. |
| `world.final_stretch_press` | world | paper | tracked | none | PRESS Sektör Telgrafı | The annual file is that outlet's (title names it). |
| `world.final_stretch_verdict` | founder | interrupt | tracked | Frank (speaker) | FRANK | "Frank arıyor". |
| `world.trade_fair` | world | paper | untracked WIP | none | OUTSIDE the fair organiser (no person) | One stand left; the organiser sells it. |

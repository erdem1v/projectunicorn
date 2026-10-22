import json
w1 = json.load(open('docs/tasks/faz_ab/b_taslak/W1_OLAYLAR.json', encoding='utf-8'))
items = {i['id']: i for i in w1['items']}
rows = []
for key in ['EFFECT_TRUST_ACCOUNT', 'EFFECT_TRUST_ACCOUNTS', 'EFFECT_NIGHT_CREW', 'EFFECT_TRUST_PER_SPRINT']:
    t = items['chip.' + key]['text']
    rows.append((key, t['tr'], t['en']))
rows.append(('EFFECT_NAMES_MORE', 've {n} kişi', 'and {n} more'))
for k, tr, en in rows:
    for v in (tr, en):
        assert not any(ch in v for ch in ',"\n\r'), (k, v)
data = open('localization/strings.csv', 'rb').read()
anchor = 'EFFECT_MARKETING_GROWTH,Kitle büyümesi {pct} · {weeks},Audience growth {pct} · {weeks}\n'.encode('utf-8')
assert data.count(anchor) == 1
pos = data.index(anchor) + len(anchor)
ins = ''.join('%s,%s,%s\n' % r for r in rows).encode('utf-8')
open('localization/strings.csv', 'wb').write(data[:pos] + ins + data[pos:])
print(ins.decode('utf-8'))

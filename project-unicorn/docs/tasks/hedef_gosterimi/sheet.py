import json, sys, os, urllib.request, io
from PIL import Image, ImageDraw
ids = sys.argv[1:]
for id in ids:
    d = json.load(open(f'app_{id}.json', encoding='utf-8'))[id]['data']
    shots = d.get('screenshots', [])[:16]
    os.makedirs(f'th_{id}', exist_ok=True)
    ims = []
    for i, s in enumerate(shots):
        p = f'th_{id}/{i:02d}.jpg'
        if not os.path.exists(p):
            urllib.request.urlretrieve(s['path_thumbnail'], p)
        ims.append(Image.open(p).convert('RGB').resize((480, 270)))
    cols = 4
    rows = (len(ims) + cols - 1) // cols
    sheet = Image.new('RGB', (cols * 480, rows * 270), 'black')
    dr = ImageDraw.Draw(sheet)
    for i, im in enumerate(ims):
        x, y = (i % cols) * 480, (i // cols) * 270
        sheet.paste(im, (x, y))
        dr.rectangle([x, y, x + 34, y + 22], fill='yellow')
        dr.text((x + 4, y + 4), f'{i:02d}', fill='black')
    sheet.save(f'sheet_{id}.jpg', quality=80)
    print(id, d['name'], len(ims))

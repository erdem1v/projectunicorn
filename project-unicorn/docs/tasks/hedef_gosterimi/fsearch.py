import json, sys, urllib.request, urllib.parse
UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/129.0 Safari/537.36"
def get(host, params):
    url = f"https://{host}/api.php?" + urllib.parse.urlencode({**params, "format": "json"})
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    return json.load(urllib.request.urlopen(req, timeout=30))
host = sys.argv[1]
for kw in sys.argv[2:]:
    try:
        r = get(host, {"action": "query", "list": "search", "srsearch": kw, "srnamespace": 6, "srlimit": 15})
    except Exception as e:
        print(host, kw, "ERR", e); continue
    titles = [h["title"] for h in r.get("query", {}).get("search", [])]
    if not titles:
        print(host, kw, "-"); continue
    r2 = get(host, {"action": "query", "titles": "|".join(titles), "prop": "imageinfo", "iiprop": "url|size"})
    for p in r2["query"]["pages"].values():
        ii = (p.get("imageinfo") or [{}])[0]
        print(f"{kw}\t{p['title']}\t{ii.get('width')}x{ii.get('height')}\t{ii.get('url','')}")

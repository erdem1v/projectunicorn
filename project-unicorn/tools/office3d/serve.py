"""Static server + sink for the office3d export page (tools/office3d/export_office.html).

Serves the project-unicorn tree and accepts POSTs:
  /save/<name>.glb | .json  -> art/office3d/<name>
  /save/<name>.jpg | .png   -> assets/art/office/<name>
  /save/<name>.txt          -> <status dir>/<name>   (progress.txt, DONE.txt; never in the repo)

usage: python tools/office3d/serve.py --status <dir> [--port 8735]
POST instead of <a download>: Chrome holds download bursts behind a prompt.
"""
import argparse, http.server, os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))

ap = argparse.ArgumentParser()
ap.add_argument("--port", type=int, default=8735)
ap.add_argument("--status", required=True)
args = ap.parse_args()
SINKS = {
    ".glb": os.path.join(ROOT, "art", "office3d"),
    ".json": os.path.join(ROOT, "art", "office3d"),
    ".jpg": os.path.join(ROOT, "assets", "art", "office"),
    ".png": os.path.join(ROOT, "assets", "art", "office"),
    ".txt": args.status,
}
for d in set(SINKS.values()):
    os.makedirs(d, exist_ok=True)


class Handler(http.server.SimpleHTTPRequestHandler):
    # The Windows registry can map .js to text/plain, which Chrome refuses for module scripts.
    extensions_map = {**http.server.SimpleHTTPRequestHandler.extensions_map, ".js": "text/javascript"}

    def __init__(self, *a, **kw):
        super().__init__(*a, directory=ROOT, **kw)

    def end_headers(self):
        # The profile persists between runs; a cached src/*.js would export stale geometry.
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def do_POST(self):
        if not self.path.startswith("/save/"):
            self.send_error(404)
            return
        name = os.path.basename(self.path[len("/save/"):])
        sink = SINKS.get(os.path.splitext(name)[1])
        if sink is None:
            self.send_error(400, "glb/json/jpg/png/txt only")
            return
        data = self.rfile.read(int(self.headers.get("Content-Length", 0)))
        dest = os.path.join(sink, name)
        with open(dest, "wb") as f:
            f.write(data)
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()
        self.wfile.write(b"ok %d" % len(data))
        if not name.endswith(".txt"):
            print("wrote %s (%d bytes)" % (dest, len(data)), flush=True)

    def log_message(self, *a):
        pass


with http.server.ThreadingHTTPServer(("127.0.0.1", args.port), Handler) as httpd:
    print("office3d export server on %d, root=%s, status=%s" % (args.port, ROOT, args.status), flush=True)
    httpd.serve_forever()

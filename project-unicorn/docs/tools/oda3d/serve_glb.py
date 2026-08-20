"""Static server + sink for the ODA 3D spike's GLB export page.

Serves the whole project-unicorn tree (the export page imports
tools/oda_render_rig/desk-builders.js by relative path, so the server root must be
a common ancestor) and accepts POSTs:
  /save/<name>.glb | .json  -> art/oda3d/<name>          (the deliverables)
  /save/<name>.txt          -> <status dir>/<name>       (DONE.txt / progress; never in the repo)

usage: python docs/tools/oda3d/serve_glb.py [--port 8734] [--status <dir>]
Mirrors tools/oda_render_rig/serve.py (POST instead of <a download>: Chrome
throttles download bursts behind a prompt; a blocked export is worse than a slow one).
"""
import argparse, http.server, os, socketserver, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))          # project-unicorn
OUT = os.path.join(ROOT, "art", "oda3d")

ap = argparse.ArgumentParser()
ap.add_argument("--port", type=int, default=8734)
ap.add_argument("--status", default=os.path.join(HERE, "_status"))
args = ap.parse_args()
os.makedirs(OUT, exist_ok=True)
os.makedirs(args.status, exist_ok=True)


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *a, **kw):
        super().__init__(*a, directory=ROOT, **kw)

    def do_POST(self):
        if not self.path.startswith("/save/"):
            self.send_error(404); return
        name = os.path.basename(self.path[len("/save/"):])
        if name.endswith((".glb", ".json")):
            dest = os.path.join(OUT, name)
        elif name.endswith(".txt"):
            dest = os.path.join(args.status, name)
        else:
            self.send_error(400, "glb/json/txt only"); return
        n = int(self.headers.get("Content-Length", 0))
        data = self.rfile.read(n)
        with open(dest, "wb") as f:
            f.write(data)
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()
        self.wfile.write(b"ok %d" % len(data))
        print("wrote %s (%d bytes)" % (dest, len(data)), flush=True)

    def log_message(self, *a):
        pass


socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("127.0.0.1", args.port), Handler) as httpd:
    print("oda3d export server on %d, root=%s, out=%s, status=%s" % (args.port, ROOT, OUT, args.status), flush=True)
    httpd.serve_forever()

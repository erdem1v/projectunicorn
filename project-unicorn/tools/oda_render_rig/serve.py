"""Static server + PNG sink for the ODA layer export rig.

Chrome throttles a burst of nine downloads behind an "allow multiple downloads"
prompt, so the rig POSTs each render here instead. No downloads, no prompt, and
the files land in ./out/ rather than the user's Downloads folder.
"""
import http.server, os, socketserver

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(ROOT, "out")
os.makedirs(OUT, exist_ok=True)


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *a, **kw):
        super().__init__(*a, directory=ROOT, **kw)

    def do_POST(self):
        if not self.path.startswith("/save/"):
            self.send_error(404)
            return
        name = os.path.basename(self.path[len("/save/"):])
        if not name.endswith((".png", ".json", ".txt")):
            self.send_error(400, "png/json/txt only")
            return
        n = int(self.headers.get("Content-Length", 0))
        data = self.rfile.read(n)
        with open(os.path.join(OUT, name), "wb") as f:
            f.write(data)
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(b"ok %d" % len(data))
        print("wrote %s (%d bytes)" % (name, len(data)), flush=True)

    def log_message(self, *a):
        pass


socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("127.0.0.1", 8732), Handler) as httpd:
    print("rig server on 8732, out=%s" % OUT, flush=True)
    httpd.serve_forever()

#!/usr/bin/env python3
"""Demo Shop — a tiny service with a version endpoint, a health endpoint,
and a feature-flagged /beta endpoint. Standard library only."""
import json
import os
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

HERE = os.path.dirname(os.path.abspath(__file__))
VERSION = open(os.path.join(HERE, "VERSION")).read().strip()
COLOR = os.environ.get("COLOR", "unknown")
# simulates bad prod config
BROKEN = os.environ.get("BROKEN", "false") == "true"
FEATURE_BETA = os.environ.get("FEATURE_BETA", "off") == "on"

PAGE = """<!doctype html><body style="font-family:sans-serif;text-align:center;margin-top:3em;background:{bg};color:white">
<h1>Demo Shop</h1><h2>version {v}</h2><p>served by the <b>{c}</b> environment</p>{extra}</body>"""


class H(BaseHTTPRequestHandler):
    def _send(self, code, body, ctype="text/html"):
        d = body.encode()
        try:
            self.send_response(code)
            self.send_header("Content-Type", ctype)
            self.send_header("Content-Length", str(len(d)))
            self.end_headers()
            self.wfile.write(d)
        except (BrokenPipeError, ConnectionResetError):
            # client hung up mid-response (e.g. curl --max-time) - not an error
            pass

    def do_GET(self):
        if self.path == "/health":
            if BROKEN:
                self._send(500, '{"status": "unhealthy"}', "application/json")
            else:
                self._send(200, json.dumps(
                    {"status": "ok", "version": VERSION}), "application/json")
        elif self.path == "/version":
            self._send(200, json.dumps(
                {"version": VERSION, "color": COLOR}), "application/json")
        elif self.path == "/beta":
            if FEATURE_BETA:
                self._send(
                    200, "<h1 style='font-family:sans-serif'>BETA: one-click checkout</h1>")
            else:
                self._send(404, "not found", "text/plain")
        else:
            bg = "#1a73e8" if COLOR == "blue" else "#188038"
            extra = '<p><a style="color:white" href="/beta">try the beta</a></p>' if FEATURE_BETA else ""
            self._send(200, PAGE.format(
                bg=bg, v=VERSION, c=COLOR, extra=extra))

    def log_message(self, *a):
        pass


if __name__ == "__main__":
    if len(sys.argv) > 2:
        sys.exit("usage: python3 app.py [port]   (default port 5000)")
    try:
        port = int(sys.argv[1]) if len(sys.argv) > 1 else 5000
    except ValueError:
        sys.exit("usage: python3 app.py [port]   (default port 5000)")
    ThreadingHTTPServer(("0.0.0.0", port), H).serve_forever()

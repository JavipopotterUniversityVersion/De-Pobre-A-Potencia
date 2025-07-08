import http.server
import socketserver

PORT = 8000

class CORSHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        super().end_headers()

handler = CORSHTTPRequestHandler
httpd = socketserver.TCPServer(("", PORT), handler)

print(f"Sirviendo en http://localhost:{PORT}")
httpd.serve_forever()

#!/usr/bin/env python3
"""
Origin : https://gist.github.com/mdonkers/63e115cc0c79b4f6b8b3a6b797e485c7
Very simple HTTP server in python for logging requests
Usage::
    ./server.py [<port>]
"""
from http.server import BaseHTTPRequestHandler, HTTPServer
import logging


class S(BaseHTTPRequestHandler):
    def _set_response(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()

    def do_GET(self):
        logging.info("GET request,\nPath: %s\nHeaders:\n%s\n", str(self.path), str(self.headers))
        self._set_response()
        self.wfile.write("GET request for {}".format(self.path).encode('utf-8'))

    def do_POST(self):
        content_length = int(self.headers['Content-Length'])  # <--- Gets the size of data
        post_data = self.rfile.read(content_length)  # <--- Gets the data itself
        logging.info("\nContent Length:%s\nPOST Body:\n%s", content_length, post_data.decode('utf-8'))

        self._set_response()
        self.wfile.write("POST request for {}".format(self.path).encode('utf-8'))


def run(server_class=HTTPServer, handler_class=S, port=7770):
    logging.basicConfig(level=logging.INFO, datefmt='%m-%d %H:%M', filename='../testArtifacts/logs/httpd-server.log')
    try:
        server_address = ('', port)
        httpd = server_class(server_address, handler_class)
    except Exception as e:
        logging.info(e, exc_info=True)

    logging.info('Starting httpd...\n')

    try:
        httpd.serve_forever()
    except Exception as e:
        logging.info(e, exc_info=True)
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    logging.info('Stopping httpd...\n')


if __name__ == '__main__':
    from sys import argv

    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()

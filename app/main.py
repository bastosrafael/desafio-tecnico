from flask import Flask, jsonify, request
import time
import os
from prometheus_client import Counter, Histogram, start_http_server

app = Flask(__name__)

# Metrics
REQUESTS_TOTAL = Counter('http_requests_total', 'Total HTTP Requests', ['method', 'endpoint', 'status'])
REQUEST_DURATION = Histogram('http_requests_duration_seconds', 'Request Duration Seconds')

@app.route('/health')
def health():
    return jsonify({"status": "healthy"}), 200

@app.route('/ready')
def ready():
    return jsonify({"status": "ready"}), 200

@app.route('/')
def hello():
    return "Hello World!", 200

@app.route('/api/v1/calendario')
def calendario():
    time.sleep(0.1)
    return jsonify({"data": "Calendario"}), 200

@app.route('/error')
def error():
    return "Error 500", 500

@app.before_request
def before_request():
    request.environ['start_time'] = time.time()

@app.after_request
def after_request(response):
    dt = time.time() - request.environ['start_time']
    status = response.status_code
    REQUEST_DURATION.observe(dt)
    REQUESTS_TOTAL.labels(method=request.method, endpoint=request.path, status=status).inc()
    return response

if __name__ == '__main__':
    # Prometheus server separate on port 8000 (/metrics automatic)
    start_http_server(8000)
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)

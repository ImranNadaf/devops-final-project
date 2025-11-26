from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time
import json
import sys

app = Flask(__name__)

# Prometheus metrics
REQUEST_COUNT = Counter(
    "api_requests_total",
    "Total API requests",
    ["method", "endpoint", "http_status"],
)
REQUEST_LATENCY = Histogram(
    "api_request_duration_seconds",
    "API request latency in seconds",
    ["endpoint"],
)


def log_json(level, message, **kwargs):
    payload = {
        "level": level,
        "message": message,
        "path": request.path if request else None,
        "method": request.method if request else None,
        "remote_addr": request.remote_addr if request else None,
        **kwargs,
    }
    sys.stdout.write(json.dumps(payload) + "\n")
    sys.stdout.flush()


@app.before_request
def start_timer():
    request.start_time = time.time()


@app.after_request
def after_request(response):
    latency = time.time() - getattr(request, "start_time", time.time())
    REQUEST_LATENCY.labels(request.path).observe(latency)
    REQUEST_COUNT.labels(
        request.method, request.path, response.status_code
    ).inc()

    log_json(
        "info",
        "request_handled",
        status_code=response.status_code,
        latency=latency,
    )
    return response


@app.route("/api/health", methods=["GET"])
def api_health():
    return jsonify({"status": "ok"}), 200


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"}), 200


# Existing working routes

@app.route("/metrics", methods=["GET"])
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}


@app.route("/api/hello", methods=["GET"])
def hello():
    return jsonify({"message": "Hello from backend!"}), 200


# ============================================================

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

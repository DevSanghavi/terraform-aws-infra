from flask import Flask, jsonify
import os
from datetime import datetime, timezone

app = Flask(__name__)

@app.route("/")
def root():
    return jsonify(
        service="terraform-aws-infra-api",
        status="running",
        endpoints=["/", "/health"]
    )

@app.route("/health")
def health():
    return jsonify(
        status="healthy",
        service="terraform-aws-infra-api",
        environment=os.getenv("APP_ENV", "development"),
        timestamp=datetime.now(timezone.utc).isoformat()
    ), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

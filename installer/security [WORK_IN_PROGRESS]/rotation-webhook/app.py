# rotation-webhook/app.py
from flask import Flask, request, jsonify
import subprocess
import os

app = Flask(__name__)

@app.route('/rotate', methods=['POST'])
def handle_rotation():
    data = request.json
    namespace = data.get('namespace', os.getenv('NAMESPACE', 'default'))
    deployment = data['deployment']
    
    try:
        subprocess.run(
            ["kubectl", "rollout", "restart", 
             f"deployment/{deployment}", "-n", namespace],
            check=True
        )
        return jsonify({"status": "success"}), 200
    except subprocess.CalledProcessError as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)

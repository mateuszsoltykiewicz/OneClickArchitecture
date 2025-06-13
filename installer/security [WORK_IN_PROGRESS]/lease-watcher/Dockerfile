# lease-watcher/Dockerfile

FROM python:3.11-slim

WORKDIR /app

# Install hvac (HashiCorp Vault API client) and requests
RUN pip install --no-cache-dir hvac requests

# Copy the lease watcher
COPY watcher.py .

# Use a non-root user for security
RUN useradd -m appuser
USER appuser

CMD ["python", "watcher.py"]

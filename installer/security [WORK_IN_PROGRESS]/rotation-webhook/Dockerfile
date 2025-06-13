# rotation-webhook/Dockerfile

FROM python:3.11-slim

WORKDIR /app

# Install Flask
RUN pip install --no-cache-dir flask

# Copy the webhook app
COPY app.py .

# Use a non-root user for security
RUN useradd -m appuser
USER appuser

EXPOSE 8080

CMD ["python", "app.py"]

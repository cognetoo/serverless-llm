# ── Stage: Runtime ──────────────────────────────────────────
FROM python:3.10-slim

# Set working directory inside container
WORKDIR /app

# Copy dependency list first (layer caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy all project files
COPY . .

# Expose Flask port
EXPOSE 5000

# Run the Flask application
CMD ["python", "app.py"]

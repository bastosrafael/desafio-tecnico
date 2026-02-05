FROM python:3.9-slim-buster

# Define the working directory
WORKDIR /app

# Install dependencies directly in the final image
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ .

# Create and use a non-root user (challenge requirement)
RUN adduser --system --group appuser && chown -R appuser:appuser /app
USER appuser

# Expose app and metrics ports
EXPOSE 5000 8000

CMD ["python", "main.py"]

FROM python:3.9-slim-buster AS builder

WORKDIR /app

COPY app/requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

COPY app/ .

FROM python:3.9-slim-buster

WORKDIR /app

COPY --from=builder /install /usr/local
COPY --from=builder /app /app

RUN adduser --system --group appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 5000 8000

CMD ["python", "main.py"]

# --- Etapa 1: build (instala dependências em um venv isolado) ---
FROM python:3.11-slim AS builder
WORKDIR /app
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# --- Etapa 2: imagem final ---
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY . .
EXPOSE 8005
# --workers 1: o worker SQS roda numa thread de background iniciada no import do
# módulo (start_worker()). Com mais de 1 worker do Gunicorn, a fila seria
# consumida em duplicidade por processos concorrentes.
CMD ["gunicorn", "--workers", "1", "--bind", "0.0.0.0:8005", "app:app"]

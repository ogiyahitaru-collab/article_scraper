FROM python:3.11-slim

# 1) ランタイムの健全化
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    TZ=Asia/Tokyo \
    LANG=C.UTF-8

# 2) セキュアな非rootユーザ
RUN adduser --disabled-password --gecos "" appuser

WORKDIR /app/github-guard

# 3) 依存を固定（将来は requirements.txt でpin推奨）
RUN pip install --no-cache-dir "pyyaml==6.0.2" "requests==2.32.3"

# 4) アプリ配置と権限
COPY . /app/github-guard
RUN chown -R appuser:appuser /app

USER appuser
CMD ["python","-u","main.py"]

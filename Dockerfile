FROM python:3.8-slim

WORKDIR /app

COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

RUN pip install transformers torch

VOLUME /app/models
VOLUME /app/data

COPY . /app

CMD ["python", "gpt_model.py"]

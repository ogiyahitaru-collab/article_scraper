run:
	docker run --rm \
		-v /volume2/docker/article_scraper:/app \
		-v /volume1/docker/article_scraper/config:/app/config \
		-v /volume1/docker/article_scraper/logs:/logs \
		-w /app \
		--env-file /app/config/.env \
		python:3.11-slim \
		bash -c "pip install -r requirements.txt && python src/main.py --keyword 日本 --limit 5" \
		>> /logs/$(shell date +%Y%m%d)_run.log 2>&1

clean:
	rm -rf __pycache__ */__pycache__ .pytest_cache .mypy_cache *.log output/* logs/*


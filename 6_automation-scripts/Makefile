.PHONY: setup lint test

setup:
	python -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt

lint:
	flake8 python
	shellcheck bash/**/*.sh || true

test:
	echo "No tests yet. Add pytest and unit tests here."

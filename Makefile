current-dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SHELL = /bin/sh
set-up:
	@if [ "$(uname)" == "Darwin" ]; then bash -c "brew update"; elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then bash -c "apt-get update"; fi
	@bash -c "pip install uv==0.5.4"
	@bash -c "uv venv --python 3.12.0"
	@bash -c "source .venv/bin/activate"
	@uv sync
install:
	@uv add $(dep)==$(ver)
uninstall:
	@uv remove $(dep)
start-airflow:
	@uv run astro dev start
stop-airflow:
	@uv run astro dev stop
restart-airflow:
	@uv run astro dev object import
	@uv run astro dev restart
run-tests:
	@uv run pytest dags/dbt/caspar_health_dbt_cosmos/tests/dags/
fix-format:
	@uv run ruff check --fix dags/dbt/caspar_health_dbt_cosmos/
	@uv run sqlfluff fix --dialect snowflake dags/dbt/caspar_health_dbt_cosmos/models/
docs:
	@uv run pytest dags/dbt/caspar_health_dbt_cosmos/tests/dags/test_dag_example.py  -vv --md=./docs/tests/index.md
docs-serve:
	@uv run mkdocs serve
.PHONY: set-up install uninstall start-airflow stop-airflow restart-airflow run-tests fix-format docs docs-serve
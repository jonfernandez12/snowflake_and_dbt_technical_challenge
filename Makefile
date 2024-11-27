current-dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SHELL = /bin/sh
set-up:
	@bash -c "sudo apt-get update"
	@bash -c "sudo pip install pipenv==2018.11.26"
	@bash -c "sudo apt-get -y install gcc build-essential"
	@bash -c "make install-deps"
start: install-deps
install-deps:
	@if [ -z $(shell which pipenv) ]; then echo "ERROR: missing software required (pip install pipenv)" > /dev/stderr && exit 1; fi
	@pipenv install --dev
install:
	@PIPENV_VENV_IN_PROJECT=1 pipenv install $(dep)==$(ver)
install-dev:
	@PIPENV_VENV_IN_PROJECT=1 pipenv install $(dep)==$(ver) --dev
uninstall:
	@pipenv uninstall $(dep)
remove:
	@pipenv --rm
run:
	@bash -c "pipenv run app"
run-tests:
	@bash -c "pipenv run test"
format:
	@pipenv run isort
	@pipenv run black
check-format:
	@pipenv run check-isort
	@pipenv run check-black
	@pipenv run check-flake8
check-types:
	@pipenv run check-types
docs:
	@pipenv run build-coverage-report
	@pipenv run build-linter-report
	@pipenv run build-docs
	@bash -c "mv htmlcov public/ && mv flake-report public/"
.PHONY: start install-deps install install-dev uninstall build deploy run run-tests format check-format check-types docs set-up
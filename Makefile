guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi


install: install-python install-hooks

install-python:
	poetry install

install-hooks: install-python
	poetry run pre-commit install --install-hooks --overwrite


lint: lint-sam-templates lint-python-scripts lint-python-code lint-github-actions lint-github-action-scripts

lint-sam-templates:
	poetry run cfn-lint -I "SAMtemplates/**/*.yaml" 2>&1 | grep "Run scan"

lint-python-scripts:
	poetry run flake8 scripts/*.py

lint-python-code:
	poetry run flake8 src/**/*.py

lint-github-actions:
	actionlint

lint-github-action-scripts:
	shellcheck .github/scripts/*.sh


clean:
	rm -rf .aws-sam

deep-clean: clean
	rm -rf venv
	poetry env remove --all


aws-configure:
	aws configure sso --region eu-west-2

aws-login:
	aws sso login --sso-session sso-session


check-licenses:
	scripts/check_python_licenses.sh

direnv-allow:
	touch .envrc || exit
	direnv allow .

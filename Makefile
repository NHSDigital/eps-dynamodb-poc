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


sam-build: sam-validate
	sam build --template-file SAMtemplates/main_template.yaml --region eu-west-2

sam-validate:
	sam validate --template-file SAMtemplates/main_template.yaml --region eu-west-2

sam-delete: guard-AWS_DEFAULT_PROFILE guard-STACK_NAME
	sam delete --stack-name $$STACK_NAME

sam-deploy: guard-AWS_DEFAULT_PROFILE guard-STACK_NAME
	sam deploy \
		--stack-name $$STACK_NAME

sam-list-outputs: guard-AWS_DEFAULT_PROFILE guard-STACK_NAME
	sam list stack-outputs --stack-name $$STACK_NAME

sam-list-resources: guard-AWS_DEFAULT_PROFILE guard-STACK_NAME
	sam list resources --stack-name $$STACK_NAME

sam-sync: guard-AWS_DEFAULT_PROFILE guard-STACK_NAME
	sam sync \
		--stack-name $$STACK_NAME \
		--watch \
		--template-file SAMtemplates/main_template.yaml

sam-deploy-package: guard-ARTIFACT_BUCKET guard-ARTIFACT_BUCKET_PREFIX guard-STACK_NAME guard-TEMPLATE_FILE guard-CLOUD_FORMATION_EXECUTION_ROLE
	sam deploy \
		--template-file $$TEMPLATE_FILE \
		--stack-name $$STACK_NAME \
		--capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
		--region eu-west-2 \
		--s3-bucket $$ARTIFACT_BUCKET \
		--s3-prefix $$ARTIFACT_BUCKET_PREFIX \
		--config-file samconfig_package_and_deploy.toml \
		--no-fail-on-empty-changeset \
		--role-arn $$CLOUD_FORMATION_EXECUTION_ROLE \
		--no-confirm-changeset \
		--force-upload


# Add python linting steps when appropriate
lint: lint-sam-templates lint-github-actions lint-github-action-scripts

lint-sam-templates:
	poetry run cfn-lint -I "SAMtemplates/**/*.y*ml" 2>&1 | awk '/Run scan/ { print } /^[EW][0-9]/ { print; getline; print }'

lint-python-scripts:
	poetry run flake8 scripts/*.py

lint-python-code:
	poetry run flake8 src/**/*.py

lint-github-actions:
	actionlint

lint-github-action-scripts:
	shellcheck .github/scripts/*.sh

test:
	pytest


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

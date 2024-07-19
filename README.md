# EPS DynamoDB POC

![Build](https://github.com/NHSDigital/eps-dynamodb-poc/actions/workflows/ci.yml/badge.svg?branch=main)  
![Release](https://github.com/NHSDigital/eps-dynamodb-poc/actions/workflows/release.yml/badge.svg?branch=main)

## Versions and deployments

Version release history can be found ot https://github.com/NHSDigital/eps-dynamodb-poc/releases.  
Deployment history can be found at https://nhsdigital.github.io/eps-dynamodb-poc/

## Introduction

This is a Proof of Concept for using DynamoDB (in place of Riak) as the datastore for the Spine EPS interaction.

- `scripts/` Utilities helpful to developers.
- `SAMtemplates/` Contains the SAM templates used to define the stacks.
- `.devcontainer` Contains a dockerfile and vscode devcontainer definition.
- `.github` Contains github workflows that are used for building and deploying from pull requests and releases.
- `.vscode` Contains vscode workspace file.

## Contributing
Contributions to this project are welcome from anyone. Please refer to the [guidelines for contribution](./CONTRIBUTING.md) and the [community code of conduct](./CODE_OF_CONDUCT.md).

### Licensing

This code is dual licensed under the MIT license and the OGL (Open Government License). Any new work added to this repository must conform to the conditions of these licenses. In particular this means that this project may not depend on GPL-licensed or AGPL-licensed libraries, as these would violate the terms of those libraries' licenses.

The contents of this repository are protected by Crown Copyright (C).

## Development

It is recommended that you use visual studio code and a devcontainer as this will install all necessary components and correct versions of tools and languages.  
See https://code.visualstudio.com/docs/devcontainers/containers for details on how to set this up on your host machine.  
The project uses [SAM](https://aws.amazon.com/serverless/sam/) to develop and deploy the APIs and associated resources.

All commits must be made using [signed commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits).

Once the steps at the link above have been completed. Add to your ~/.gnupg/gpg.conf as below:

```
use-agent
pinentry-mode loopback
```

and to your ~/.gnupg/gpg-agent.conf as below:

```
allow-loopback-pinentry
```

As described here:
https://stackoverflow.com/a/59170001

You will need to create the files, if they do not already exist.
This will ensure that your VSCode bash terminal prompts you for your GPG key password.

You can cache the gpg key passphrase by following instructions at https://superuser.com/questions/624343/keep-gnupg-credentials-cached-for-entire-user-session

### CI Setup

The GitHub Actions require a secret to exist on the repo called "SONAR_TOKEN".
This can be obtained from [SonarCloud](https://sonarcloud.io/)
as described [here](https://docs.sonarsource.com/sonarqube/latest/user-guide/user-account/generating-and-using-tokens/).
You will need the "Execute Analysis" permission for the project (NHSDigital_eps-prescription-status-update-api) in order for the token to work.

### Pre-commit hooks

Some pre-commit hooks are installed as part of the install above, to run basic lint checks and ensure you can't accidentally commit invalid changes.
The pre-commit hook uses python package pre-commit and is configured in the file .pre-commit-config.yaml.
A combination of these checks are also run in CI.

### Make commands

There are `make` commands that are run as part of the CI pipeline and help alias some functionality during development.

#### Install targets

- `install-python` Installs python dependencies
- `install-hooks` Installs git pre-commit hooks
- `install` Runs all install targets

#### SAM targets

These are used to invoke common commands:

- `sam-build` Prepares the lambdas and SAM definition file to be used in subsequent steps.
- `sam-validate` Validates the main SAM template.

These need AWS_DEFAULT_PROFILE and STACK_NAME environment variables set:

- `sam-delete` Deletes the deployed SAM cloud formation stack and associated resources.
- `sam-deploy` Deploys the compiled SAM template from sam-build to AWS.
- `sam-list-outputs` Lists outputs from the current stack.
- `sam-list-resources` Lists resources created for the current stack.
- `sam-sync` Sync to the current stack deployed in AWS. This keeps running and automatically uploads any changes to the table made locally.

- `sam-deploy-package` Deploys a package created by sam-build. Used in CI builds. Needs the following environment variables set.
  - ARTIFACT_BUCKET - bucket where uploaded packaged files are
  - ARTIFACT_BUCKET_PREFIX - prefix in bucket of where uploaded packaged files ore
  - STACK_NAME - name of stack to deploy
  - TEMPLATE_FILE - name of template file created by sam-package
  - CLOUD_FORMATION_EXECUTION_ROLE - ARN of role that cloud formation assumes when applying the changeset

#### Clean and deep-clean targets

- `clean` Clears up any files that have been generated by building or testing locally.
- `deep-clean` Runs clean target and removes any python libraries installed locally.

#### Linting and testing

- `lint` Runs lint for all code
- `lint-github-actions` Runs lint for github actions workflows
- `lint-github-action-scripts` Runs shellcheck for github actions scripts
- `lint-python` Runs lint for python code
- `lint-sam-templates` Runs lint for SAM templates
- `test` Runs unit tests for all code

#### Check licenses

- `check-licenses` Checks licenses for all python code

#### CLI Login to AWS

- `aws-configure` Configures a connection to AWS
- `aws-login` Reconnects to AWS from a previously configured connection

### Github folder

This .github folder contains workflows and templates related to GitHub, along with actions and scripts pertaining to Jira.

- `pull_request_template.yml` Template for pull requests.
- `dependabot.yml` Dependabot definition file.

Scripts are in the `.github/scripts` folder:

- `delete_stacks.sh` Checks and deletes active CloudFormation stacks associated with closed pull requests.
- `deploy_code.sh` Releases code by deploying it using AWS SAM after packaging it.

Workflows are in the `.github/workflows` folder:

- `ci.yml` Workflow run when code merged to main. Deploys to dev and qa environments.
- `combine_dependabot_prs.yml` Workflow for combining dependabot pull requests. Runs on demand.
- `delete_old_cloudformation_stacks.yml` Workflow for deleting old cloud formation stacks. Runs daily.
- `dependabot_auto_approve_and_merge.yml` Workflow to auto merge dependabot updates.
- `deploy_code.yml` Release code and api built by package_and_upload_code.yml to an environment.
- `package_and_upload_code.yml` Packages code and api and uploads to a github artifact for later deployment.
- `pr_title_check.yaml` Checks title of pull request is valid.
- `pr_link_ticket.yaml` This workflow template links Pull Requests to Jira tickets and runs when a pull request is opened.
- `pull_request.yml` Called when pull request is opened or updated. Calls package_and_upload_code and deploy_code to build and deploy the code. Deploys to dev AWS account. The main stack deployed adopts the naming convention ddb-pr-<PULL_REQUEST_ID>.
- `quality_checks.yml` Runs check-licenses, lint, test and SonarCloud scan against the repo. Called from ci.yml, pull_request.yml and release.yml
- `release.yml` Runs on demand to create a release and deploy to all environments.

#!/usr/bin/env bash

echo "$COMMIT_ID"

ARTIFACT_BUCKET=$(aws cloudformation list-exports --output json | jq -r '.Exports[] | select(.Name == "account-resources:ArtifactsBucket") | .Value' | grep -o '[^:]*$')
export ARTIFACT_BUCKET

CLOUD_FORMATION_EXECUTION_ROLE=$(aws cloudformation list-exports --output json | jq -r '.Exports[] | select(.Name == "ci-resources:CloudFormationExecutionRole") | .Value' )
export CLOUD_FORMATION_EXECUTION_ROLE

cd ../../.aws-sam/build || exit
make sam-deploy-package

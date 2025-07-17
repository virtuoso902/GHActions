#!/bin/bash
set -e

# Configuration
RUNNER_NAME=${RUNNER_NAME:-"ephemeral-runner-$(date +%s)"}
RUNNER_WORKDIR=${RUNNER_WORKDIR:-"/home/runner/_work"}
RUNNER_GROUP=${RUNNER_GROUP:-"default"}
LABELS=${LABELS:-"self-hosted,Linux,X64,ephemeral"}
EPHEMERAL=${EPHEMERAL:-"true"}

# Required environment variables
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN is required"
    exit 1
fi

if [ -z "$GITHUB_REPOSITORY" ] && [ -z "$GITHUB_ORGANIZATION" ]; then
    echo "Error: Either GITHUB_REPOSITORY or GITHUB_ORGANIZATION must be set"
    exit 1
fi

# Determine registration URL
if [ -n "$GITHUB_REPOSITORY" ]; then
    REGISTRATION_URL="https://github.com/${GITHUB_REPOSITORY}"
    API_URL="https://api.github.com/repos/${GITHUB_REPOSITORY}/actions/runners/registration-token"
else
    REGISTRATION_URL="https://github.com/${GITHUB_ORGANIZATION}"
    API_URL="https://api.github.com/orgs/${GITHUB_ORGANIZATION}/actions/runners/registration-token"
fi

echo "Requesting registration token..."
REGISTRATION_TOKEN=$(curl -sX POST \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    "${API_URL}" | jq -r .token)

if [ -z "$REGISTRATION_TOKEN" ] || [ "$REGISTRATION_TOKEN" = "null" ]; then
    echo "Error: Failed to get registration token"
    exit 1
fi

echo "Configuring runner..."
./config.sh \
    --url "${REGISTRATION_URL}" \
    --token "${REGISTRATION_TOKEN}" \
    --name "${RUNNER_NAME}" \
    --work "${RUNNER_WORKDIR}" \
    --labels "${LABELS}" \
    --runnergroup "${RUNNER_GROUP}" \
    --unattended \
    --replace \
    $([ "$EPHEMERAL" = "true" ] && echo "--ephemeral")

# Cleanup function
cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token "${REGISTRATION_TOKEN}" || true
}

# Set up cleanup on exit
trap cleanup EXIT

echo "Starting runner..."
./run.sh
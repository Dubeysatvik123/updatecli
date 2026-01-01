#!/bin/bash

# Script to update the workflow file with environment variables

WORKFLOW_FILE=".github/workflows/job.yml"

if [ ! -f "$WORKFLOW_FILE" ]; then
    echo "Error: Workflow file not found at $WORKFLOW_FILE"
    exit 1
fi

# Backup the original
cp "$WORKFLOW_FILE" "${WORKFLOW_FILE}.bak"

# Add environment variables to the updatecli step
sed -i '/- name: Run Updatecli for Docker Compose Version/a\        env:\n          GITHUB_ACTOR: "Dubeysatvik123"\n          GITHUB_EMAIL: "satvikdubey268@gmail.com"\n          GITHUB_OWNER: "Dubeysatvik123"\n          GITHUB_REPO: "updatecli"' "$WORKFLOW_FILE"

echo "Updated $WORKFLOW_FILE with environment variables"
echo "Backup saved as ${WORKFLOW_FILE}.bak"

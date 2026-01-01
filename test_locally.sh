#!/bin/bash

# Script to test Updatecli locally







s
echo "Testing Updatecli configuration locally..."
echo ""

# Check if updatecli is installed
if ! command -v updatecli &> /dev/null; then
    echo "Updatecli is not installed. Installing..."
    curl -sL https://github.com/updatecli/updatecli/releases/latest/download/updatecli_Linux_x86_64.tar.gz | tar xz
    sudo mv updatecli /usr/local/bin/
fi

# Check if TOKEN_GITHUB is set
if [ -z "$TOKEN_GITHUB" ]; then
    echo "Error: TOKEN_GITHUB environment variable is not set"
    echo "Please set it with: export TOKEN_GITHUB=your_token_here"
    exit 1
fi

# Set environment variables for the configuration
export GITHUB_ACTOR="Dubeysatvik123"
export GITHUB_EMAIL="satvikdubey268@gmail.com"
export GITHUB_OWNER="Dubeysatvik123"
export GITHUB_REPO="updatecli"

echo "Configuration:"
echo "  User: $GITHUB_ACTOR"
echo "  Email: $GITHUB_EMAIL"
echo "  Repo: $GITHUB_OWNER/$GITHUB_REPO"
echo ""

# Run updatecli in dry-run mode first
echo "Running in dry-run mode..."
updatecli diff --config update_docker_compose_version.yml

echo ""
echo "To apply changes, run:"
echo "  updatecli apply --config update_docker_compose_version.yml"

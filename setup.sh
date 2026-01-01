#!/bin/bash
set -e

echo "=================================="
echo "Updatecli Project Setup Script"
echo "=================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if we're in the right directory
if [ ! -d ".git" ]; then
    print_error "Error: Not in a git repository. Please run this script from your project root."
    exit 1
fi

echo "Creating/Updating project files..."
echo ""

# 1. Create README.md
print_status "Creating README.md..."
cat > README.md << 'EOF'
# Docker Compose Version Tracker

This repository uses [Updatecli](https://www.updatecli.io/) to automatically track and update the Docker Compose version.

## How It Works

1. **Scheduled Check**: GitHub Actions runs daily at 5 AM UTC
2. **Version Detection**: Updatecli checks the installed Docker Compose version
3. **Automatic Update**: If a new version is detected, it updates `versions/docker-compose.yaml`
4. **Pull Request**: A PR is automatically created with the changes

## Files

- `.github/workflows/job.yml` - GitHub Actions workflow
- `update_docker_compose_version.yml` - Updatecli configuration
- `versions/docker-compose.yaml` - Tracked Docker Compose version

## Manual Execution

You can manually trigger the workflow from the GitHub Actions tab.

## Requirements

- GitHub repository secrets:
  - `TOKEN_GITHUB` - Personal Access Token with `repo` and `workflow` scopes
  - `USERNAME_GIT` - Your GitHub username
  - `MAIL_GIT` - Your Git email

## Local Testing

```bash
# Install Updatecli
curl -sL https://github.com/updatecli/updatecli/releases/latest/download/updatecli_Linux_x86_64.tar.gz | tar xz
sudo mv updatecli /usr/local/bin/

# Set your GitHub token
export GITHUB_TOKEN=your_token_here

# Run Updatecli
updatecli apply --config update_docker_compose_version.yml
```

## License

MIT
EOF

# 2. Create versions directory and docker-compose.yaml
print_status "Creating versions/docker-compose.yaml..."
mkdir -p versions
cat > versions/docker-compose.yaml << 'EOF'
docker_compose:
  version: "" # Will be managed by Updatecli
EOF

# 3. Create .github/workflows directory and job.yml
print_status "Creating .github/workflows/job.yml..."
mkdir -p .github/workflows
cat > .github/workflows/job.yml << 'EOF'
name: Run Updatecli

on:
  push:
    branches:
      - main
  workflow_dispatch:
  schedule:
    - cron: '0 5 * * *' # every day at 5am UTC

jobs:
  updatecli:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          
      - name: Install Updatecli
        run: |
          curl -sL https://github.com/updatecli/updatecli/releases/latest/download/updatecli_Linux_x86_64.tar.gz | tar xz
          sudo mv updatecli /usr/local/bin/
          updatecli version
          
      - name: Install Docker Compose
        run: |
          sudo apt-get update
          sudo apt-get install -y docker-compose-plugin || sudo apt-get install -y docker-compose || true
          docker compose version || docker-compose version
          
      - name: Run Updatecli for Docker Compose Version
        env:
          GITHUB_TOKEN: ${{ secrets.TOKEN_GITHUB }}
        run: |
          updatecli apply --config update_docker_compose_version.yml
EOF

# 4. Create update_docker_compose_version.yml
print_status "Creating update_docker_compose_version.yml..."
cat > update_docker_compose_version.yml << 'EOF'
name: "Update Docker Compose Version in versions/docker-compose.yaml"

scms:
  default:
    kind: github
    spec:
      user: "{{ requiredEnv `GITHUB_ACTOR` }}"
      email: "{{ requiredEnv `GITHUB_EMAIL` }}"
      owner: "{{ requiredEnv `GITHUB_OWNER` }}"
      repository: "{{ requiredEnv `GITHUB_REPO` }}"
      token: "{{ requiredEnv `GITHUB_TOKEN` }}"
      branch: main

sources:
  dockerComposeVersion:
    kind: shell
    name: Get installed Docker Compose version
    spec:
      command: |
        docker compose version --short 2>/dev/null || docker-compose version --short

conditions: {}

targets:
  updateDockerComposeVersion:
    name: Update Docker Compose version in versions/docker-compose.yaml
    kind: yaml
    sourceid: dockerComposeVersion
    scmid: default
    spec:
      file: versions/docker-compose.yaml
      key: $.docker_compose.version

actions:
  githubPR:
    kind: github/pullrequest
    scmid: default
    title: "chore: update docker-compose version to {{ source `dockerComposeVersion` }}"
    spec:
      automerge: false
      mergemethod: squash
      labels:
        - dependencies
        - automated
      description: |
        ## Docker Compose Version Update
        
        This PR updates the tracked Docker Compose version.
        
        **New Version**: `{{ source "dockerComposeVersion" }}`
        
        ### Changes
        - Updated `versions/docker-compose.yaml`
        
        ### Automation
        - Generated by [Updatecli](https://www.updatecli.io/)
        - Triggered by: Scheduled workflow
        
        ---
        
        Please review and merge if the version is correct.
EOF

# 5. Create alternative configuration with hardcoded values
print_status "Creating update_docker_compose_version_hardcoded.yml (backup)..."
cat > update_docker_compose_version_hardcoded.yml << 'EOF'
name: "Update Docker Compose Version in versions/docker-compose.yaml"

scms:
  default:
    kind: github
    spec:
      user: "Dubeysatvik123"
      email: "satvikdubey268@gmail.com"
      owner: "Dubeysatvik123"
      repository: "updatecli"
      token: "{{ requiredEnv `GITHUB_TOKEN` }}"
      branch: main

sources:
  dockerComposeVersion:
    kind: shell
    name: Get installed Docker Compose version
    spec:
      command: |
        docker compose version --short 2>/dev/null || docker-compose version --short

conditions: {}

targets:
  updateDockerComposeVersion:
    name: Update Docker Compose version in versions/docker-compose.yaml
    kind: yaml
    sourceid: dockerComposeVersion
    scmid: default
    spec:
      file: versions/docker-compose.yaml
      key: $.docker_compose.version

actions:
  githubPR:
    kind: github/pullrequest
    scmid: default
    title: "chore: update docker-compose version to {{ source `dockerComposeVersion` }}"
    spec:
      automerge: false
      mergemethod: squash
      labels:
        - dependencies
        - automated
      description: |
        ## Docker Compose Version Update
        
        This PR updates the tracked Docker Compose version.
        
        **New Version**: `{{ source "dockerComposeVersion" }}`
        
        ### Changes
        - Updated `versions/docker-compose.yaml`
        
        ### Automation
        - Generated by [Updatecli](https://www.updatecli.io/)
        - Triggered by: Scheduled workflow
        
        ---
        
        Please review and merge if the version is correct.
EOF

# 6. Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    print_status "Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Updatecli
.updatecli/
updatecli_*

# OS files
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Temporary files
*.tmp
*.bak
EOF
fi

# 7. Create a local test script
print_status "Creating test_locally.sh..."
cat > test_locally.sh << 'EOF'
#!/bin/bash

# Script to test Updatecli locally

echo "Testing Updatecli configuration locally..."
echo ""

# Check if updatecli is installed
if ! command -v updatecli &> /dev/null; then
    echo "Updatecli is not installed. Installing..."
    curl -sL https://github.com/updatecli/updatecli/releases/latest/download/updatecli_Linux_x86_64.tar.gz | tar xz
    sudo mv updatecli /usr/local/bin/
fi

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable is not set"
    echo "Please set it with: export GITHUB_TOKEN=your_token_here"
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
EOF

chmod +x test_locally.sh

# 8. Create GitHub Actions workflow updater helper
print_status "Creating update_workflow_env.sh..."
cat > update_workflow_env.sh << 'EOF'
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
EOF

chmod +x update_workflow_env.sh

echo ""
echo "=================================="
print_status "Setup Complete!"
echo "=================================="
echo ""
echo "Files created/updated:"
echo "  ✓ README.md"
echo "  ✓ versions/docker-compose.yaml"
echo "  ✓ .github/workflows/job.yml"
echo "  ✓ update_docker_compose_version.yml"
echo "  ✓ update_docker_compose_version_hardcoded.yml (backup)"
echo "  ✓ .gitignore"
echo "  ✓ test_locally.sh"
echo "  ✓ update_workflow_env.sh"
echo ""
echo "Next steps:"
echo "  1. Update GitHub Secrets:"
print_warning "     Go to: Settings > Secrets and variables > Actions"
echo "     Add these secrets:"
echo "       - TOKEN_GITHUB: Your GitHub Personal Access Token"
echo "       - USERNAME_GIT: Dubeysatvik123"
echo "       - MAIL_GIT: satvikdubey268@gmail.com"
echo ""
echo "  2. Ensure TOKEN_GITHUB has these scopes:"
echo "       - repo (full control)"
echo "       - workflow"
echo ""
echo "  3. Test locally (optional):"
echo "       export GITHUB_TOKEN=your_token_here"
echo "       ./test_locally.sh"
echo ""
echo "  4. Commit and push:"
echo "       git add ."
echo "       git commit -m 'chore: setup updatecli automation'"
echo "       git push origin main"
echo ""
echo "  5. Manually trigger workflow:"
print_warning "     Go to: Actions > Run Updatecli > Run workflow"
echo ""
echo "=================================="

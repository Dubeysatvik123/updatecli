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

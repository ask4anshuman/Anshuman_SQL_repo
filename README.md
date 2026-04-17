# Anshuman SQL Repo

This repository stores SQL files and automatically publishes SQL documentation to Confluence through GitHub Actions.

## What This Repo Contains

- SQL source files (for example, `sample_query.sql`)
- Workflow config for SQL doc preview and publish
- Confluence publish configuration at `.github/sql_confluence.yml`

## Automation Flows

- PR preview comment workflow: `.github/workflows/sql-doc-preview-pr.yml`
- Publish on merge workflow: `.github/workflows/sql-doc-publish-on-merge.yml`

Both workflows check out the external summarization tool from:

- `ask4anshuman/Code-Summarization-Project`

The requirements file referenced in workflow is from that external tool checkout:

- `sql-doc-tool/requirements.txt`

## Required GitHub Secrets

Configure these in repository settings:

- `LLM_API_KEY`
- `CONFLUENCE_USERNAME`
- `CONFLUENCE_API_TOKEN`
- `TOOL_REPO_TOKEN` (needed when the external tool repository is private)

`GITHUB_TOKEN` is provided automatically by GitHub Actions.

## How To Configure Secrets

1. Open repository on GitHub.
2. Go to **Settings -> Secrets and variables -> Actions**.
3. Add each secret with exact names listed above.

## Notes

- The workflow publishes only for merged PRs.
- SQL file filtering happens inside the summarization tool when PR number is provided.

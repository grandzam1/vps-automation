# Grandzam VPS Automation

Small helper scripts for repetitive tasks on the Grandzam Hestia VPS.  
Default GitHub org: **grandzam1**

## Install

```bash
cd /home/root1/vps-automation
sudo ./bin/gzb-install
```

This installs:

| Command | Purpose |
|---------|---------|
| `gzb-sync <app-path> [branch]` | `git pull` preserving `.env`, then clear Laravel caches |
| `gzb-laravel-refresh <app-path>` | `config:clear`, `view:clear`, `route:clear`, `cache:clear` |
| `gzb-apps` | Git status for all projects in `projects.conf` |

## Project manifest

Edit `projects.conf` when adding a new site:

```
# name | path | github_repo
myapp | /home/user/web/example.com/public_html | https://github.com/grandzam1/myapp
```

## Examples

```bash
# Pull latest plus code (keeps server .env)
gzb-sync /home/root1/web/plus.tidebridges.com/public_html

# Clear caches after manual edits
gzb-laravel-refresh /home/root1/web/grandbank.tidebridges.com/public_html

# Overview of all registered projects
gzb-apps
```

## Existing server scripts (not in this repo yet)

These live on the server under `/usr/local/bin/`:

- `hestia-laravel-https` — configure Laravel HTTPS behind Traefik
- `hestia-cloudflare-sync` — sync Hestia DNS to Cloudflare

Consider migrating them into this repo in a future update.

## Policy

All new VPS projects and automation should have a **grandzam1** GitHub repository for change tracking.

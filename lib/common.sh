#!/bin/bash
# Shared helpers for Grandzam VPS automation scripts.

set -euo pipefail

GZB_APPS_MANIFEST="${GZB_APPS_MANIFEST:-/usr/local/lib/vps-automation/projects.conf}"
if [[ ! -f "$GZB_APPS_MANIFEST" ]]; then
  GZB_APPS_MANIFEST="/home/root1/vps-automation/projects.conf"
fi

gzb_die() {
  echo "error: $*" >&2
  exit 1
}

gzb_info() {
  echo "==> $*"
}

gzb_require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || gzb_die "required command not found: $cmd"
}

gzb_app_owner() {
  local app_path="$1"
  stat -c '%U' "$app_path" 2>/dev/null || echo "root"
}

gzb_laravel_refresh() {
  local app_path="${1%/}"
  [[ -f "$app_path/artisan" ]] || gzb_die "not a Laravel app: $app_path"

  local owner
  owner="$(gzb_app_owner "$app_path")"
  gzb_info "clearing Laravel caches in $app_path (user: $owner)"

  sudo -u "$owner" php "$app_path/artisan" config:clear >/dev/null 2>&1 || php "$app_path/artisan" config:clear
  sudo -u "$owner" php "$app_path/artisan" view:clear >/dev/null 2>&1 || php "$app_path/artisan" view:clear
  sudo -u "$owner" php "$app_path/artisan" route:clear >/dev/null 2>&1 || true
  sudo -u "$owner" php "$app_path/artisan" cache:clear >/dev/null 2>&1 || true

  echo "Laravel caches cleared: $app_path"
}

gzb_git_sync_pull() {
  local app_path="${1%/}"
  local branch="${2:-}"

  [[ -d "$app_path/.git" ]] || gzb_die "not a git repo: $app_path"

  local owner
  owner="$(gzb_app_owner "$app_path")"

  gzb_info "syncing $app_path"

  if [[ -f "$app_path/.env" ]]; then
    cp "$app_path/.env" "/tmp/.env.backup.$(basename "$app_path").$$"
  fi

  sudo -u "$owner" git -C "$app_path" fetch origin

  if [[ -n "$branch" ]]; then
    sudo -u "$owner" git -C "$app_path" checkout "$branch"
  fi

  local current_branch
  current_branch="$(sudo -u "$owner" git -C "$app_path" rev-parse --abbrev-ref HEAD)"

  sudo -u "$owner" git -C "$app_path" pull --ff-only origin "$current_branch"

  if [[ -f "/tmp/.env.backup.$(basename "$app_path").$$" ]]; then
    cp "/tmp/.env.backup.$(basename "$app_path").$$" "$app_path/.env"
    rm -f "/tmp/.env.backup.$(basename "$app_path").$$"
  fi

  echo "synced: $app_path ($current_branch)"
}

gzb_git_status_short() {
  local app_path="${1%/}"
  local owner
  owner="$(gzb_app_owner "$app_path")"
  sudo -u "$owner" git -C "$app_path" status -sb 2>/dev/null || echo "no-git"
}

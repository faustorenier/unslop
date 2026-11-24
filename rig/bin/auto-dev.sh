#!/usr/bin/env bash
# Runs rig:auto-dev in a new headless Claude session per issue until DONE, FAILED or the limit.
set -uo pipefail

usage='usage: auto-dev <Linear project> [max-issues] [base-branch]'

slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g'
}

# Herdr hands out a closed id only once, so anything missing from the snapshot was opened by this run.
list_tabs() { herdr tab list --workspace "$workspace" | jq -r '.result.tabs[].tab_id' | sort; }
list_panes() { herdr pane list --workspace "$workspace" | jq -r '.result.panes[].pane_id' | sort; }

snapshot() {
  tabs_at_start=$(list_tabs)
  panes_at_start=$(list_panes)
}

close_opened() {
  local id
  for id in $(comm -13 <(printf '%s\n' "$tabs_at_start") <(list_tabs)); do
    herdr tab close "$id" >/dev/null && echo "auto-dev: tab $id closed"
  done
  for id in $(comm -13 <(printf '%s\n' "$panes_at_start") <(list_panes)); do
    herdr pane close "$id" >/dev/null && echo "auto-dev: pane $id closed"
  done
}

# A failed run keeps its tabs so the agents can be read afterwards; the loop ends either way.
leave_open() {
  echo "auto-dev: keeping this run's Herdr tabs open so you can inspect them" >&2
}

run_once() {
  log="$log_dir/$(date +%Y%m%d-%H%M%S).log"
  echo "auto-dev: starting run $((merged + 1)), logging to $log"
  snapshot
  claude -p "/rig:auto-dev $project --base $base" --permission-mode auto 2>&1 | tee "$log"
  verdict=$(grep -E '^AUTO_DEV: ' "$log" | tail -n 1)
}

handle_verdict() {
  case "$verdict" in
    "AUTO_DEV: DONE"*)
      close_opened
      echo "auto-dev: $project has no issues left; this loop merged $merged"
      [[ "$base" != main ]] && echo "auto-dev: the PR waits for your review and merge: gh pr view $base --web"
      exit 0
      ;;
    "AUTO_DEV: NEXT"*)
      close_opened
      merged=$((merged + 1))
      echo "auto-dev: ${verdict#AUTO_DEV: NEXT } landed on $base (total so far: $merged)"
      if (( limit > 0 && merged >= limit )); then
        echo "auto-dev: stopping at the limit of $limit issue(s)"
        exit 0
      fi
      ;;
    "AUTO_DEV: FAILED"*)
      leave_open
      echo "auto-dev: stopped: ${verdict#AUTO_DEV: FAILED }" >&2
      exit 1
      ;;
    *)
      leave_open
      echo "auto-dev: no verdict at the end of the session, read $log" >&2
      exit 1
      ;;
  esac
}

main() {
  project="${1:?$usage}"
  limit="${2:-0}"
  base="${3:-auto/$(slugify "$project")}"

  cd "$(git rev-parse --show-toplevel)" || exit 2
  if [[ "${HERDR_ENV:-}" != 1 ]]; then
    echo "auto-dev: start this from a Herdr pane (HERDR_ENV=1)" >&2
    exit 2
  fi
  "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/preflight.sh" || exit 2

  log_dir=".auto-dev"
  mkdir -p "$log_dir"
  merged=0
  workspace="$HERDR_WORKSPACE_ID"

  while true; do
    run_once
    handle_verdict
  done
}

main "$@"

#!/usr/bin/env bash
# One fresh Claude session per Linear issue (skill auto-dev); stops on DONE, FAILED or max-issues.
set -uo pipefail

project="${1:?usage: auto-dev <Linear project> [max-issues] [base-branch]}"
max="${2:-0}"
slug=$(printf '%s' "$project" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')
base="${3:-auto/$slug}"

cd "$(git rev-parse --show-toplevel)" || exit 2
[[ "${HERDR_ENV:-}" == 1 ]] || { echo "auto-dev: run this inside Herdr (HERDR_ENV=1)" >&2; exit 2; }
"$(dirname "$(realpath "${BASH_SOURCE[0]}")")/preflight.sh" || exit 2

logs=".auto-dev"
mkdir -p "$logs"
count=0
workspace="$HERDR_WORKSPACE_ID"

# Herdr never reuses a closed id, so a set difference isolates exactly what this run opened.
tab_ids() { herdr tab list --workspace "$workspace" | jq -r '.result.tabs[].tab_id' | sort; }
pane_ids() { herdr pane list --workspace "$workspace" | jq -r '.result.panes[].pane_id' | sort; }

close_new_herdr() {
  local tab pane
  for tab in $(comm -13 <(printf '%s\n' "$tabs_before") <(tab_ids)); do
    herdr tab close "$tab" >/dev/null && echo "auto-dev: closed tab $tab"
  done
  for pane in $(comm -13 <(printf '%s\n' "$panes_before") <(pane_ids)); do
    herdr pane close "$pane" >/dev/null && echo "auto-dev: closed pane $pane"
  done
}

while true; do
  log="$logs/$(date +%Y%m%d-%H%M%S).log"
  echo "auto-dev: run $((count + 1)), log in $log"
  tabs_before=$(tab_ids)
  panes_before=$(pane_ids)

  claude -p "/rig:auto-dev $project --base $base" --permission-mode auto 2>&1 | tee "$log"
  verdict=$(grep -E '^AUTO_DEV: ' "$log" | tail -n 1)

  # Tabs of a failed run stay open, so the user can read the agents; the loop stops anyway.
  case "$verdict" in
    "AUTO_DEV: NEXT"* | "AUTO_DEV: DONE"*) close_new_herdr ;;
    *) echo "auto-dev: left this run's Herdr tabs open for inspection" >&2 ;;
  esac

  case "$verdict" in
    "AUTO_DEV: DONE"*)
      echo "auto-dev: nothing left in $project after $count issue(s)"
      [[ "$base" != main ]] && echo "auto-dev: review and merge the PR: gh pr view $base --web"
      exit 0
      ;;
    "AUTO_DEV: NEXT"*)
      count=$((count + 1))
      echo "auto-dev: ${verdict#AUTO_DEV: NEXT } merged into $base ($count so far)"
      if (( max > 0 && count >= max )); then
        echo "auto-dev: reached the limit of $max issue(s)"
        exit 0
      fi
      ;;
    "AUTO_DEV: FAILED"*)
      echo "auto-dev: stopped: ${verdict#AUTO_DEV: FAILED }" >&2
      exit 1
      ;;
    *)
      echo "auto-dev: the session ended without a verdict, see $log" >&2
      exit 1
      ;;
  esac
done

#!/usr/bin/env bash
# Fails fast, before any agent spends quota. Usage: preflight.sh [--skip-verify]
set -uo pipefail

skip_verify=0
[[ "${1:-}" == "--skip-verify" ]] && skip_verify=1

cd "$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "preflight: not inside a git repository" >&2; exit 1; }

failures=()
ok() { echo "  ok    $1"; }
fail() { echo "  FAIL  $1 -> $2"; failures+=("$1"); }
has() { command -v "$1" >/dev/null 2>&1; }

echo "preflight:"

if has jq; then ok "jq"; else fail "jq" "brew install jq"; fi

if git ls-remote -q origin HEAD >/dev/null 2>&1; then ok "git origin reachable"
else fail "git origin" "check the remote and your network (git remote -v)"; fi

if has gh && gh auth status >/dev/null 2>&1; then ok "gh authenticated"
else fail "gh" "install gh and run: gh auth login"; fi

if has linear && linear auth whoami --no-input >/dev/null 2>&1; then
  ok "linear authenticated"
  team=$(linear team id --no-input 2>/dev/null)
  if [[ ! -f .linear.toml || -z "$team" ]]; then
    fail "linear team" "run: linear config --team <KEY> --sort manual --no-input, then commit .linear.toml"
  elif grep -q "^In Review " <<<"$(linear team states "$team" --no-input 2>/dev/null)"; then
    ok "linear team $team has In Review"
  else
    fail "linear team $team" "add an In Review status (type started) in the team's workflow settings"
  fi
else
  fail "linear" "install linear and run: linear auth login"
fi

herdr_status=$(herdr status 2>/dev/null)
if [[ "${HERDR_ENV:-}" == 1 && "$herdr_status" == *"status: running"* ]]; then ok "inside a running Herdr"
else fail "herdr" "start herdr and run this from one of its panes"; fi

# Personal, gitignored loop-models.local.json replaces the shared config role by role.
models='{}'
for config in loop-models.json loop-models.local.json; do
  [[ -f "$config" ]] && has jq || continue
  if jq -e . "$config" >/dev/null 2>&1; then
    models=$(jq -s '.[0] + .[1]' <(printf '%s' "$models") "$config")
    ok "$config is valid JSON"
  else
    fail "$config" "fix the JSON syntax"
  fi
done

role_field() { has jq && jq -r ".$1.$2 // empty" <<<"$models"; }
developer=$(role_field developer tool); developer=${developer:-opencode}
reviewer=$(role_field reviewer tool); reviewer=${reviewer:-claude}

for tool in $(printf '%s\n%s\n' "$developer" "$reviewer" | sort -u); do
  case "$tool" in
    claude | opencode)
      if has "$tool"; then ok "$tool installed"; else fail "$tool" "install $tool"; fi
      ;;
    *) fail "tool $tool" "loop-models supports only claude and opencode" ;;
  esac
done

if has opencode && [[ "$developer $reviewer" == *opencode* ]]; then
  opencode_models=$(opencode models 2>/dev/null)
  for role in developer reviewer; do
    [[ $(role_field "$role" tool) == opencode ]] || continue
    model=$(role_field "$role" model)
    [[ -z "$model" ]] && continue
    if grep -qxF "$model" <<<"$opencode_models"; then ok "opencode model $model"
    else fail "opencode model $model" "pick one listed by: opencode models"; fi
  done
fi

# npm rewrites node_modules/.package-lock.json on every install, so it dates the last install.
if [[ ! -f package-lock.json ]]; then :
elif [[ ! -d node_modules ]]; then fail "node_modules" "npm install"
elif [[ package-lock.json -nt node_modules/.package-lock.json ]]; then
  fail "node_modules" "package-lock.json changed since the last install: npm install"
else ok "node_modules up to date"; fi

if (( skip_verify )); then
  echo "  skip  verification commands"
else
  # The commands are the shell block under "## Verification" in CLAUDE.md.
  verify=$(awk '/^## Verification/{f=1; next} f && /^```/{if (b) exit; b=1; next} f && b' CLAUDE.md 2>/dev/null \
    | grep -v '^[[:space:]]*\(#\|$\)')
  if [[ -z "$verify" ]]; then
    fail "verification" "add commands to the ## Verification block of CLAUDE.md, then run /rig:init"
  else
    while IFS= read -r cmd; do
      [[ -z "$cmd" ]] && continue
      if bash -c "$cmd" >/dev/null 2>&1; then ok "$cmd"
      else fail "$cmd" "fix it on $(git branch --show-current) before starting"; fi
    done <<<"$verify"
  fi
fi

if (( ${#failures[@]} )); then
  echo "preflight: ${#failures[@]} problem(s), nothing started" >&2
  exit 1
fi
echo "preflight: all good"

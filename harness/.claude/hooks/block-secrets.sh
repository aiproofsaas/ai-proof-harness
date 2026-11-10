#!/bin/sh
# Stops Claude from writing a secret into any file except .dev.vars.
# Claude Code sends the planned write as JSON on stdin. Exit 2 blocks it.

input=$(cat)

target=$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
case "$target" in
  */.dev.vars|.dev.vars|*\\.dev.vars) exit 0 ;;
esac

block() {
  echo "Blocked: this would put a secret in $target. Secrets only go in .dev.vars and Cloudflare secrets." >&2
  exit 2
}

# Known key shapes.
printf '%s' "$input" | grep -Eq 'sk-ant-[A-Za-z0-9_-]{8,}' && block
printf '%s' "$input" | grep -Eq '(CLOUDFLARE_API_TOKEN|ACCESS_CODE)(\\?")?[[:space:]]*[=:][[:space:]]*(\\?")?[A-Za-z0-9_-]{6,}' && block

# Any value already stored in .dev.vars.
vars="${CLAUDE_PROJECT_DIR:-.}/.dev.vars"
if [ -f "$vars" ]; then
  sed -n 's/^[A-Za-z_][A-Za-z0-9_]*=//p' "$vars" | tr -d '"'"'"'\r' | while IFS= read -r value; do
    [ ${#value} -ge 6 ] || continue
    if printf '%s' "$input" | grep -Fq -- "$value"; then
      exit 3
    fi
  done
  [ $? -eq 3 ] && block
fi

exit 0

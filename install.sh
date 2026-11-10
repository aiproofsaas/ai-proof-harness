#!/bin/sh
# Installs or updates the AI-Proof harness in the current folder.
# Safe to run again: harness files get replaced, your own files never do.
set -eu

REPO="aiproofsaas/ai-proof-harness"
DEST=$(pwd)

case "$DEST" in
  "$HOME"|"$HOME/Desktop"|"$HOME/Documents"|"$HOME/Downloads"|/)
    echo "Stop: this is $DEST. Make a project folder first, like Documents/ai-proof, open it, and run this again."
    exit 1 ;;
esac

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

if [ -n "${AIPROOF_SRC:-}" ]; then
  SRC="$AIPROOF_SRC"   # for testing a local copy
else
  echo "Downloading the AI-Proof harness..."
  curl -fsSL "https://github.com/$REPO/archive/refs/heads/main.zip" -o "$TMP/harness.zip"
  unzip -q "$TMP/harness.zip" -d "$TMP"
  SRC=$(find "$TMP" -mindepth 1 -maxdepth 1 -type d | head -n 1)
fi

OLD=""
[ -f "$DEST/VERSION" ] && OLD=$(cat "$DEST/VERSION")

# Harness files: always the newest version.
mkdir -p "$DEST/.claude/skills" "$DEST/.claude/hooks"
for dir in "$SRC"/harness/.claude/skills/*/; do
  name=$(basename "$dir")
  rm -rf "$DEST/.claude/skills/$name"
  cp -R "$dir" "$DEST/.claude/skills/$name"
done
cp "$SRC"/harness/.claude/hooks/* "$DEST/.claude/hooks/"
cp "$SRC/harness/.claude/settings.json" "$DEST/.claude/settings.json"
for file in HARNESS.md START-HERE.md VERSION; do
  cp "$SRC/harness/$file" "$DEST/$file"
done
rm -rf "$DEST/templates"
cp -R "$SRC/harness/templates" "$DEST/templates"

# Your files: only added when missing.
cd "$SRC/starter"
find . -type f | while IFS= read -r file; do
  if [ ! -e "$DEST/$file" ]; then
    mkdir -p "$DEST/$(dirname "$file")"
    cp "$file" "$DEST/$file"
  fi
done
cd "$DEST"

if [ ! -e "$DEST/CLAUDE.md" ]; then
  cp "$DEST/templates/CLAUDE.md" "$DEST/CLAUDE.md"
elif ! grep -q "@HARNESS.md" "$DEST/CLAUDE.md"; then
  printf '\n@HARNESS.md\n' >> "$DEST/CLAUDE.md"
fi

if [ -e "$DEST/.gitignore" ] && ! grep -qx ".dev.vars" "$DEST/.gitignore"; then
  printf '\n.dev.vars\n' >> "$DEST/.gitignore"
fi

NEW=$(cat "$DEST/VERSION")
if [ -z "$OLD" ]; then
  echo "Installed the AI-Proof harness, version $NEW."
elif [ "$OLD" = "$NEW" ]; then
  echo "Already up to date, version $NEW."
else
  echo "Updated from version $OLD to $NEW."
fi
echo "Next: type /setup-check. If Claude doesn't know it yet, open a new session in this folder first."

---
name: update
description: Gets the newest version of the AI-Proof harness, with the skills for the next bootcamp day. Never touches the user's own files. Use when the user types /update, asks for new skills, or asks for a skill this folder doesn't have yet.
---

# Update

Tell the user: "Getting the newest skills. Your own files stay as they are."

1. Read `VERSION` and remember it.
2. Run the installer again. It replaces only the harness files and adds starter files that are missing.
   - Mac: `curl -fsSL https://raw.githubusercontent.com/aiproofsaas/ai-proof-harness/main/install.sh | sh`
   - Windows: `powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/aiproofsaas/ai-proof-harness/main/install.ps1 | iex"`
3. Read `VERSION` again.
4. Tell them:
   - Same version: "You already had the newest version."
   - New version: "Updated from <old> to <new>." Then list the skill folders in `.claude/skills/` that weren't there before, one line each.
5. If new skills arrived, say: "Open a new session in this folder so your co-founder sees the new skills."

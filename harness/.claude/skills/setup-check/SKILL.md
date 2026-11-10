---
name: setup-check
description: First-day sign-off for the AI-Proof bootcamp. Checks the laptop, the harness, Node, Cloudflare and the live product, and prints a green or red list with a fix for every red. Use when the user types /setup-check, asks if their setup works, or finishes a setup step.
---

# Setup check

Print this line first, on its own:

**First-day sign-off. Green means ready. Red comes with the fix.**

Run the checks below in order. They only read. Never change a file here, never install anything, and never print a secret. Run each command quietly and keep the output to yourself. The user only sees the final list.

Work out the system first: `uname` works on Mac. On Windows, the shell may be Git Bash or PowerShell. Use the command that fits.

## The checks

1. **Folder.** Get the current folder path.
   - RED if it is the home folder itself, the Desktop, or Downloads. Fix: "Make a folder called ai-proof in Documents, open the Code tab on it, and install the harness there."
   - RED if the path contains `OneDrive`. Fix: "Move this folder out of OneDrive, to C:\Users\<you>\ai-proof. OneDrive locks files while you build."
   - Otherwise GREEN: "Folder: <folder name>, outside OneDrive."

2. **Handbook.** Check that `HARNESS.md`, `VERSION` and `.claude/skills/ship/SKILL.md` exist.
   - GREEN: "Handbook installed (version <contents of VERSION>)."
   - RED: "Handbook missing. Fix: paste the install prompt from the setup guide again."

3. **Claude login.** Check whether the `ANTHROPIC_API_KEY` environment variable is set. Don't print its value.
   - RED if set: "An Anthropic key sits in your system settings, so Claude may bill that key instead of your plan. Fix: remove ANTHROPIC_API_KEY from your shell profile or system settings, then open a new session."
   - GREEN if not: "Claude is using your plan."

4. **Node.** Run `node --version`.
   - GREEN if it prints v18 or higher: "Node <version>."
   - RED if missing or older: "Node not found. Fix: install Node LTS from nodejs.org, then open a new session here."
   - If Node is missing, mark checks 5 to 8 as RED with the fix "Comes after Node." and skip running them.

5. **Cloudflare login.** Run `npx wrangler whoami`.
   - GREEN if it shows an account: "Cloudflare: logged in as <email or account name>."
   - RED if not logged in: "Cloudflare not connected yet. Fix: make a free account at cloudflare.com, then type /ship. It logs you in."

6. **Secret file.** Check that `.dev.vars` exists and has a line starting with `ACCESS_CODE=` with a value. Check that `.gitignore` has a line `.dev.vars`. Never print the value.
   - GREEN: "Access code set and kept private."
   - RED: "No access code yet. Fix: type /ship. It makes one."

7. **Live product.** Read `.ai-proof.json` and take `live_url`. Request `<live_url>/info` with curl.
   - GREEN if it answers with JSON: "Live at <live_url>."
   - RED if the file is missing: "Not live yet. Fix: type /ship."
   - RED if the URL doesn't answer: "Your product didn't answer. Fix: type /ship again."

8. **AI test.** Only if check 7 is green. Send one test run, reading the code from `.dev.vars` inside the command so it never shows on screen:
   `curl -s -X POST <live_url>/run -H "content-type: application/json" -d '{"input":"Setup check. Say hi.","code":"<ACCESS_CODE>"}'`
   - GREEN if `status` is `done`: "Your product's AI answered."
   - RED if the output mentions neurons or a daily limit: "Today's free AI runs are used up. They reset at midnight UTC. Nothing is broken."
   - RED for anything else: "Your product's AI didn't answer. Fix: type /unstuck."

## The output
One line per check, in this exact shape:

```
GREEN  Folder: ai-proof, outside OneDrive.
GREEN  Handbook installed (version 0.1.0).
RED    Node not found. Fix: install Node LTS from nodejs.org, then open a new session here.
```

Then one empty line and:

- If any check is red and the user hasn't done Part B of the setup guide yet, add: "Red on Node, Cloudflare, the access code or the live product is normal before Part B of the guide."
- If all are green: "All green. Your co-founder is ready for Day 1."
- Always end with: "Screenshot this and post it in the Skool setup thread."

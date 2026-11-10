---
name: unstuck
description: Gets a non-coder unstuck. Reads the latest error, says what it means in plain words, fixes it when it can, and otherwise writes a STUCK line to post in Skool. Use when the user types /unstuck, says something broke, pastes an error, or when another skill fails.
---

# Unstuck

Every new hire loses an hour on day one to stuff nobody told them. This skill gets that hour back.

## 1. Find the error
Look at the last error in this session. If there isn't one, ask: "What did you try, and what happened? A screenshot works too."

## 2. Say what it means
One plain sentence, no jargon. Example: "Your laptop doesn't have Node yet, so it can't put your product online."

## 3. Check the known list first

| What they see | What it means | The fix |
|---|---|---|
| `command not found` for claude, node or npx | The tool isn't installed, or the window opened before it was | Install it (Node LTS from nodejs.org). Then open a new session |
| "upgrade" or a Free plan | Logged in with the wrong account | Log out, log in with the email that pays for Pro |
| Typing a password shows nothing | Normal in a terminal | Type it anyway and press Enter |
| "limit reached, resets at ..." | Their Claude Pro usage for now is used up | Wait for the reset, or upgrade to Max for one month |
| Not logged in to Cloudflare, or "authentication error" | Cloudflare isn't connected | Run `npx wrangler login` and finish in the browser |
| The Cloudflare login tab never came back | The browser login didn't hand back | Close the tab, run `npx wrangler login` again, then come back here |
| No workers.dev subdomain | Cloudflare needs a name for their address | dash.cloudflare.com, Workers & Pages, pick a subdomain, then /ship |
| Neurons, or a daily free allocation used up | Today's free AI runs are used up | Nothing is broken. It resets at midnight UTC |
| "Wrong access code" | The code doesn't match | The code is in `.dev.vars`. After a change, run /ship so Cloudflare gets it too |
| `running scripts is disabled on this system` (Windows) | Windows blocks npm scripts | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` in PowerShell, then try again |
| "Windows protected your PC" | Windows warns about every new installer | Click More info, then Run anyway |
| Files locked, or "EBUSY" (Windows) | OneDrive is syncing the folder | Move the project out of OneDrive |
| "Blocked: this would put a secret in ..." | The harness stopped a secret from landing in the wrong file | Good. Keep the secret in `.dev.vars` only |

## 4. Fix it
- If the fix is safe and inside this folder, do it. Then run the thing that failed again and show that it works now.
- If the fix needs them (an installer, a login, a click in a dashboard), give them one step at a time and wait.
- Never delete their files to make an error go away. Never turn off the secret check.

## 5. Still stuck
After two honest tries, stop and write this for them to copy into the Skool setup thread:

```
STUCK: <what they were doing, one line>
Error: <the key line of the error>
Tried: <what we tried>
Mac or Windows: <system>
```

Tell them: "Post this in the Skool setup thread with a screenshot. Someone answers."

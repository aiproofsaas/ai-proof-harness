---
name: ship
description: Puts the user's product live on Cloudflare at their own web address, then runs one real job on it. The first time, it also logs in to Cloudflare, creates the database and makes the access code. Use when the user types /ship or asks to put their product live, deploy, or publish.
---

# Ship

Tell the user in one sentence: "Your co-founder is putting your product on the internet. This takes a few minutes."

Work step by step. Before each step, say in one short line what it does. If a step fails, stop and run the `/unstuck` steps. Don't guess.

## 1. Check the basics
- Run `node --version`. If Node is missing, stop: "First install Node LTS from nodejs.org, then open a new session here and type /ship again."
- Check that `wrangler.jsonc`, `src/index.js` and `schema.sql` exist. If they don't, stop: "Your starter product is missing. Type /update to put it back."
- If there's no `node_modules` folder, run `npm install`. Say: "Installing the toolbox. It looks frozen for a minute. That's normal."

## 2. Log in to Cloudflare
- Run `npx wrangler whoami`.
- If not logged in, say: "A browser tab opens to log in to Cloudflare. Finish the login there, then come back. I'll wait." Then run `npx wrangler login`.
- If they have no Cloudflare account, stop: "Make a free account at cloudflare.com first. Then type /ship again."

## 3. Put their name on it
- Read `vars.OWNER_NAME` in `wrangler.jsonc`.
- If it is `FILL`, ask: "What name goes on your product? Your first name is fine." Write the answer into `OWNER_NAME`.

## 4. The database
- Read `database_id` in `wrangler.jsonc`.
- If it is `FILL`, run `npx wrangler d1 create ai-proof-db`. Take the `database_id` from the output and write it into `wrangler.jsonc`. If the database already exists, run `npx wrangler d1 list --json` and take the id of `ai-proof-db` from there.
- Then run `npx wrangler d1 execute ai-proof-db --remote --file=schema.sql --yes`. This is safe to run again. It only adds tables that don't exist yet.

## 5. Deploy
- Run `npx wrangler deploy`.
- Take the live URL from the output. It ends in `.workers.dev`.
- If the output says the account has no workers.dev subdomain, stop and say: "Cloudflare needs a name for your web address first. Open dash.cloudflare.com, go to Workers & Pages, and pick a subdomain. Your name works. Then type /ship again."

## 6. The access code
- If `.dev.vars` has no `ACCESS_CODE` value yet:
  - Make a random 8-character code with `node -e "console.log(require('crypto').randomBytes(4).toString('hex'))"`.
  - Write `ACCESS_CODE=<code>` into `.dev.vars`. Create the file if needed. Check that `.gitignore` contains `.dev.vars`, and add it if not.
  - Tell the user once: "Your access code is <code>. Your product asks for it, so strangers can't use your free AI runs. It's saved in .dev.vars. Don't put it in a screenshot."
- Upload it every time: `npx wrangler secret bulk .dev.vars`.

## 7. Save the address
Write `.ai-proof.json` in the project folder:

```json
{ "live_url": "<the live URL>", "owner": "<OWNER_NAME>", "shipped_at": "<date and time now>" }
```

## 8. Open it and run one real job
- Open the URL in their browser: `open <url>` on Mac, `start <url>` or `explorer <url>` on Windows.
- Send one run, reading the code from `.dev.vars` inside the command so it never shows:
  `curl -s -X POST <url>/run -H "content-type: application/json" -d '{"input":"Hello, it is your first day.","code":"<ACCESS_CODE>"}'`
- Show them the reply.
- If the run failed, run the `/unstuck` steps.

## 9. Tell them
Say:

"Your product is live at <url>. A real address on the internet with your name on it. It only says hello for now. On Wednesday it gets a real job.

Post your URL in Skool. Then type /setup-check. It should be all green."

Only say it's live if the URL opened and the run came back. If one of them failed, say which one, and what you're doing about it.

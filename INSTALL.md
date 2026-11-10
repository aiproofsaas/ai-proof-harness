# Install the AI-Proof harness

These steps are for Claude Code. The person you're helping doesn't code, so explain each step in one plain sentence before you run it.

1. **Check the folder.** Look at the current folder. It should be their project folder, usually called `ai-proof`. If it's their home folder, the Desktop, Documents or Downloads, stop. Help them make `Documents/ai-proof` (Mac) or `C:\Users\<them>\ai-proof` (Windows, outside OneDrive), and tell them to open the Code tab on that folder and paste the install prompt again.

2. **Run the installer.** It downloads the harness and puts it in this folder. Running it again is safe.
   - Mac: `curl -fsSL https://raw.githubusercontent.com/aiproofsaas/ai-proof-harness/main/install.sh | sh`
   - Windows: `powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/aiproofsaas/ai-proof-harness/main/install.ps1 | iex"`

3. **Tell them it worked.** Say: "Your co-founder's handbook is installed." Show the version line the installer printed.

4. **Run the setup check.** Run `/setup-check`. If it isn't available yet, say: "Open a new session in this folder, then type /setup-check." Red on Node, Cloudflare, the access code or the live product is normal at this point.

// Your product. On Day 0 it only says hello. On Day 3 it gets its real job.

// The AI model. It comes free with your Cloudflare account.
const MODEL = "@cf/meta/llama-3.3-70b-instruct-fp8-fast";

// The one job your product does. Day 3 replaces this.
const JOB =
  "You are a new hire on your first day at work. Reply to the message below in one short, friendly sentence.";

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.pathname === "/info") {
      const owner = env.OWNER_NAME === "FILL" ? "" : env.OWNER_NAME || "";
      return json({ owner });
    }

    if (url.pathname === "/run" && request.method === "POST") {
      return run(request, env);
    }

    // Everything else is the page in public/.
    return env.ASSETS.fetch(request);
  },
};

// Does the job once and saves the run. Day 4 builds the moat on these rows.
async function run(request, env) {
  let body;
  try {
    body = await request.json();
  } catch {
    return json({ error: 'Send JSON like {"input": "...", "code": "..."}' }, 400);
  }

  // The access code keeps strangers from using up your free AI runs.
  if (!env.ACCESS_CODE || body.code !== env.ACCESS_CODE) {
    return json({ error: "Wrong access code." }, 401);
  }

  const input = String(body.input || "").slice(0, 4000);
  if (!input.trim()) {
    return json({ error: "Type something first." }, 400);
  }

  const id = crypto.randomUUID();
  const createdAt = new Date().toISOString();
  let output = "";
  let status = "done";

  try {
    const result = await env.AI.run(MODEL, {
      messages: [
        { role: "system", content: JOB },
        { role: "user", content: input },
      ],
      max_tokens: 400,
    });
    output = result.response || "";
  } catch (err) {
    status = "failed";
    output = String(err && err.message ? err.message : err);
  }

  await env.DB.prepare(
    "INSERT INTO runs (id, created_at, input, output, status) VALUES (?, ?, ?, ?, ?)"
  )
    .bind(id, createdAt, input, output, status)
    .run();

  return json({ id, status, output }, status === "done" ? 200 : 502);
}

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "content-type": "application/json" },
  });
}

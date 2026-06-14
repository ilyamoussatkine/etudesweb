const crypto = require("crypto");

const QUESTION_ORDER = {
  motto: 1,
  current_state: 2,
  favorite_color: 3,
  favorite_occupation: 4,
  desired_ability: 5,
  desired_self: 6,
  dream_of_happiness: 7,
  friends_qualities: 8,
  favorite_writers: 9,
  favorite_poets: 10,
  favorite_literary_hero: 11,
  favorite_composers: 12,
  favorite_artists: 13,
  real_life_heroes: 14,
  favorite_names: 15,
  forgiven_vices: 16,
  most_hated: 17,
  main_flaw: 18,
  main_trait: 19,
  valued_human_qualities: 20,
  greatest_misfortune: 21,
  desired_death: 22,
};

const ALLOWED_ORIGIN = process.env.ALLOWED_ORIGIN || "*";
const MAX_NICKNAME = 32;
const MAX_ANSWER = 700;
const MAX_RESULTS = Number(process.env.MAX_RESULTS || 200);

let driverPromise;
let sqlPromise;

exports.handler = async function handler(event) {
  const method = getMethod(event);
  const path = getPath(event);

  if (method === "OPTIONS") {
    return response(204, "");
  }

  try {
    if (method === "POST" && path.endsWith("/submissions")) {
      const payload = parseJsonBody(event);
      const saved = await saveSubmission(payload, event);
      return response(201, saved);
    }

    if (method === "GET" && path.endsWith("/results")) {
      const results = await loadResults();
      return response(200, { submissions: results });
    }

    return response(404, { error: "Not found" });
  } catch (error) {
    console.error(error);
    const status = error.statusCode || 500;
    return response(status, { error: error.publicMessage || "Internal error" });
  }
};

async function getSql() {
  if (!sqlPromise) {
    sqlPromise = (async () => {
      const endpoint = process.env.YDB_ENDPOINT;
      if (!endpoint) {
        throw publicError(500, "YDB_ENDPOINT is not configured");
      }
      const { Driver } = await import("@ydbjs/core");
      const { query } = await import("@ydbjs/query");
      const { MetadataCredentialsProvider } = await import("@ydbjs/auth/metadata");

      if (!driverPromise) {
        driverPromise = (async () => {
          const driver = new Driver(endpoint, {
            credentialsProvider: new MetadataCredentialsProvider(),
          });
          await driver.ready();
          return driver;
        })();
      }

      return query(await driverPromise);
    })();
  }
  return sqlPromise;
}

async function saveSubmission(payload, event) {
  const now = new Date().toISOString();
  const submissionId = crypto.randomUUID();
  const nickname = normalizeNickname(payload.nickname);
  const mode = payload.mode === "full" ? "full" : "short";
  const answers = normalizeAnswers(payload.answers);
  const userAgent = getHeader(event, "user-agent").slice(0, 300);

  if (!answers.length) {
    throw publicError(400, "Нужно заполнить хотя бы один ответ");
  }

  const sql = await getSql();
  await sql.begin(async (tx) => {
    await tx`
      INSERT INTO submissions
        (submission_id, nickname, mode, created_at, consent, user_agent)
      VALUES
        (${submissionId}, ${nickname}, ${mode}, ${now}, ${true}, ${userAgent});
    `;

    for (const answer of answers) {
      await tx`
        INSERT INTO answers
          (submission_id, question_slug, question_order, answer_text, created_at, hidden)
        VALUES
          (${submissionId}, ${answer.slug}, ${answer.order}, ${answer.text}, ${now}, ${false});
      `;
    }
  });

  return { submission_id: submissionId, created_at: now };
}

async function loadResults() {
  const sql = await getSql();
  const [submissionRows] = await sql`
    SELECT submission_id, nickname, mode, created_at
    FROM submissions
    ORDER BY created_at DESC
    LIMIT ${MAX_RESULTS};
  `;

  const ids = submissionRows.map((row) => row.submission_id);
  if (!ids.length) return [];

  const [answerRows] = await sql`
    SELECT submission_id, question_slug, answer_text
    FROM answers
    WHERE hidden = false;
  `;

  const allowedIds = new Set(ids);
  const byId = new Map(submissionRows.map((row) => [
    row.submission_id,
    {
      id: row.submission_id,
      nickname: row.nickname,
      mode: row.mode,
      createdAt: row.created_at,
      answers: {},
    },
  ]));

  for (const row of answerRows) {
    if (!allowedIds.has(row.submission_id)) continue;
    byId.get(row.submission_id).answers[row.question_slug] = row.answer_text;
  }

  return [...byId.values()];
}

function normalizeNickname(value) {
  const nickname = String(value || "").trim().replace(/\s+/g, " ");
  if (!nickname) return "Аноним";
  return nickname.slice(0, MAX_NICKNAME);
}

function normalizeAnswers(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw publicError(400, "Некорректный формат ответов");
  }

  return Object.entries(value)
    .map(([slug, text]) => ({
      slug,
      order: QUESTION_ORDER[slug],
      text: String(text || "").trim().slice(0, MAX_ANSWER),
    }))
    .filter((answer) => answer.order && answer.text);
}

function parseJsonBody(event) {
  if (!event.body) return {};
  const rawBody = event.isBase64Encoded
    ? Buffer.from(event.body, "base64").toString("utf8")
    : event.body;
  try {
    return typeof rawBody === "string" ? JSON.parse(rawBody) : rawBody;
  } catch {
    throw publicError(400, "Некорректный JSON");
  }
}

function getMethod(event) {
  return String(
    event.httpMethod ||
    event.requestContext?.http?.method ||
    event.requestContext?.httpMethod ||
    "",
  ).toUpperCase();
}

function getPath(event) {
  return String(event.path || event.rawPath || event.url || "/");
}

function getHeader(event, name) {
  const headers = event.headers || {};
  const key = Object.keys(headers).find((candidate) => candidate.toLowerCase() === name);
  return key ? String(headers[key] || "") : "";
}

function publicError(statusCode, publicMessage) {
  const error = new Error(publicMessage);
  error.statusCode = statusCode;
  error.publicMessage = publicMessage;
  return error;
}

function response(statusCode, body) {
  return {
    statusCode,
    headers: {
      "Access-Control-Allow-Origin": ALLOWED_ORIGIN,
      "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
      "Content-Type": "application/json; charset=utf-8",
    },
    body: body === "" ? "" : JSON.stringify(body),
  };
}

const app = document.querySelector("#app");
const STORAGE_KEY = "etudes_proust_submissions_v1";
const DRAFT_KEY = "etudes_proust_draft_v1";
const API_URL = String(window.PROUST_API_URL || "").replace(/\/$/, "");

let questions = [];
let backgroundAnswers = [];
let activeQuestions = [];
let activeIndex = 0;
let draftAnswers = {};
let mode = "short";

const sampleNames = ["Аврора", "Соня", "Марк", "Лев", "Ника", "Ася"];

init();

async function init() {
  const [questionResponse, backgroundResponse] = await Promise.all([
    fetch("./data/questions.json"),
    fetch("./data/background_answers.json"),
  ]);
  questions = (await questionResponse.json()).sort((a, b) => a.order - b.order);
  backgroundAnswers = await backgroundResponse.json();
  if (!API_URL) seedDemoSubmissions();
  renderIntro();
}

function seedDemoSubmissions() {
  if (localStorage.getItem(STORAGE_KEY)) return;
  const demo = [
    {
      id: crypto.randomUUID(),
      nickname: "Гость в синем",
      createdAt: new Date(Date.now() - 1000 * 60 * 12).toISOString(),
      answers: {
        motto: "Сначала смотреть, потом называть.",
        current_state: "Собранность и легкое электричество.",
        dream_of_happiness: "Делать важное рядом с людьми, которым не нужно всё объяснять.",
        friends_qualities: "Точность, нежность и чувство юмора.",
      },
    },
    {
      id: crypto.randomUUID(),
      nickname: "Полевая заметка",
      createdAt: new Date(Date.now() - 1000 * 60 * 7).toISOString(),
      answers: {
        motto: "Оставлять след, но не шум.",
        current_state: "Любопытство.",
        favorite_color: "Пыльный голубой.",
        favorite_occupation: "Собирать смыслы в систему.",
      },
    },
    {
      id: crypto.randomUUID(),
      nickname: "Северная комната",
      createdAt: new Date(Date.now() - 1000 * 60 * 5).toISOString(),
      answers: {
        motto: "Не торопить смысл.",
        current_state: "Светло, но сосредоточенно.",
      },
    },
    {
      id: crypto.randomUUID(),
      nickname: "Чернила",
      createdAt: new Date(Date.now() - 1000 * 60 * 4).toISOString(),
      answers: {
        motto: "Все важное сначала шепчет.",
        friends_qualities: "Способность быть рядом без шума.",
      },
    },
    {
      id: crypto.randomUUID(),
      nickname: "Поля",
      createdAt: new Date(Date.now() - 1000 * 60 * 3).toISOString(),
      answers: {
        motto: "Оставлять место для воздуха.",
        dream_of_happiness: "Дом, работа и люди, к которым хочется возвращаться.",
      },
    },
  ];
  localStorage.setItem(STORAGE_KEY, JSON.stringify(demo));
}

function renderIntro() {
  app.className = "app intro-screen";
  app.innerHTML = `
    <section class="hero">
      <div class="hero-copy">
        <img class="brand-logo" src="./assets/etudes_logo_transparent.png" alt="Этюды" />
        <h1>Анкета Пруста</h1>
        <p class="lead">составь короткий портрет с помощью салонной анкеты belle epoque</p>
        <div class="hero-actions" aria-label="Выбор версии опросника">
          <button class="choice primary" data-mode="short">
            <span>Короткая версия</span>
            <small>6 случайных вопросов</small>
          </button>
          <button class="choice" data-mode="full">
            <span>Полная версия</span>
            <small>22 вопроса</small>
          </button>
        </div>
      </div>
      <div class="proust-stage" aria-hidden="true">
        <div class="paper-grain"></div>
        <img src="./assets/proust.jpg" alt="" class="proust-cutout" />
        <div class="portrait-caption">Marcel Proust</div>
      </div>
    </section>
  `;

  app.querySelectorAll("[data-mode]").forEach((button) => {
    button.addEventListener("click", () => startSurvey(button.dataset.mode));
  });
}

function startSurvey(nextMode) {
  mode = nextMode;
  draftAnswers = {};
  activeIndex = 0;
  activeQuestions = mode === "short" ? buildShortQuestions() : questions.slice();
  renderQuestion();
}

function buildShortQuestions() {
  const randomPool = questions.slice();
  shuffle(randomPool);
  return randomPool.slice(0, 6).sort((a, b) => a.order - b.order);
}

function renderQuestion() {
  const question = activeQuestions[activeIndex];
  const progress = `${activeIndex + 1} / ${activeQuestions.length}`;
  app.className = "app survey-screen";
  app.innerHTML = `
    <section class="question-shell">
      <div class="floating-field">${renderFloatingAnswers(question.slug)}</div>
      <header class="survey-header">
        <button class="ghost-button" data-action="home" aria-label="На первый экран">Анкета</button>
        <span class="progress">${progress}</span>
      </header>
      <article class="question-card question-card--answering">
        <p class="question-index">Вопрос ${activeIndex + 1}</p>
        <h2>${escapeHtml(question.question)}</h2>
        <form class="answer-form">
          <label class="sr-only" for="answer">Ваш ответ</label>
          <textarea class="inline-answer" id="answer" rows="3" autocomplete="off" autocapitalize="sentences" placeholder="Ваш ответ">${escapeHtml(draftAnswers[question.slug] ?? "")}</textarea>
          <div class="nav-row">
            ${activeIndex > 0 ? `<button class="back-button" type="button" data-action="prev">Назад</button>` : "<span></span>"}
            <button class="next-button" type="submit">
              <span>${activeIndex === activeQuestions.length - 1 ? "Завершить" : "Дальше"}</span>
              <span aria-hidden="true">→</span>
            </button>
          </div>
        </form>
      </article>
    </section>
  `;

  app.querySelector("[data-action='home']").addEventListener("click", renderIntro);
  const prevButton = app.querySelector("[data-action='prev']");
  if (prevButton) {
    prevButton.addEventListener("click", () => {
      saveCurrentAnswer(question.slug);
      if (activeIndex > 0) {
        activeIndex -= 1;
        renderQuestion();
      }
    });
  }
  app.querySelector(".answer-form").addEventListener("submit", (event) => {
    event.preventDefault();
    saveCurrentAnswer(question.slug);
    if (activeIndex < activeQuestions.length - 1) {
      activeIndex += 1;
      renderQuestion();
    } else {
      renderConsent();
    }
  });
  const textarea = app.querySelector("textarea");
  textarea.addEventListener("input", () => autosizeTextarea(textarea));
  autosizeTextarea(textarea);
  textarea.focus({ preventScroll: true });
}

function saveCurrentAnswer(slug) {
  const textarea = app.querySelector("textarea");
  if (!textarea) return;
  draftAnswers[slug] = textarea.value.trim();
  saveDraft();
}

function renderConsent() {
  app.className = "app consent-screen";
  app.innerHTML = `
    <section class="consent-card">
      <p class="eyebrow">Почти готово</p>
      <h2>Покажем общую стену ответов?</h2>
      <p class="consent-copy">Введите псевдоним, если хотите добавить ответы в общую анонимизированную стену. Можно отказаться от публикации и посмотреть только свой портрет.</p>
      <form class="consent-form">
        <label for="nickname">Псевдоним</label>
        <input id="nickname" name="nickname" type="text" maxlength="32" placeholder="${sampleNames[Math.floor(Math.random() * sampleNames.length)]}" />
        <div class="consent-actions">
          <button class="next-button wide" type="submit">
            <span>Отправить и смотреть</span>
            <span aria-hidden="true">→</span>
          </button>
          <button class="secondary-button" type="button" data-action="private-results">Не публиковать</button>
        </div>
      </form>
    </section>
  `;
  app.querySelector(".consent-form").addEventListener("submit", async (event) => {
    event.preventDefault();
    const button = event.currentTarget.querySelector("button[type='submit']");
    button.disabled = true;
    button.querySelector("span").textContent = "Отправляем";
    const form = new FormData(event.currentTarget);
    const nickname = String(form.get("nickname") || "Аноним").trim();
    try {
      await saveSubmission(nickname || "Аноним");
      await renderResults();
    } catch (error) {
      button.disabled = false;
      button.querySelector("span").textContent = "Отправить и смотреть";
      showConsentError(error.message);
    }
  });
  app.querySelector("[data-action='private-results']").addEventListener("click", () => {
    renderPersonalResults();
  });
}

function showConsentError(message) {
  const existing = app.querySelector(".form-error");
  if (existing) existing.remove();
  const error = document.createElement("p");
  error.className = "form-error";
  error.textContent = message || "Не удалось отправить ответы. Проверьте соединение и попробуйте еще раз.";
  app.querySelector(".consent-form").append(error);
}

async function saveSubmission(nickname) {
  const payload = {
    nickname,
    mode,
    answers: Object.fromEntries(Object.entries(draftAnswers).filter(([, value]) => value)),
  };

  if (API_URL) {
    const response = await fetch(`${API_URL}/submissions`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });
    if (!response.ok) {
      throw new Error(`Не удалось отправить ответы: ${response.status}`);
    }
    return;
  }

  const submissions = await getSubmissions();
  submissions.unshift({
    id: crypto.randomUUID(),
    nickname,
    createdAt: new Date().toISOString(),
    mode,
    answers: payload.answers,
  });
  localStorage.setItem(STORAGE_KEY, JSON.stringify(submissions));
  sessionStorage.removeItem(DRAFT_KEY);
}

async function renderResults() {
  const submissions = await getSubmissions();
  app.className = "app results-screen";
  app.innerHTML = `
    <section class="results-layout">
      <header class="results-header">
        <div>
          <p class="eyebrow">Общая стена</p>
          <h2>Ответы участников</h2>
        </div>
        <button class="ghost-button" data-action="again">Пройти еще раз</button>
      </header>
      <div class="results-list">
        ${questions.map((question) => renderResultGroup(question, submissions)).join("")}
      </div>
    </section>
  `;
  app.querySelector("[data-action='again']").addEventListener("click", renderIntro);
  app.querySelectorAll("[data-action='show-more']").forEach((button) => {
    button.addEventListener("click", () => {
      const group = button.closest(".result-group");
      group.classList.remove("is-collapsed");
      button.remove();
    });
  });
}

function renderPersonalResults() {
  const answers = Object.fromEntries(Object.entries(draftAnswers).filter(([, value]) => value));
  app.className = "app results-screen personal-results-screen";
  app.innerHTML = `
    <section class="results-layout">
      <header class="results-header">
        <div>
          <p class="eyebrow">Личный портрет</p>
          <h2>Ваши ответы</h2>
        </div>
        <button class="ghost-button" data-action="finish">Завершить</button>
      </header>
      <div class="results-list">
        ${questions.map((question) => renderPersonalResultGroup(question, answers)).join("")}
      </div>
    </section>
  `;
  sessionStorage.removeItem(DRAFT_KEY);
  app.querySelector("[data-action='finish']").addEventListener("click", renderIntro);
}

function renderPersonalResultGroup(question, answers) {
  const answer = answers[question.slug];
  if (!answer) return "";
  return `
    <article class="result-group">
      <h3>${escapeHtml(question.question)}</h3>
      <ul>
        <li>
          <span class="result-name">Вы</span>
          <p>${escapeHtml(answer)}</p>
        </li>
      </ul>
    </article>
  `;
}

function renderResultGroup(question, submissions) {
  const matching = submissions.filter((submission) => submission.answers[question.slug]);
  const rows = matching
    .map((submission, index) => `
      <li>
        <span class="result-name">${escapeHtml(submission.nickname)}</span>
        <p>${escapeHtml(submission.answers[question.slug])}</p>
      </li>
    `)
    .join("");
  if (!rows) return "";
  const more = matching.length > 4
    ? `<button class="show-more" type="button" data-action="show-more">Смотреть больше</button>`
    : "";
  return `
    <article class="result-group ${matching.length > 4 ? "is-collapsed" : ""}">
      <h3>${escapeHtml(question.question)}</h3>
      <ul>${rows}</ul>
      ${more}
    </article>
  `;
}

function renderFloatingAnswers(slug) {
  const variants = backgroundAnswers
    .filter((answer) => answer.question_slug === slug)
    .map((answer) => answer.background_text)
    .filter(Boolean);
  const fallback = backgroundAnswers.map((answer) => answer.background_text).filter(Boolean);
  const selected = (variants.length ? variants : fallback).slice();
  shuffle(selected);
  return selected.slice(0, 9).map((text, index) => {
    const style = `--i:${index}; --x:${8 + (index * 17) % 76}%; --y:${8 + (index * 23) % 78}%;`;
    return `<span class="float-line" style="${style}">${escapeHtml(text)}</span>`;
  }).join("");
}

async function getSubmissions() {
  if (API_URL) {
    const response = await fetch(`${API_URL}/results`);
    if (!response.ok) {
      throw new Error(`Не удалось загрузить результаты: ${response.status}`);
    }
    const data = await response.json();
    return Array.isArray(data.submissions) ? data.submissions : [];
  }

  try {
    const data = JSON.parse(localStorage.getItem(STORAGE_KEY) || "[]");
    return Array.isArray(data) ? data : [];
  } catch {
    return [];
  }
}

function autosizeTextarea(textarea) {
  textarea.style.height = "auto";
  textarea.style.height = `${Math.min(textarea.scrollHeight, Math.round(window.innerHeight * 0.28))}px`;
}

function saveDraft() {
  sessionStorage.setItem(DRAFT_KEY, JSON.stringify({
    mode,
    activeIndex,
    answers: draftAnswers,
  }));
}

function shuffle(items) {
  for (let i = items.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [items[i], items[j]] = [items[j], items[i]];
  }
  return items;
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

import fs from "node:fs/promises";
import path from "node:path";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";

const outputDir = path.resolve("outputs/proust_questionnaire_db");

const questions = [
  ["motto", 1, "Ваш девиз?", "opening"],
  ["current_state", 2, "Ваше состояние духа в настоящий момент?", "opening"],
  ["favorite_color", 3, "Ваш любимый цвет?", "taste"],
  ["favorite_occupation", 4, "Какое Ваше любимое занятие?", "taste"],
  ["desired_ability", 5, "Способность, которой вам хотелось бы обладать?", "aspiration"],
  ["desired_self", 6, "Каким Вы хотели бы быть?", "aspiration"],
  ["dream_of_happiness", 7, "Какова Ваша мечта о счастье?", "values"],
  ["friends_qualities", 8, "Что Вы больше всего цените в Ваших друзьях?", "values"],
  ["favorite_writers", 9, "Ваши любимые писатели?", "culture"],
  ["favorite_poets", 10, "Ваши любимые поэты?", "culture"],
  ["favorite_literary_hero", 11, "Любимый литературный герой?", "culture"],
  ["favorite_composers", 12, "Любимые композиторы?", "culture"],
  ["favorite_artists", 13, "Любимые художники?", "culture"],
  ["real_life_heroes", 14, "Любимые герои в реальной жизни?", "culture"],
  ["favorite_names", 15, "Любимые имена?", "culture"],
  ["forgiven_vices", 16, "К каким порокам Вы чувствуете наибольшее снисхождение?", "values"],
  ["most_hated", 17, "Что Вы больше всего ненавидите?", "shadow"],
  ["main_flaw", 18, "Что является Вашим главным недостатком?", "shadow"],
  ["main_trait", 19, "Ваша самая характерная черта?", "identity"],
  ["valued_human_qualities", 20, "Качества, которые Вы больше всего цените в человеке?", "identity"],
  ["greatest_misfortune", 21, "Что Вы считаете самым большим несчастьем?", "deep"],
  ["desired_death", 22, "Как Вы хотели бы умереть?", "deep"],
].map(([slug, order, question, category], index) => ({
  id: index + 1,
  order,
  slug,
  question,
  category,
  active: true,
}));

const questionIdBySlug = Object.fromEntries(questions.map((question) => [question.slug, question.id]));
const answers = [];

function add(slug, author, answer, options = {}) {
  answers.push({
    id: answers.length + 1,
    question_id: questionIdBySlug[slug],
    question_slug: slug,
    author,
    answer_text: answer,
    background_text: options.backgroundText ?? answer,
    language: options.language ?? "ru",
    source: options.source ?? "user_provided",
    source_question: options.sourceQuestion ?? "",
    source_note: options.sourceNote ?? "",
    use_in_background: options.useInBackground ?? true,
  });
}

const PROUST_1 = "Анкета Пруста N1";
const PROUST_2 = "Анкета Пруста N2";
const VANITY_FAIR = "Vanity Fair Proust Questionnaire";
const POZNER = "https://pozneronline.ru/2010/07/5758";

add("motto", "Marcel Proust, 16", "Любимое изречение - то, которое нельзя резюмировать (или пересказать вкратце), поскольку его наиболее простое выражение представляет собой всё, что есть самого лучшего, красивого и великого в природе.", { source: PROUST_1, sourceQuestion: "Ваше любимое изречение?", sourceNote: "Оригинальный вопрос был про любимое изречение." });
add("motto", "Marcel Proust, 19", "Я предпочитаю его не раскрывать, чтобы он не принёс мне несчастья.", { source: PROUST_2 });
add("current_state", "Marcel Proust, 19", "Досада, что пришлось так долго размышлять о себе, чтобы ответить на все эти вопросы.", { source: PROUST_2 });
add("favorite_color", "Marcel Proust, 16", "Я люблю все цвета.", { source: PROUST_1, sourceQuestion: "Ваш любимый цвет и цветок?", sourceNote: "Ответ разделен между цветом и цветком." });
add("favorite_color", "Marcel Proust, 19", "Красота заключается не в одном цвете, а в их гармонии.", { source: PROUST_2 });
add("favorite_occupation", "Marcel Proust, 16", "Читать, мечтать, заниматься поэзией, историей, посещать театр.", { source: PROUST_1 });
add("favorite_occupation", "Marcel Proust, 19", "Любить.", { source: PROUST_2 });
add("desired_ability", "Marcel Proust, 19", "Сила воли и умение очаровывать.", { source: PROUST_2 });
add("desired_self", "Marcel Proust, 16", "Поскольку этот вопрос неактуален, я бы предпочёл не отвечать на него. В то же самое время, я не отказался бы быть Плинием Младшим.", { source: PROUST_1, sourceQuestion: "Если не собой, то кем Вам хотелось бы быть?" });
add("desired_self", "Marcel Proust, 19", "Самим собой - таким, каким меня хотели бы видеть люди, которыми я восхищаюсь.", { source: PROUST_2 });
add("dream_of_happiness", "Marcel Proust, 16", "Жить с людьми, которых я люблю, в окружении красивой природы, среди множества книг и музыки, и неподалёку от французского театра.", { source: PROUST_1, sourceQuestion: "Ваша идея о счастье?" });
add("dream_of_happiness", "Marcel Proust, 19", "Боюсь, что она недостаточно возвышенна, к тому же боюсь разрушить её словами.", { source: PROUST_2 });
add("friends_qualities", "Marcel Proust, 19", "Нежность по отношению ко мне, при том, что их личности настолько утончённы, что их нежностью стоит дорожить.", { source: PROUST_2 });
add("favorite_writers", "Marcel Proust, 16", "Жорж Санд, Огюстен Тьерри.", { source: PROUST_1 });
add("favorite_writers", "Marcel Proust, 19", "Сегодня это Анатоль Франс и Пьер Лоти.", { source: PROUST_2 });
add("favorite_poets", "Marcel Proust, 16", "Мюссе.", { source: PROUST_1 });
add("favorite_poets", "Marcel Proust, 19", "Бодлер и Альфред де Виньи.", { source: PROUST_2 });
add("favorite_literary_hero", "Marcel Proust, 16", "Те из романов и лирики, которые скорее выражают идеал, чем служат примером для подражания.", { source: PROUST_1, sourceQuestion: "Каковы Ваши любимые литературные персонажи?" });
add("favorite_literary_hero", "Marcel Proust, 19", "Гамлет.", { source: PROUST_2 });
add("favorite_composers", "Marcel Proust, 16", "Моцарт, Гуно.", { source: PROUST_1, sourceQuestion: "Ваши любимые художники и композиторы?", sourceNote: "Ответ разделен между художниками и композиторами." });
add("favorite_composers", "Marcel Proust, 19", "Бетховен, Вагнер, Шуман.", { source: PROUST_2 });
add("favorite_artists", "Marcel Proust, 16", "Мейсонье.", { source: PROUST_1, sourceQuestion: "Ваши любимые художники и композиторы?", sourceNote: "Ответ разделен между художниками и композиторами." });
add("favorite_artists", "Marcel Proust, 19", "Леонардо да Винчи, Рембрандт.", { source: PROUST_2 });
add("real_life_heroes", "Marcel Proust, 16", "Нечто среднее между Сократом, Периклом, Магометом, Мюссе, Плинием Младшим и Огюстеном Тьерри.", { source: PROUST_1 });
add("real_life_heroes", "Marcel Proust, 19", "Месье Дарлю, месье Бутру.", { source: PROUST_2 });
add("favorite_names", "Marcel Proust, 19", "В каждый данный момент у меня только одно любимое имя.", { source: PROUST_2 });
add("forgiven_vices", "Marcel Proust, 16", "К частной жизни гениев.", { source: PROUST_1 });
add("forgiven_vices", "Marcel Proust, 19", "К тем, которые мне понятны.", { source: PROUST_2 });
add("most_hated", "Marcel Proust, 16", "К людям, которые не чувствуют, что есть добро, которые пренебрегают счастьем любви.", { source: PROUST_1, sourceQuestion: "К чему Вы испытываете отвращение?" });
add("most_hated", "Marcel Proust, 19", "То дурное, что есть во мне.", { source: PROUST_2 });
add("main_flaw", "Marcel Proust, 19", "Неумение, неспособность «желать».", { source: PROUST_2 });
add("main_trait", "Marcel Proust, 19", "Жажда быть любимым, а точнее, быть обласканным и избалованным, скорее чем служить предметом восхищения.", { source: PROUST_2 });
add("valued_human_qualities", "Marcel Proust, 16", "Ум, чувство морали.", { source: PROUST_1, sourceQuestion: "Качества, которые Вы больше всего цените в мужчине?", sourceNote: "Сведено в объединенный вопрос про качества в человеке." });
add("valued_human_qualities", "Marcel Proust, 16", "Нежность, естественность, ум.", { source: PROUST_1, sourceQuestion: "Качества, которые Вы больше всего цените в женщине?", sourceNote: "Сведено в объединенный вопрос про качества в человеке." });
add("valued_human_qualities", "Marcel Proust, 19", "Женственное обаяние.", { source: PROUST_2, sourceQuestion: "Качества, которые Вы больше всего цените в мужчине?", sourceNote: "Сведено в объединенный вопрос про качества в человеке." });
add("valued_human_qualities", "Marcel Proust, 19", "Добродетели мужчины и искренность в дружбе.", { source: PROUST_2, sourceQuestion: "Качества, которые Вы больше всего цените в женщине?", sourceNote: "Сведено в объединенный вопрос про качества в человеке." });
add("greatest_misfortune", "Marcel Proust, 16", "Быть в разлуке с мамой.", { source: PROUST_1, sourceQuestion: "Ваша идея о несчастье?" });
add("greatest_misfortune", "Marcel Proust, 19", "Никогда не знать мою маму или бабушку.", { source: PROUST_2 });
add("desired_death", "Marcel Proust, 19", "Став лучше, чем я теперь, и любимым.", { source: PROUST_2 });

add("dream_of_happiness", "Yayoi Kusama", "Happiness is when I make a good artwork.", { language: "en", source: VANITY_FAIR });
add("desired_ability", "Yayoi Kusama", "The talent to be able to paint forever.", { language: "en", source: VANITY_FAIR });
add("current_state", "Yayoi Kusama", "Feeling the final day of my life approaching, I think about becoming a great person, a great artist, and leaving great artworks in this world. I spend every day trying to make all possible efforts that one person can, and I want to do so until this life expires. This is everything that my art has reached. I will keep my struggle to send the message of Yayoi Kusama to future generations until the end of my life.", { language: "en", source: VANITY_FAIR });
add("greatest_misfortune", "Yayoi Kusama", "War. My childhood was a miserable one in the days of war. Art has always been my hope and support.", { language: "en", source: VANITY_FAIR, sourceQuestion: "What do you regard as the lowest depth of misery?" });
add("favorite_writers", "Yayoi Kusama", "Takuboku Ishikawa.", { language: "en", source: VANITY_FAIR, sourceQuestion: "Who is your favorite writer?" });
add("favorite_literary_hero", "Yayoi Kusama", "I don’t have one.", { language: "en", source: VANITY_FAIR, sourceQuestion: "Who is your favorite hero of fiction?" });
add("real_life_heroes", "Yayoi Kusama", "Myself.", { language: "en", source: VANITY_FAIR, sourceQuestion: "Who are your heroes in real life?" });
add("most_hated", "Yayoi Kusama", "Solitude.", { language: "en", source: VANITY_FAIR, sourceQuestion: "What is it that you most dislike?" });
add("desired_death", "Yayoi Kusama", "I would like to die in a way that my art would inspire the generations after. I would like to live till the end of my life in this world filled with endless love and prayers. I am trying to communicate with people through my work in order that they continue to appreciate my art even after I am gone.", { language: "en", source: VANITY_FAIR });
add("motto", "Yayoi Kusama", "The sun, the moon, the earth and stars are also polka dots. They cannot exist alone. Each and every one of us are polka dots. We gather and weave a beautiful pattern of polka dots.", { language: "en", source: VANITY_FAIR });

add("dream_of_happiness", "Cyndi Lauper", "Long walks with my husband. Being with my family. Making music, and writing when songs just fall together. And maybe a cannoli. Just one.", { language: "en", source: VANITY_FAIR });
add("favorite_names", "Cyndi Lauper", "Domenica (that’s my mother’s real name), Sparkle (my old dog), Declyn, David. Now, I can say Cynthia. At first I didn’t like Cynthia until my mother explained why she named me that. It was after the English goddess of the moon. How can you go wrong with that?", { language: "en", source: VANITY_FAIR });
add("current_state", "Cyndi Lauper", "Sunny with a chance of rain.", { language: "en", source: VANITY_FAIR });
add("greatest_misfortune", "Cyndi Lauper", "Losing my voice.", { language: "en", source: VANITY_FAIR, sourceQuestion: "What do you regard as the lowest depth of misery?" });
add("favorite_writers", "Cyndi Lauper", "The Brontë sisters, and I love Maya Angelou, Alice Walker, Lisa See, Haruki Murakami, Patti Smith, and Charles Dickens.", { language: "en", source: VANITY_FAIR });

add("favorite_literary_hero", "Владимир Познер", "Д’Артаньян.", { source: POZNER });
add("main_trait", "Владимир Познер", "Терпение.", { source: POZNER });
add("desired_ability", "Владимир Познер", "Умением рисовать.", { source: POZNER, sourceQuestion: "Каким бы талантом вы хотели обладать?" });
add("dream_of_happiness", "Владимир Познер", "Полностью выразить себя в любви, в детях и в работе.", { source: POZNER, sourceQuestion: "Что для вас предел счастья?" });

add("desired_ability", "Donatella Versace", "To sing. I have been surrounded by the most incredible singers my whole life, from Madonna to Prince, Lady Gaga, J.Lo, Beyoncé. To be able to have their talent for just one second would be incredible.", { language: "en", source: VANITY_FAIR });
add("current_state", "Donatella Versace", "Excited, energized, impatient.", { language: "en", source: VANITY_FAIR });
add("favorite_occupation", "Donatella Versace", "The one I have right now.", { language: "en", source: VANITY_FAIR });
add("main_trait", "Donatella Versace", "That I get what I want.", { language: "en", source: VANITY_FAIR, sourceQuestion: "What is your most marked characteristic?" });
add("valued_human_qualities", "Donatella Versace", "Charm and a good body.", { language: "en", source: VANITY_FAIR, sourceQuestion: "What is the quality you most like in a man?", sourceNote: "Сведено в объединенный вопрос про качества в человеке." });
add("valued_human_qualities", "Donatella Versace", "Strength and power.", { language: "en", source: VANITY_FAIR, sourceQuestion: "What is the quality you most like in a woman?", sourceNote: "Сведено в объединенный вопрос про качества в человеке." });

add("friends_qualities", "Donatella Versace", "Love, compassion, concern, humor, intelligence.", { language: "en", source: VANITY_FAIR });
add("favorite_literary_hero", "Donatella Versace", "The Medusa.", { language: "en", source: VANITY_FAIR, sourceQuestion: "Who is your favorite hero of fiction?" });
add("real_life_heroes", "Donatella Versace", "Kids on the street. That’s where you find real energy.", { language: "en", source: VANITY_FAIR, sourceQuestion: "Who are your heroes in real life?" });
add("favorite_names", "Donatella Versace", "Allegra, Daniel.", { language: "en", source: VANITY_FAIR });
add("most_hated", "Donatella Versace", "Intolerance.", { language: "en", source: VANITY_FAIR, sourceQuestion: "What is it that you most dislike?" });
add("desired_death", "Donatella Versace", "Without me knowing it.", { language: "en", source: VANITY_FAIR });

add("desired_ability", "Olivia de Havilland", "The gift of coolheadedness or the ability to tap-dance.", { language: "en", source: VANITY_FAIR });
add("favorite_names", "Olivia de Havilland", "Alexandra and Alexis.", { language: "en", source: VANITY_FAIR });

add("favorite_occupation", "Olivia de Havilland", "Doing cryptic crosswords or, equally, reading tales of mystery and imagination.", { language: "en", source: VANITY_FAIR });
add("valued_human_qualities", "Olivia de Havilland", "Clear-sightedness, humor, fairness, fidelity to purpose.", { language: "en", source: VANITY_FAIR, sourceQuestion: "What is the quality you most like in a man?", sourceNote: "Сведено в объединенный вопрос про качества в человеке." });
add("valued_human_qualities", "Olivia de Havilland", "Thoughtfulness.", { language: "en", source: VANITY_FAIR, sourceQuestion: "What is the quality you most like in a woman?", sourceNote: "Сведено в объединенный вопрос про качества в человеке." });
add("most_hated", "Olivia de Havilland", "The deception and exploitation of the naive and defenseless.", { language: "en", source: VANITY_FAIR, sourceQuestion: "What is it that you most dislike?" });
add("desired_death", "Olivia de Havilland", "I would prefer to live forever in perfect health.", { language: "en", source: VANITY_FAIR, sourceNote: "Сокращено для фонового использования." });
add("motto", "Olivia de Havilland", "Dominus Fortissima Turris.", { language: "la", source: VANITY_FAIR, sourceNote: "В источнике дан перевод: God is the strongest tower / God is my tower of strength." });
add("current_state", "Baz Luhrmann", "I’m oscillating between the joys of playing hooky from responsibilities and a desperate need to take on new creative responsibilities.", { language: "en", source: VANITY_FAIR });
add("favorite_occupation", "Baz Luhrmann", "I don’t know, what I do is all I’ve ever done.", { language: "en", source: VANITY_FAIR });
add("main_trait", "Baz Luhrmann", "Storytelling.", { language: "en", source: VANITY_FAIR, sourceQuestion: "What is your most marked characteristic?" });
add("dream_of_happiness", "Baz Luhrmann", "To love and be loved in return.", { language: "en", source: VANITY_FAIR });
add("favorite_writers", "Baz Luhrmann", "Huxley, Garcia Marquez, Shakespeare, Tolstoy, Moliere, Fitzgerald, to name but a few.", { language: "en", source: VANITY_FAIR });
add("friends_qualities", "Baz Luhrmann", "Loyalty.", { language: "en", source: VANITY_FAIR });
add("favorite_literary_hero", "Baz Luhrmann", "I love heroic characters who embody the Greek quality of pothos.", { language: "en", source: VANITY_FAIR, sourceQuestion: "Who is your favorite hero of fiction?" });
add("most_hated", "Baz Luhrmann", "Mediocrity and boredom.", { language: "en", source: VANITY_FAIR, sourceQuestion: "What is it that you most dislike?" });
add("motto", "Baz Luhrmann", "A life lived in fear is a life half lived.", { language: "en", source: VANITY_FAIR });
add("desired_ability", "Baz Luhrmann", "Beach; the ability to spell.", { language: "en", source: VANITY_FAIR });
add("favorite_names", "Baz Luhrmann", "Ones that truly evoke people’s character.", { language: "en", source: VANITY_FAIR });
add("greatest_misfortune", "Baz Luhrmann", "To be unloved and lonely.", { language: "en", source: VANITY_FAIR, sourceQuestion: "What do you regard as the lowest depth of misery?" });
function csvEscape(value) {
  const text = String(value ?? "");
  return /[",\n;]/.test(text) ? `"${text.replaceAll('"', '""')}"` : text;
}

function toCsv(rows, headers) {
  return [
    headers.join(","),
    ...rows.map((row) => headers.map((header) => csvEscape(row[header])).join(",")),
  ].join("\n");
}

const questionRows = questions.map((question) => ({
  ...question,
  answer_count: answers.filter((answer) => answer.question_id === question.id).length,
}));

const questionHeaders = ["id", "order", "slug", "question", "category", "active", "answer_count"];
const answerHeaders = [
  "id",
  "question_id",
  "question_slug",
  "author",
  "answer_text",
  "background_text",
  "language",
  "source",
  "source_question",
  "source_note",
  "use_in_background",
];

const questionById = Object.fromEntries(questionRows.map((question) => [question.id, question]));
const flatRows = answers.map((answer) => {
  const question = questionById[answer.question_id];
  return {
    answer_id: answer.id,
    question_id: answer.question_id,
    question_order: question.order,
    question_slug: answer.question_slug,
    question: question.question,
    author: answer.author,
    answer_text: answer.answer_text,
    background_text: answer.background_text,
    language: answer.language,
    source: answer.source,
    source_question: answer.source_question,
    source_note: answer.source_note,
    use_in_background: answer.use_in_background,
  };
});
const flatHeaders = [
  "answer_id",
  "question_id",
  "question_order",
  "question_slug",
  "question",
  "author",
  "answer_text",
  "background_text",
  "language",
  "source",
  "source_question",
  "source_note",
  "use_in_background",
];
const grouped = questionRows.map((question) => ({
  ...question,
  answers: answers
    .filter((answer) => answer.question_id === question.id)
    .map((answer) => ({
      id: answer.id,
      author: answer.author,
      answer_text: answer.answer_text,
      background_text: answer.background_text,
      language: answer.language,
      source: answer.source,
      source_question: answer.source_question,
      source_note: answer.source_note,
      use_in_background: answer.use_in_background,
    })),
}));

await fs.mkdir(outputDir, { recursive: true });
await fs.writeFile(
  path.join(outputDir, "proust_questions.csv"),
  toCsv(questionRows, questionHeaders),
  "utf8",
);
await fs.writeFile(
  path.join(outputDir, "proust_answers.csv"),
  toCsv(answers, answerHeaders),
  "utf8",
);
await fs.writeFile(
  path.join(outputDir, "proust_questionnaire_db.csv"),
  toCsv(flatRows, flatHeaders),
  "utf8",
);
await fs.writeFile(
  path.join(outputDir, "proust_questionnaire_db.json"),
  JSON.stringify(grouped, null, 2),
  "utf8",
);
await fs.writeFile(
  path.join(outputDir, "proust_background_answers.json"),
  JSON.stringify(
    answers
      .filter((answer) => answer.use_in_background)
      .map((answer) => ({
        id: answer.id,
        question_id: answer.question_id,
        question_slug: answer.question_slug,
        background_text: answer.background_text,
        language: answer.language,
      })),
    null,
    2,
  ),
  "utf8",
);

const workbook = await Workbook.fromCSV(toCsv(questionRows, questionHeaders), {
  sheetName: "Questions",
});
const answerSheet = workbook.worksheets.add("Answers");
const answerValues = [
  answerHeaders,
  ...answers.map((answer) => answerHeaders.map((header) => answer[header])),
];
answerSheet.getRange(`A1:K${answerValues.length}`).values = answerValues;

const questionSheet = workbook.worksheets.getItem("Questions");
questionSheet.getRange("A1:G1").format = {
  fill: "#202124",
  font: { color: "#FFFFFF", bold: true },
  horizontalAlignment: "center",
  verticalAlignment: "center",
  wrapText: true,
};
questionSheet.getRange(`A1:G${questionRows.length + 1}`).format.wrapText = true;
questionSheet.getRange("A:A").format.columnWidthPx = 48;
questionSheet.getRange("B:B").format.columnWidthPx = 56;
questionSheet.getRange("C:C").format.columnWidthPx = 190;
questionSheet.getRange("D:D").format.columnWidthPx = 330;
questionSheet.getRange("E:G").format.columnWidthPx = 110;
questionSheet.freezePanes.freezeRows(1);
questionSheet.tables.add(`A1:G${questionRows.length + 1}`, true).name = "ProustQuestions";

answerSheet.getRange("A1:K1").format = {
  fill: "#202124",
  font: { color: "#FFFFFF", bold: true },
  horizontalAlignment: "center",
  verticalAlignment: "center",
  wrapText: true,
};
answerSheet.getRange(`A1:K${answerValues.length}`).format.wrapText = true;
answerSheet.getRange(`A1:K${answerValues.length}`).format.verticalAlignment = "top";
answerSheet.getRange("A:A").format.columnWidthPx = 48;
answerSheet.getRange("B:C").format.columnWidthPx = 110;
answerSheet.getRange("D:D").format.columnWidthPx = 170;
answerSheet.getRange("E:F").format.columnWidthPx = 470;
answerSheet.getRange("G:H").format.columnWidthPx = 130;
answerSheet.getRange("I:K").format.columnWidthPx = 220;
answerSheet.freezePanes.freezeRows(1);
answerSheet.tables.add(`A1:K${answerValues.length}`, true).name = "ProustAnswers";

const blob = await SpreadsheetFile.exportXlsx(workbook);
await blob.save(path.join(outputDir, "proust_questionnaire_db.xlsx"));

console.log(`Wrote ${questionRows.length} questions and ${answers.length} answers to ${outputDir}`);

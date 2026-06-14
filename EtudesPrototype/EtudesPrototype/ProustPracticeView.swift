import SwiftUI

struct ProustQuestion: Identifiable, Hashable {
    let id: String
    let text: String
}

struct ProustSubmission: Identifiable, Codable, Equatable {
    var id = UUID()
    var nickname: String
    var createdAt: Date
    var modeTitle: String
    var answers: [String: String]
}

struct ProustPracticeView: View {
    @State private var route: ProustRoute = .intro
    @State private var mode: ProustMode = .short
    @State private var questionIndex = 0
    @State private var answers: [String: String] = [:]
    @State private var nickname = ""
    @State private var agreedToPublish = false
    @State private var submissions = ProustSubmissionStore.load()

    private var activeQuestions: [ProustQuestion] {
        mode.questions
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ProustPracticeBackground()
                    .ignoresSafeArea()

                switch route {
                case .intro:
                    introView
                case .questionnaire:
                    questionnaireView
                case .consent:
                    consentView
                case .results:
                    resultsView
                }
            }
            .navigationTitle("Практики")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(EtudesPalette.ink)
    }

    private var introView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Практика 1")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(EtudesPalette.muted)
                        .textCase(.uppercase)

                    Text("Анкета Пруста")
                        .font(.system(size: 42, weight: .semibold, design: .serif))
                        .foregroundStyle(EtudesPalette.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)

                    Text("Короткий салонный портрет: несколько вопросов, немного тишины и общая стена ответов.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(EtudesPalette.muted)
                }
                .padding(.top, 22)

                proustStage

                VStack(spacing: 12) {
                    modeButton(.short)
                    modeButton(.full)
                }
            }
            .padding(22)
        }
        .scrollIndicators(.hidden)
    }

    private var proustStage: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(EtudesPalette.panel.opacity(0.82))
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(.white.opacity(0.46), lineWidth: 1)
                }

            HStack {
                Spacer()

                BundledProustImage()
                    .scaledToFill()
                    .frame(width: 164, height: 210)
                    .clipped()
                    .saturation(0.82)
                    .contrast(0.92)
                    .opacity(0.68)
                    .blendMode(.multiply)
            }
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            LinearGradient(
                colors: [
                    EtudesPalette.panel,
                    EtudesPalette.panel.opacity(0.84),
                    EtudesPalette.panel.opacity(0.16)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .bottom, spacing: 12) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 42, weight: .light))
                        .foregroundStyle(EtudesPalette.grayLilac)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Marcel")
                        Text("Proust")
                    }
                    .font(.system(size: 30, weight: .medium, design: .serif))
                    .foregroundStyle(EtudesPalette.ink.opacity(0.80))
                }

                Text("Ваш девиз?")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(EtudesPalette.ink)

                Text("Вопросы из веб-версии перенесены в нативную практику Этюдов.")
                    .font(.footnote)
                    .foregroundStyle(EtudesPalette.muted)
                    .frame(maxWidth: 220, alignment: .leading)
            }
            .padding(22)
        }
        .frame(height: 210)
        .overlay {
            NoiseOverlay(opacity: 0.035, dotCount: 220)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .blendMode(.multiply)
        }
    }

    private func modeButton(_ nextMode: ProustMode) -> some View {
        Button {
            start(nextMode)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: nextMode.symbol)
                    .font(.title3)
                    .frame(width: 34, height: 34)
                    .background(EtudesPalette.ink.opacity(0.08), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(nextMode.title)
                        .font(.headline)
                    Text(nextMode.subtitle)
                        .font(.footnote)
                        .foregroundStyle(EtudesPalette.muted)
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.headline)
                    .foregroundStyle(EtudesPalette.muted)
            }
            .foregroundStyle(EtudesPalette.ink)
            .padding(16)
            .background(EtudesPalette.panel, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(EtudesPalette.line.opacity(0.75), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var questionnaireView: some View {
        let question = activeQuestions[questionIndex]

        return VStack(spacing: 0) {
            HStack {
                Button {
                    route = .intro
                } label: {
                    Label("Анкета", systemImage: "chevron.left")
                        .labelStyle(.titleAndIcon)
                }
                .font(.callout.weight(.medium))

                Spacer()

                Text("\(questionIndex + 1) / \(activeQuestions.count)")
                    .font(.subheadline.monospacedDigit().weight(.semibold))
                    .foregroundStyle(EtudesPalette.muted)
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)

            ProgressView(value: Double(questionIndex + 1), total: Double(activeQuestions.count))
                .tint(EtudesPalette.ink)
                .padding(.horizontal, 22)
                .padding(.top, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ProustFloatingAnswersView(questionID: question.id)
                        .frame(height: 128)
                        .padding(.top, 18)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Вопрос \(questionIndex + 1)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(EtudesPalette.muted)
                            .textCase(.uppercase)

                        Text(question.text)
                            .font(.system(size: 31, weight: .semibold, design: .serif))
                            .foregroundStyle(EtudesPalette.ink)
                            .lineSpacing(3)
                    }
                    .padding(22)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(EtudesPalette.panel.opacity(0.92), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(.white.opacity(0.50), lineWidth: 1)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ваш ответ")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(EtudesPalette.muted)

                        TextEditor(text: binding(for: question.id))
                            .scrollContentBackground(.hidden)
                            .font(.body)
                            .lineSpacing(3)
                            .frame(minHeight: 132)
                            .padding(10)
                            .background(.white.opacity(0.50), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(EtudesPalette.line.opacity(0.80), lineWidth: 1)
                            }
                    }
                }
                .padding(22)
            }
            .scrollIndicators(.hidden)

            HStack(spacing: 12) {
                Button {
                    previousQuestion()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .frame(width: 50, height: 50)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .disabled(questionIndex == 0)

                Button {
                    nextQuestion()
                } label: {
                    HStack {
                        Text(questionIndex == activeQuestions.count - 1 ? "Завершить" : "Дальше")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .tint(EtudesPalette.ink)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 14)
        }
    }

    private var consentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Почти готово")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(EtudesPalette.muted)
                    .textCase(.uppercase)

                Text("Покажем общую стену ответов?")
                    .font(.system(size: 34, weight: .semibold, design: .serif))
                    .foregroundStyle(EtudesPalette.ink)

                Text("Введите псевдоним. Ответы сохранятся на этом устройстве и будут видны в результатах без настоящего имени.")
                    .font(.body)
                    .lineSpacing(4)
                    .foregroundStyle(EtudesPalette.muted)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Псевдоним")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(EtudesPalette.muted)

                    TextField("Аврора", text: $nickname)
                        .textFieldStyle(.plain)
                        .padding(15)
                        .background(.white.opacity(0.54), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(EtudesPalette.line.opacity(0.8), lineWidth: 1)
                        }
                }
                .padding(.top, 8)

                Toggle("Я согласен отправить ответы в общую анонимизированную стену.", isOn: $agreedToPublish)
                    .toggleStyle(.switch)
                    .font(.callout)
                    .foregroundStyle(EtudesPalette.ink)
                    .padding(.vertical, 6)

                Button {
                    saveSubmission()
                } label: {
                    Label("Отправить и смотреть", systemImage: "arrow.right")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .tint(EtudesPalette.ink)
                .disabled(!agreedToPublish)
            }
            .padding(22)
            .background(EtudesPalette.panel.opacity(0.86), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .padding(22)
            .padding(.top, 52)
        }
        .scrollIndicators(.hidden)
    }

    private var resultsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Общая стена")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(EtudesPalette.muted)
                            .textCase(.uppercase)

                        Text("Ответы участников")
                            .font(.title.weight(.semibold))
                            .foregroundStyle(EtudesPalette.ink)
                    }

                    Spacer()

                    Button("Еще раз") {
                        route = .intro
                    }
                    .font(.callout.weight(.medium))
                }

                ForEach(ProustMode.full.questions) { question in
                    let items = answers(for: question.id)

                    if !items.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(question.text)
                                .font(.headline)
                                .foregroundStyle(EtudesPalette.ink)

                            ForEach(items.prefix(4)) { item in
                                VStack(alignment: .leading, spacing: 7) {
                                    Text(item.text)
                                        .font(.body)
                                        .foregroundStyle(EtudesPalette.ink)
                                        .lineSpacing(3)

                                    Text(item.author)
                                        .font(.caption)
                                        .foregroundStyle(EtudesPalette.muted)
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.white.opacity(0.48), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }
                        .padding(16)
                        .background(EtudesPalette.panel.opacity(0.88), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(EtudesPalette.line.opacity(0.70), lineWidth: 1)
                        }
                    }
                }
            }
            .padding(22)
        }
        .scrollIndicators(.hidden)
    }

    private func binding(for questionID: String) -> Binding<String> {
        Binding(
            get: { answers[questionID, default: ""] },
            set: { answers[questionID] = $0 }
        )
    }

    private func start(_ nextMode: ProustMode) {
        mode = nextMode
        questionIndex = 0
        answers = [:]
        nickname = ""
        agreedToPublish = false
        route = .questionnaire
    }

    private func previousQuestion() {
        guard questionIndex > 0 else { return }
        questionIndex -= 1
    }

    private func nextQuestion() {
        if questionIndex < activeQuestions.count - 1 {
            questionIndex += 1
        } else {
            route = .consent
        }
    }

    private func saveSubmission() {
        let visibleAnswers = answers
            .mapValues { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.value.isEmpty }

        let submission = ProustSubmission(
            nickname: nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Аноним" : nickname,
            createdAt: Date(),
            modeTitle: mode.title,
            answers: visibleAnswers
        )
        submissions.insert(submission, at: 0)
        ProustSubmissionStore.save(submissions)
        route = .results
    }

    private func answers(for questionID: String) -> [ProustWallAnswer] {
        let local = submissions.compactMap { submission -> ProustWallAnswer? in
            guard let answer = submission.answers[questionID], !answer.isEmpty else { return nil }
            return ProustWallAnswer(text: answer, author: "\(submission.nickname) · \(submission.modeTitle)")
        }

        return local + ProustDemoAnswers.answers(for: questionID)
    }
}

private enum ProustRoute {
    case intro
    case questionnaire
    case consent
    case results
}

private enum ProustMode {
    case short
    case full

    var title: String {
        switch self {
        case .short: "Короткая версия"
        case .full: "Полная версия"
        }
    }

    var subtitle: String {
        "\(questions.count) вопросов"
    }

    var symbol: String {
        switch self {
        case .short: "timer"
        case .full: "text.book.closed"
        }
    }

    var questions: [ProustQuestion] {
        switch self {
        case .short:
            ProustQuestionBank.short
        case .full:
            ProustQuestionBank.full
        }
    }
}

private enum ProustQuestionBank {
    static let full: [ProustQuestion] = [
        ProustQuestion(id: "motto", text: "Ваш девиз?"),
        ProustQuestion(id: "current_state", text: "Ваше состояние духа в настоящий момент?"),
        ProustQuestion(id: "favorite_color", text: "Ваш любимый цвет?"),
        ProustQuestion(id: "favorite_occupation", text: "Какое Ваше любимое занятие?"),
        ProustQuestion(id: "desired_ability", text: "Способность, которой вам хотелось бы обладать?"),
        ProustQuestion(id: "desired_self", text: "Каким Вы хотели бы быть?"),
        ProustQuestion(id: "dream_of_happiness", text: "Какова Ваша мечта о счастье?"),
        ProustQuestion(id: "friends_qualities", text: "Что Вы больше всего цените в Ваших друзьях?"),
        ProustQuestion(id: "favorite_writers", text: "Ваши любимые писатели?"),
        ProustQuestion(id: "favorite_poets", text: "Ваши любимые поэты?"),
        ProustQuestion(id: "favorite_literary_hero", text: "Любимый литературный герой?"),
        ProustQuestion(id: "favorite_composers", text: "Любимые композиторы?"),
        ProustQuestion(id: "favorite_artists", text: "Любимые художники?"),
        ProustQuestion(id: "real_life_heroes", text: "Любимые герои в реальной жизни?"),
        ProustQuestion(id: "favorite_names", text: "Любимые имена?"),
        ProustQuestion(id: "forgiven_vices", text: "К каким порокам Вы чувствуете наибольшее снисхождение?"),
        ProustQuestion(id: "most_hated", text: "Что Вы больше всего ненавидите?"),
        ProustQuestion(id: "main_flaw", text: "Что является Вашим главным недостатком?"),
        ProustQuestion(id: "main_trait", text: "Ваша самая характерная черта?"),
        ProustQuestion(id: "valued_human_qualities", text: "Качества, которые Вы больше всего цените в человеке?"),
        ProustQuestion(id: "greatest_misfortune", text: "Что Вы считаете самым большим несчастьем?"),
        ProustQuestion(id: "desired_death", text: "Как Вы хотели бы умереть?")
    ]

    static let short: [ProustQuestion] = [
        full[0],
        full[1],
        full[6],
        full[7],
        full[18],
        full[19]
    ]
}

private struct ProustPracticeBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    EtudesPalette.ivory,
                    EtudesPalette.background,
                    Color(red: 0.90, green: 0.88, blue: 0.83)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Canvas { context, size in
                context.addFilter(.blur(radius: 42))
                let shapes: [(CGPoint, CGSize, Color, Double)] = [
                    (CGPoint(x: size.width * 0.20, y: size.height * 0.18), CGSize(width: 280, height: 190), EtudesPalette.fadedRose, 0.16),
                    (CGPoint(x: size.width * 0.82, y: size.height * 0.28), CGSize(width: 310, height: 230), EtudesPalette.dustyBlue, 0.18),
                    (CGPoint(x: size.width * 0.42, y: size.height * 0.76), CGSize(width: 330, height: 210), EtudesPalette.paleSage, 0.14)
                ]

                for shape in shapes {
                    let rect = CGRect(
                        x: shape.0.x - shape.1.width / 2,
                        y: shape.0.y - shape.1.height / 2,
                        width: shape.1.width,
                        height: shape.1.height
                    )
                    context.opacity = shape.3
                    context.fill(Path(ellipseIn: rect), with: .color(shape.2))
                }
            }
            .allowsHitTesting(false)
        }
    }
}

private struct ProustFloatingAnswersView: View {
    let questionID: String

    private var answers: [ProustWallAnswer] {
        ProustDemoAnswers.answers(for: questionID)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(Array(answers.prefix(5).enumerated()), id: \.element.id) { index, answer in
                    Text(answer.text)
                        .font(.caption)
                        .lineLimit(2)
                        .foregroundStyle(EtudesPalette.ink.opacity(0.58))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.44), in: Capsule())
                        .position(position(for: index, size: proxy.size))
                }
            }
        }
    }

    private func position(for index: Int, size: CGSize) -> CGPoint {
        let points = [
            CGPoint(x: size.width * 0.22, y: size.height * 0.24),
            CGPoint(x: size.width * 0.72, y: size.height * 0.18),
            CGPoint(x: size.width * 0.52, y: size.height * 0.50),
            CGPoint(x: size.width * 0.28, y: size.height * 0.78),
            CGPoint(x: size.width * 0.78, y: size.height * 0.74)
        ]
        return points[index % points.count]
    }
}

private struct BundledProustImage: View {
    var body: some View {
        if let path = Bundle.main.path(forResource: "proust", ofType: "jpg"),
           let image = UIImage(contentsOfFile: path) {
            Image(uiImage: image)
                .resizable()
        } else {
            LinearGradient(
                colors: [
                    EtudesPalette.warmMilk,
                    EtudesPalette.grayLilac.opacity(0.42),
                    EtudesPalette.fadedRose.opacity(0.34)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

private struct ProustWallAnswer: Identifiable {
    let id = UUID()
    let text: String
    let author: String
}

private enum ProustDemoAnswers {
    static func answers(for questionID: String) -> [ProustWallAnswer] {
        data[questionID, default: []]
    }

    private static let data: [String: [ProustWallAnswer]] = [
        "motto": [
            ProustWallAnswer(text: "Сначала смотреть, потом называть.", author: "Гость в синем"),
            ProustWallAnswer(text: "Не торопить смысл.", author: "Северная комната"),
            ProustWallAnswer(text: "Оставлять место для воздуха.", author: "Поля")
        ],
        "current_state": [
            ProustWallAnswer(text: "Собранность и легкое электричество.", author: "Гость в синем"),
            ProustWallAnswer(text: "Любопытство.", author: "Полевая заметка")
        ],
        "dream_of_happiness": [
            ProustWallAnswer(text: "Делать важное рядом с людьми, которым не нужно все объяснять.", author: "Гость в синем"),
            ProustWallAnswer(text: "Дом, работа и люди, к которым хочется возвращаться.", author: "Поля")
        ],
        "friends_qualities": [
            ProustWallAnswer(text: "Точность, нежность и чувство юмора.", author: "Гость в синем"),
            ProustWallAnswer(text: "Способность быть рядом без шума.", author: "Чернила")
        ],
        "favorite_color": [
            ProustWallAnswer(text: "Пыльный голубой.", author: "Полевая заметка")
        ],
        "favorite_occupation": [
            ProustWallAnswer(text: "Собирать смыслы в систему.", author: "Полевая заметка")
        ],
        "main_trait": [
            ProustWallAnswer(text: "Долго всматриваться, прежде чем решать.", author: "Аврора")
        ],
        "valued_human_qualities": [
            ProustWallAnswer(text: "Деликатность, точность, способность слышать паузы.", author: "Ника")
        ]
    ]
}

private enum ProustSubmissionStore {
    private static let key = "etudes_proust_submissions_v1"

    static func load() -> [ProustSubmission] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([ProustSubmission].self, from: data)) ?? []
    }

    static func save(_ submissions: [ProustSubmission]) {
        guard let data = try? JSONEncoder().encode(submissions) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

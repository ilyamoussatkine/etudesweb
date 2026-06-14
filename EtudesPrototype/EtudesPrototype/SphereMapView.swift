import SwiftUI

struct SphereMapView: View {
    @State private var spheres = Sphere.samples
    @State private var selectedSphereID: Sphere.ID?
    @State private var showingComposer = false

    private let sphereSize: CGFloat = 138
    private let cellHeight: CGFloat = 220

    private var selectedIndex: Int? {
        guard let selectedSphereID else { return nil }
        return spheres.firstIndex { $0.id == selectedSphereID }
    }

    var body: some View {
        ZStack {
            AtmosphericMapBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                mapHeader

                ScrollView(.vertical) {
                    GeometryReader { proxy in
                        ZStack {
                            ForEach(spheres) { sphere in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.34)) {
                                        selectedSphereID = sphere.id
                                    }
                                } label: {
                                    SphereMapItemView(sphere: sphere, sphereSize: sphereSize)
                                }
                                .buttonStyle(SphereLensButtonStyle())
                                    .position(position(for: sphere, in: proxy.size.width))
                            }
                        }
                        .frame(width: proxy.size.width, height: canvasHeight(for: spheres.count, width: proxy.size.width))
                    }
                    .frame(height: canvasHeight(for: spheres.count, width: UIScreen.main.bounds.width))
                    .padding(.top, 8)
                    .padding(.bottom, 22)
                }
                .scrollIndicators(.hidden)
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .black, location: 0.035),
                            .init(color: .black, location: 0.94),
                            .init(color: .clear, location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }

                Button {
                    showingComposer = true
                } label: {
                    Label("Создать сферу", systemImage: "plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .tint(EtudesPalette.ink)
                .padding(.horizontal, 24)
                .padding(.bottom, 14)
            }

            if let selectedIndex {
                ExpandedSphereOverlay(
                    spheres: spheres,
                    selectedIndex: selectedIndex,
                    onSelect: { index in
                        withAnimation(.easeInOut(duration: 0.38)) {
                            selectedSphereID = spheres[index].id
                        }
                    },
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.36)) {
                            selectedSphereID = nil
                        }
                    }
                )
                .transition(.opacity)
            }
        }
        .sheet(isPresented: $showingComposer) {
            CreateSphereView { newSphere in
                var positionedSphere = newSphere
                positionedSphere.gridIndex = spheres.count
                spheres.append(positionedSphere)
            }
        }
    }

    private var mapHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Карта")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(EtudesPalette.ink)

                Text("Оптическое поле сфер")
                    .font(.subheadline)
                    .foregroundStyle(EtudesPalette.muted)
            }

            Spacer()

            Text("\(spheres.count)")
                .font(.title3.monospacedDigit())
                .foregroundStyle(EtudesPalette.muted)
        }
        .padding(.horizontal, 24)
        .padding(.top, 22)
        .padding(.bottom, 8)
    }

    private func columns(for width: CGFloat) -> Int {
        max(Int(width / 178), 2)
    }

    private func canvasHeight(for count: Int, width: CGFloat) -> CGFloat {
        let columnCount = columns(for: width)
        let rows = max(Int(ceil(Double(count) / Double(columnCount))), 1)
        return CGFloat(rows) * cellHeight + 54
    }

    private func position(for sphere: Sphere, in width: CGFloat) -> CGPoint {
        let columnCount = columns(for: width)
        let row = sphere.gridIndex / columnCount
        let column = sphere.gridIndex % columnCount
        let horizontalPadding: CGFloat = 26
        let availableWidth = max(width - horizontalPadding * 2, sphereSize * CGFloat(columnCount))
        let cellWidth = availableWidth / CGFloat(columnCount)
        let maxXOffset = max((cellWidth - sphereSize) * 0.36, 8)
        let maxYOffset = max((cellHeight - sphereSize - 38) * 0.22, 8)
        let xOffset = min(max(sphere.offsetSeed.width, -maxXOffset), maxXOffset)
        let yOffset = min(max(sphere.offsetSeed.height, -maxYOffset), maxYOffset)
        let x = horizontalPadding + cellWidth * (CGFloat(column) + 0.5) + xOffset
        let y = cellHeight * (CGFloat(row) + 0.5) + yOffset + 18
        return CGPoint(x: x, y: y)
    }
}

struct AtmosphericMapBackground: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate / 8.5
            let driftA = CGFloat(sin(phase))
            let driftB = CGFloat(cos(phase * 0.7))
            let driftC = CGFloat(cos(phase * 0.8))
            let driftD = CGFloat(sin(phase * 1.2))
            let driftE = CGFloat(cos(phase * 1.1))

            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: 0xFFFFFF),
                        Color(hex: 0xF8F8F8),
                        Color(hex: 0x999999).opacity(0.34),
                        Color(hex: 0xEDEDED),
                        Color(hex: 0xFFFFFF)
                    ],
                    startPoint: UnitPoint(
                        x: 0.04 + 0.18 * driftA,
                        y: 0.00
                    ),
                    endPoint: UnitPoint(
                        x: 0.92 + 0.16 * driftB,
                        y: 1.0
                    )
                )

                Canvas { context, size in
                    let clouds: [(CGPoint, CGSize, Double)] = [
                        (CGPoint(x: size.width * (0.10 + 0.08 * driftA), y: size.height * 0.10), CGSize(width: size.width * 0.82, height: 230), 0.30),
                        (CGPoint(x: size.width * (0.88 + 0.07 * driftC), y: size.height * 0.24), CGSize(width: size.width * 0.76, height: 280), 0.24),
                        (CGPoint(x: size.width * (0.30 + 0.09 * driftD), y: size.height * 0.48), CGSize(width: size.width * 0.92, height: 250), 0.22),
                        (CGPoint(x: size.width * (0.76 + 0.08 * driftE), y: size.height * 0.69), CGSize(width: size.width * 0.86, height: 300), 0.26),
                        (CGPoint(x: size.width * (0.18 - 0.07 * driftB), y: size.height * 0.88), CGSize(width: size.width * 0.88, height: 260), 0.20)
                    ]

                    context.addFilter(.blur(radius: 30))
                    for cloud in clouds {
                        let rect = CGRect(
                            x: cloud.0.x - cloud.1.width / 2,
                            y: cloud.0.y - cloud.1.height / 2,
                            width: cloud.1.width,
                            height: cloud.1.height
                        )
                        context.opacity = cloud.2
                        context.fill(Path(ellipseIn: rect), with: .color(Color(hex: 0x999999)))
                    }
                }
                .allowsHitTesting(false)
                .blendMode(.multiply)

                Canvas { context, size in
                    context.addFilter(.blur(radius: 42))
                    let highlights: [(CGPoint, CGSize, Double)] = [
                        (CGPoint(x: size.width * (0.66 - 0.05 * driftD), y: size.height * 0.16), CGSize(width: size.width * 0.82, height: 250), 0.52),
                        (CGPoint(x: size.width * (0.42 + 0.04 * driftA), y: size.height * 0.62), CGSize(width: size.width * 0.80, height: 310), 0.42)
                    ]

                    for highlight in highlights {
                        let rect = CGRect(
                            x: highlight.0.x - highlight.1.width / 2,
                            y: highlight.0.y - highlight.1.height / 2,
                            width: highlight.1.width,
                            height: highlight.1.height
                        )
                        context.opacity = highlight.2
                        context.fill(Path(ellipseIn: rect), with: .color(.white))
                    }
                }
                .allowsHitTesting(false)
                .blendMode(.screen)

                NoiseOverlay(opacity: 0.038, dotCount: 1200)
                    .blendMode(.multiply)
            }
        }
    }
}

struct SphereMapItemView: View {
    let sphere: Sphere
    let sphereSize: CGFloat

    var body: some View {
        AtmosphericSphereLensView(sphere: sphere)
            .frame(width: sphereSize, height: sphereSize)
        .contentShape(Rectangle())
    }
}

struct SphereLensButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.045 : 1.0)
            .brightness(configuration.isPressed ? 0.035 : 0)
            .animation(.easeInOut(duration: 0.26), value: configuration.isPressed)
    }
}

struct AtmosphericSphereLensView: View {
    let sphere: Sphere

    var body: some View {
        ZStack {
            lensCore

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.52),
                            .white.opacity(0.20),
                            .clear
                        ],
                        center: UnitPoint(x: 0.30, y: 0.22),
                        startRadius: 2,
                        endRadius: 112
                    )
                )
                .blendMode(.screen)

            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.60),
                            .white.opacity(0.16),
                            EtudesPalette.softGraphite.opacity(0.16)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.15
                )

            Circle()
                .strokeBorder(.white.opacity(0.13), lineWidth: 7)
                .blur(radius: 5)
                .blendMode(.screen)

            mirrorVeil
            lensTitle
        }
        .clipShape(Circle())
        .overlay {
            Circle()
                .strokeBorder(.white.opacity(0.22), lineWidth: 0.7)
        }
        .overlay {
            NoiseOverlay(opacity: 0.055, dotCount: 170)
                .clipShape(Circle())
                .blendMode(.overlay)
        }
        .shadow(color: EtudesPalette.softGraphite.opacity(0.14), radius: 18, x: 0, y: 13)
        .shadow(color: .white.opacity(0.52), radius: 10, x: -5, y: -6)
    }

    @ViewBuilder
    private var lensCore: some View {
        if let imageName = sphere.imageName {
            photoLens(imageName)
        } else {
            abstractLens
        }
    }

    private func photoLens(_ imageName: String) -> some View {
        ZStack {
            BundledSphereImage(imageName: imageName)
                .scaledToFill()
                .scaleEffect(1.10)
                .blur(radius: 4)
                .saturation(0.82)
                .contrast(0.82)
                .brightness(0.04)
                .clipShape(Circle())

            LinearGradient(
                colors: [
                    .white.opacity(0.18),
                    .clear,
                    EtudesPalette.softGraphite.opacity(0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(Circle())
        }
    }

    private var abstractLens: some View {
        ZStack {
            RadialGradient(
                colors: sphere.colors.map { $0.opacity(0.46) } + [EtudesPalette.ivory.opacity(0.82)],
                center: UnitPoint(x: 0.36, y: 0.30),
                startRadius: 4,
                endRadius: 128
            )

            AngularGradient(
                colors: [
                    EtudesPalette.ivory.opacity(0.72),
                    sphere.colors.first?.opacity(0.34) ?? EtudesPalette.dustyBlue.opacity(0.34),
                    EtudesPalette.grayLilac.opacity(0.28),
                    EtudesPalette.warmMilk.opacity(0.60),
                    EtudesPalette.ivory.opacity(0.72)
                ],
                center: .center
            )
            .blur(radius: 12)
            .opacity(0.74)
        }
    }

    private var mirrorVeil: some View {
        ZStack {
            Ellipse()
                .fill(.white.opacity(0.42))
                .frame(width: 68, height: 28)
                .blur(radius: 8)
                .rotationEffect(.degrees(-28))
                .offset(x: -30, y: -34)
                .blendMode(.screen)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.34), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 122, height: 18)
                .blur(radius: 6)
                .rotationEffect(.degrees(-15))
                .offset(x: 2, y: -4)
                .blendMode(.screen)

            Ellipse()
                .stroke(.white.opacity(0.32), lineWidth: 1.2)
                .frame(width: 104, height: 64)
                .blur(radius: 2.8)
                .rotationEffect(.degrees(-28))
                .offset(x: -12, y: -10)
                .blendMode(.screen)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [.clear, EtudesPalette.softGraphite.opacity(0.24)],
                        center: UnitPoint(x: 0.68, y: 0.72),
                        startRadius: 34,
                        endRadius: 78
                    )
                )
                .blendMode(.multiply)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white.opacity(0.18), .clear],
                        center: UnitPoint(x: 0.38, y: 0.34),
                        startRadius: 0,
                        endRadius: 70
                    )
                )
                .blendMode(.screen)
        }
    }

    private var lensTitle: some View {
        Text(sphere.title)
            .font(.system(size: 13.5, weight: .semibold, design: .serif))
            .foregroundStyle(titleColor)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, 18)
            .shadow(color: titleShadowColor, radius: 2.2, x: 0, y: 1)
            .blendMode(sphere.imageName == nil ? .multiply : .normal)
            .mask {
                RadialGradient(
                    colors: [.black, .black.opacity(0.95), .black.opacity(0.74), .clear],
                    center: .center,
                    startRadius: 4,
                    endRadius: 76
                )
            }
    }

    private var titleColor: Color {
        if usesLightTitle {
            return Color.white.opacity(0.82)
        }
        return EtudesPalette.ink.opacity(sphere.imageName == nil ? 0.76 : 0.84)
    }

    private var titleShadowColor: Color {
        usesLightTitle ? .black.opacity(0.22) : .white.opacity(0.42)
    }

    private var usesLightTitle: Bool {
        guard let firstColor = sphere.colors.first else { return false }
        return firstColor.perceivedLuminance < 0.42
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }

    var perceivedLuminance: Double {
        let resolved = UIColor(self).resolvedColor(with: UITraitCollection.current)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        resolved.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return 0.299 * Double(red) + 0.587 * Double(green) + 0.114 * Double(blue)
    }
}

struct BundledSphereImage: View {
    let imageName: String

    var body: some View {
        if let path = Bundle.main.path(forResource: imageName, ofType: nil, inDirectory: "photos_etudes"),
           let image = UIImage(contentsOfFile: path) {
            Image(uiImage: image)
                .resizable()
        } else {
            LinearGradient(
                colors: [
                    EtudesPalette.dustyBlue.opacity(0.62),
                    EtudesPalette.grayLilac.opacity(0.48),
                    EtudesPalette.ivory.opacity(0.72)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct NoiseOverlay: View {
    let opacity: Double
    let dotCount: Int

    var body: some View {
        Canvas { context, size in
            context.opacity = opacity
            for index in 0..<dotCount {
                let xSeed = pseudoRandom(index * 17 + 11)
                let ySeed = pseudoRandom(index * 29 + 7)
                let radiusSeed = pseudoRandom(index * 43 + 3)
                let rect = CGRect(
                    x: xSeed * size.width,
                    y: ySeed * size.height,
                    width: 0.35 + radiusSeed * 0.9,
                    height: 0.35 + radiusSeed * 0.9
                )
                context.fill(Path(ellipseIn: rect), with: .color(.black))
            }
        }
        .allowsHitTesting(false)
    }

    private func pseudoRandom(_ seed: Int) -> CGFloat {
        let value = sin(Double(seed) * 12.9898) * 43758.5453
        return CGFloat(value - floor(value))
    }
}

struct ExpandedSphereOverlay: View {
    let spheres: [Sphere]
    let selectedIndex: Int
    let onSelect: (Int) -> Void
    let onDismiss: () -> Void

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.opacity(0.18)
                    .ignoresSafeArea()
                    .onTapGesture {
                        onDismiss()
                    }

                ExpandedSphereCard(sphere: spheres[selectedIndex])
                    .frame(width: proxy.size.width - 42, height: proxy.size.height - 112)
                    .offset(x: dragOffset)
                    .gesture(
                        DragGesture(minimumDistance: 24)
                            .onChanged { value in
                                dragOffset = value.translation.width
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 72
                                if value.translation.width < -threshold, selectedIndex < spheres.count - 1 {
                                    onSelect(selectedIndex + 1)
                                } else if value.translation.width > threshold, selectedIndex > 0 {
                                    onSelect(selectedIndex - 1)
                                }
                                withAnimation(.easeInOut(duration: 0.32)) {
                                    dragOffset = 0
                                }
                            }
                    )
                    .onTapGesture {}
                    .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            }
        }
    }
}

struct ExpandedSphereCard: View {
    let sphere: Sphere

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                imageHeader

                VStack(alignment: .leading, spacing: 18) {
                    Text(sphere.title)
                        .font(.title.weight(.semibold))
                        .foregroundStyle(EtudesPalette.ink)

                    Text(sphere.caption)
                        .font(.body)
                        .lineSpacing(3)
                        .foregroundStyle(EtudesPalette.ink)

                    metadataGrid
                }
                .padding(22)
            }
        }
        .scrollIndicators(.hidden)
        .background(EtudesPalette.panel)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .shadow(color: .black.opacity(0.20), radius: 30, y: 18)
    }

    private var imageHeader: some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                if let imageName = sphere.imageName {
                    BundledSphereImage(imageName: imageName)
                        .scaledToFill()
                } else {
                    LinearGradient(
                        colors: sphere.colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
            .frame(height: 260)
            .clipped()

            LinearGradient(
                colors: [.clear, EtudesPalette.panel.opacity(0.98)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
        }
    }

    private var metadataGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            SphereField(label: "Ощущение", value: sphere.feeling)
            SphereField(label: "Предметы", value: sphere.objects)
            SphereField(label: "Дата", value: sphere.date)
            SphereField(label: "Время", value: sphere.time)
            SphereField(label: "Место", value: sphere.place)
            SphereField(label: "Запахи", value: sphere.smells)
            SphereField(label: "Песня", value: sphere.song)
        }
    }
}

struct SphereField: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(EtudesPalette.muted)

            Text(value)
                .font(.callout)
                .foregroundStyle(EtudesPalette.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(EtudesPalette.background, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

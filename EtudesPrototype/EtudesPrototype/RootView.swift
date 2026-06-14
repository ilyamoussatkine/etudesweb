import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            SphereMapView()
                .tabItem {
                    Label("Карта", systemImage: "map")
                }

            ProustPracticeView()
                .tabItem {
                    Label("Практики", systemImage: "sparkles")
                }

            PlaceholderSectionView(
                title: "Профиль",
                subtitle: "Здесь позже появятся настройки приватности, экспорт и личные параметры карты.",
                symbol: "person.crop.circle"
            )
            .tabItem {
                Label("Профиль", systemImage: "person.crop.circle")
            }
        }
        .tint(.primary)
    }
}

struct PlaceholderSectionView: View {
    let title: String
    let subtitle: String
    let symbol: String

    var body: some View {
        ZStack {
            EtudesPalette.background.ignoresSafeArea()

            VStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.system(size: 42, weight: .light))
                    .foregroundStyle(.secondary)

                Text(title)
                    .font(.title2.weight(.semibold))

                Text(subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
            }
            .padding(24)
        }
    }
}

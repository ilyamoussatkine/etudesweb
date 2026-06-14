import SwiftUI

struct CreateSphereView: View {
    @Environment(\.dismiss) private var dismiss

    var onCreate: (Sphere) -> Void

    @State private var title = ""
    @State private var caption = ""
    @State private var feeling = ""
    @State private var objects = ""
    @State private var date = ""
    @State private var time = ""
    @State private var place = ""
    @State private var smells = ""
    @State private var song = ""

    var body: some View {
        NavigationStack {
            ZStack {
                EtudesPalette.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        photoPlaceholder

                        field("Название", text: $title)
                        field("Подпись", text: $caption, axis: .vertical)
                        field("Ощущение", text: $feeling)
                        field("Предметы", text: $objects)

                        HStack(spacing: 12) {
                            field("Дата", text: $date)
                            field("Время", text: $time)
                        }

                        field("Место", text: $place)
                        field("Запахи", text: $smells)
                        field("Название песни", text: $song)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Новая сфера")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Создать") {
                        createSphere()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private var photoPlaceholder: some View {
        Button {
            // Photo picking is intentionally left as a later prototype step.
        } label: {
            VStack(spacing: 10) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 34, weight: .light))
                Text("Добавить фото")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 156)
            .foregroundStyle(EtudesPalette.muted)
            .background(EtudesPalette.panel, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(EtudesPalette.line, style: StrokeStyle(lineWidth: 1, dash: [7, 7]))
            }
        }
        .buttonStyle(.plain)
    }

    private func field(_ label: String, text: Binding<String>, axis: Axis = .horizontal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(EtudesPalette.muted)

            TextField(label, text: text, axis: axis)
                .textFieldStyle(.plain)
                .lineLimit(axis == .vertical ? 6 : 1)
                .padding(14)
                .background(EtudesPalette.panel, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(EtudesPalette.line.opacity(0.8), lineWidth: 1)
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func createSphere() {
        let nextIndex = Int.random(in: 4...16)
        let newSphere = Sphere(
            title: title,
            caption: caption.isEmpty ? "Новая сфера без подписи." : caption,
            feeling: feeling.isEmpty ? "не указано" : feeling,
            objects: objects.isEmpty ? "не указано" : objects,
            date: date.isEmpty ? "не указано" : date,
            time: time.isEmpty ? "не указано" : time,
            place: place.isEmpty ? "не указано" : place,
            smells: smells.isEmpty ? "не указано" : smells,
            song: song.isEmpty ? "не указано" : song,
            colors: [.teal, .indigo, .pink],
            gridIndex: nextIndex,
            offsetSeed: CGSize(
                width: CGFloat.random(in: -28...28),
                height: CGFloat.random(in: -24...24)
            ),
            imageName: nil
        )
        onCreate(newSphere)
        dismiss()
    }
}

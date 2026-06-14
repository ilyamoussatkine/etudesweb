import SwiftUI

struct Sphere: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var caption: String
    var feeling: String
    var objects: String
    var date: String
    var time: String
    var place: String
    var smells: String
    var song: String
    var colors: [Color]
    var gridIndex: Int
    var offsetSeed: CGSize
    var imageName: String?
}

extension Sphere {
    static let samples: [Sphere] = [
        Sphere(
            title: "Тёплый экран в метро",
            caption: "Поздний вечер, когда стекло вагона становится темным зеркалом, а уведомления похожи на маленькие окна чужих комнат.",
            feeling: "усталость, мягкость, возвращение",
            objects: "телефон, поручень, отражение, наушники",
            date: "май 2026",
            time: "22:40",
            place: "синяя ветка",
            smells: "металл, дождь на куртках",
            song: "Clairo — Bags",
            colors: [.indigo, .cyan, .black],
            gridIndex: 0,
            offsetSeed: CGSize(width: -26, height: 18),
            imageName: "33e4f4ea751853ffd510c111cc8475af.jpg"
        ),
        Sphere(
            title: "2016 в папке загрузок",
            caption: "Скриншоты, сохранённые без причины: розовый интерфейс, низкое разрешение, мемы как личные закладки эпохи.",
            feeling: "ностальгия, неловкость, смешное узнавание",
            objects: "скриншот, старый ноутбук, папка downloads",
            date: "2015-2017",
            time: "после школы",
            place: "комната",
            smells: "пыль, сладкий чай",
            song: "The 1975 — Somebody Else",
            colors: [.pink, .purple, .orange],
            gridIndex: 1,
            offsetSeed: CGSize(width: 32, height: -20),
            imageName: "3607d000e1432da84b0f8b9abe052d93.jpg"
        ),
        Sphere(
            title: "Двор после дождя",
            caption: "Мокрый асфальт собирает вывески, окна и редкие шаги в одну темную карту.",
            feeling: "пауза, чистота, ожидание",
            objects: "лужи, окна, деревья, подъезд",
            date: "июнь 2026",
            time: "19:15",
            place: "внутренний двор",
            smells: "асфальт, листья",
            song: "Kedr Livanskiy — Ariadna",
            colors: [.green, .mint, .gray],
            gridIndex: 2,
            offsetSeed: CGSize(width: -18, height: -14),
            imageName: nil
        ),
        Sphere(
            title: "Пустой лендинг выставки",
            caption: "До того как посетители добавят свои фрагменты, доска уже похожа на ожидание коллективной памяти.",
            feeling: "предвкушение, сборка, публичность",
            objects: "qr-код, экран, белая стена, подпись",
            date: "май 2026",
            time: "день",
            place: "культурная институция",
            smells: "краска, бумага",
            song: "Oneohtrix Point Never — Chrome Country",
            colors: [.yellow, .teal, .white],
            gridIndex: 3,
            offsetSeed: CGSize(width: 24, height: 22),
            imageName: "e1ca0ea63ba17b44a135dd1cba3ef563-2.jpg"
        ),
        Sphere(
            title: "Как показывали Италию",
            caption: "Как показывали Италию в советских фильмах. Солнечная улица становится не столько местом, сколько собранным образом юга: фасады, тени, камень, медленное движение и почти открытка-воспоминание.",
            feeling: "ностальгия, кино, полдень",
            objects: "итальянская улица, фасады, тени, подпись, карточка",
            date: "июнь 2026",
            time: "полдень",
            place: "Италия как экранный образ",
            smells: "камень, пыль, горячий воздух",
            song: "Nino Rota — Amarcord",
            colors: [.yellow, .green, .white],
            gridIndex: 4,
            offsetSeed: CGSize(width: -22, height: 12),
            imageName: "katya_italy_soviet_films.png"
        )
    ]
}

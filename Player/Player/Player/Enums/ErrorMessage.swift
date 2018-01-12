import Foundation

enum ErrorTitles: String {
    case error = "Ошибка"
    case sorry = "Извините"
}

enum ErrorMessageBody: String {
    case downloadError = "В процессе скачивания произошла ошибка"
    case playError = "Не удается воспроизвести песню"
    case noInfo = "Нет информации о песне"
    case saveError = "Не удалось сохранить песню"
}

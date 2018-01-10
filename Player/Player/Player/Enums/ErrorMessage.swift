//
//  ErrorMessage.swift
//  Player
//
//  Created by Sitora on 11.01.18.
//  Copyright © 2018 Sitora. All rights reserved.
//

import Foundation
enum ErrorTitles: String {
    case error = "Ошибка"
    case sorry = "Извините"
}

enum ErrorMessageBody: String {
    case downloadError = "В процессе скачивания произошла ошибка"
    case playError = "Не удается воспроизвести песню"
}

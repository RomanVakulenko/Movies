//
//  GlobalConstants.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit

enum GlobalConstants {
    static let error = "Ошибка"
    static let ok = "Ok"

    static let appTitle = "KinoPoisk"
    static let loginPlaceholder = "Логин"
    static let passwordPlaceholder = "Пароль"
    static let enterButton = "Войти"
    static let alertWrongPassword = "Некорректный пароль"

    static let searchBarPlaceholder = "Поиск по название/страна/жанр"

    static let filmDescriptionTtile = "Описание"
    static let stills = "Кадры"

    static let borderWidth: CGFloat = UIHelper.Margins.small1px
    static let cornerRadius: CGFloat = UIHelper.Margins.medium8px
    static let fieldFontSize16px: CGFloat = UIHelper.Margins.medium16px
    static let fieldsAndButtonHeight24px: CGFloat = UIHelper.Margins.large24px

}

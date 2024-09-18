//
//  GlobalConstants.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit

enum GlobalConstants {
    static let error = "Ошибка"
    static let attention = "Внимание"
    static let ok = "Ok"

    static let appTitle = "KinoPoisk"
    static let loginPlaceholder = "Логин"
    static let passwordPlaceholder = "Пароль"
    static let enterButton = "Войти"
    static let someFieldIsEmpty = "Логин или пароль пустой"
    static let invalidPassword = "Некорректный пароль"

    static let fetchingFilms =  "Fetchnig films"

    static let searchBarPlaceholder = "Поиск по название/страна/жанр"

    static let filmDescriptionTtile = "Описание"
    static let stills = "Кадры"

    static let spinnerOffset: CGFloat = 72
    static let borderWidth: CGFloat = UIHelper.Margins.small1px
    static let cornerRadius: CGFloat = UIHelper.Margins.medium8px
    static let fieldFontSize16px: CGFloat = UIHelper.Margins.medium16px
    static let fieldsAndButtonHeight48px: CGFloat = UIHelper.Margins.huge48px

}

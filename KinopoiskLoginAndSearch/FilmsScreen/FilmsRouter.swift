//
//  FilmsRouter.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit
import SnapKit

protocol FilmsRoutingLogic {
    func routeBackToLoginScreen()
    func routeToOneFilmDetails()
    func openPiker()
}


protocol FilmsDelegate: AnyObject {
    func doLogOut()
}

protocol FilmsDataPassing {
    var dataStore: FilmsDataStore? { get }
}

protocol DatePickerRouterProtocol {
    func presentYearPicker(from view: UIViewController, completion: @escaping (Int) -> Void)
}

@available(iOS 13.4, *)
final class FilmsRouter: FilmsRoutingLogic, FilmsDataPassing, DatePickerRouterProtocol {

    enum Constants {
        static let offset50: CGFloat = 50
        static let heightOfPicker: CGFloat = 200
    }


    weak var viewController: FilmsController?
    weak var dataStore: FilmsDataStore?


    // MARK: - Public methods

    func routeBackToLoginScreen() {
        if let delegate = viewController?.delegate {
            delegate.doLogOut()
        }

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.navigationController?.popViewController(animated: false)
        }

    }

    func routeToOneFilmDetails() {
        if let idOfSelectedFilm = dataStore?.idOfSelectedFilm {
            let oneFilmViewController = OneFilmDetailsBuilder().getControllerFor(filmId: idOfSelectedFilm)

            DispatchQueue.main.async { [weak self] in
                self?.viewController?.navigationController?.pushViewController(oneFilmViewController, animated: true)
            }
        }
    }

    func openPiker() {

    }

    func presentYearPicker(from view: UIViewController, completion: @escaping (Int) -> Void) {
        let alertController = UIAlertController(title: "Выберите год", message: nil, preferredStyle: .alert)

        // Создаем контейнер для UIDatePicker
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = GlobalConstants.cornerRadius
        containerView.layer.masksToBounds = true

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.backgroundColor = .white // Устанавливаем белый фон для UIDatePicker
        datePicker.preferredDatePickerStyle = .wheels

        let currentYear = Calendar.current.component(.year, from: Date())
        let minDate = Calendar.current.date(from: DateComponents(year: 1950))
        let maxDate = Calendar.current.date(from: DateComponents(year: currentYear))

        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate

        containerView.addSubview(datePicker)

        datePicker.snp.makeConstraints {
            $0.edges.equalTo(containerView) // Заполняем весь контейнер
        }

        alertController.view.addSubview(containerView)

        containerView.snp.makeConstraints {
            $0.leading.equalTo(alertController.view.snp.leading)
            $0.trailing.equalTo(alertController.view.snp.trailing)
            $0.top.equalTo(alertController.view.snp.top).offset(Constants.offset50)
            $0.height.equalTo(Constants.heightOfPicker)
            $0.bottom.equalTo(alertController.view.snp.bottom).offset(-Constants.offset50)
        }

        alertController.addAction(UIAlertAction(title: GlobalConstants.ok, style: .default, handler: { _ in
            let selectedYear = Calendar.current.component(.year, from: datePicker.date)
            completion(selectedYear)
        }))

        view.present(alertController, animated: true, completion: nil)
    }
}

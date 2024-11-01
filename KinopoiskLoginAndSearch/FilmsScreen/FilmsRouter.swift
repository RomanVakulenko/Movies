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

@available(iOS 13.0, *)
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


    func presentYearPicker(from view: UIViewController, completion: @escaping (Int) -> Void) {
        let alertController = UIAlertController(title: "Выберите год", message: nil, preferredStyle: .alert)
        
        // Создаем контейнер для UIPickerView
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = GlobalConstants.cornerRadius
        containerView.layer.masksToBounds = true
        
        let pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.dataSource = view as? FilmsController
        pickerView.delegate = view as? FilmsController

        containerView.addSubview(pickerView)
        
        pickerView.snp.makeConstraints {
            $0.edges.equalTo(containerView)
        }
        
        alertController.view.addSubview(containerView)
        
        containerView.snp.makeConstraints {
            $0.leading.equalTo(alertController.view.snp.leading)
            $0.trailing.equalTo(alertController.view.snp.trailing)
            $0.top.equalTo(alertController.view.snp.top).offset(Constants.offset50)
            $0.height.equalTo(Constants.heightOfPicker)
            $0.bottom.equalTo(alertController.view.snp.bottom).offset(-Constants.offset50)
        }
        
        // Диапазон годов
        let yearsForPicking = Array(GlobalConstants.defaultSelectedYear...GlobalConstants.currentYear)
        
        // выбранный ранее год
        if let yearForFilter = dataStore?.yearForFilter {
            if let index = yearsForPicking.firstIndex(of: yearForFilter) {
                pickerView.selectRow(index, inComponent: 0, animated: false)
            }
        }

        alertController.addAction(UIAlertAction(title: GlobalConstants.ok, style: .default, handler: { _ in
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            let selectedYear = yearsForPicking[selectedRow]
            completion(selectedYear)
        }))
        
        view.present(alertController, animated: true, completion: nil)
    }
}

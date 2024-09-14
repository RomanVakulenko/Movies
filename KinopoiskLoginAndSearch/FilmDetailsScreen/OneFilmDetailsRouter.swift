//
//  OneEmailDetailsRouter.swift
//  SGTS
//
//  Created by Roman Vakulenko on 22.04.2024.
//

import Foundation
import UIKit
import SnapKit

protocol OneEmailDetailsRoutingLogic {
    func routeToSaveDialog()
    func routeToOpenImage()
    func routeToNewEmailCreate()
    func routeToOpenData()
    func routeToMailStartScreen()
}

protocol OneEmailDetailsDataPassing {
    var dataStore: OneEmailDetailsDataStore? { get }
}


final class OneEmailDetailsRouter: OneEmailDetailsRoutingLogic, OneEmailDetailsDataPassing, FileShareable {

    weak var viewController: OneEmailDetailsController?
    weak var dataStore: OneEmailDetailsDataStore?

    // MARK: - Public methods

    func routeToSaveDialog() {
        guard let store = dataStore,
              let fileDataToSaveAtDownloadIcon = store.fileDataToSaveAtDownloadIcon,
              let vc = viewController else { return }
        
        vc.shareFile(data: fileDataToSaveAtDownloadIcon,
                     filenameWithExt: store.fileNameWithExt,
                     from: vc)
    }

    func routeToOpenImage() {
        if let image = dataStore?.imageToOpen,
           let name = dataStore?.fileNameWithExt,
           let uidl = dataStore?.incomingEmailUIDL,
           let size = dataStore?.fileSize {
            let imageViewController = ImageFullScreenBuilder().getController(
                with: image,
                fileNameWithExt: name,
                mailUidl: uidl,
                size: size)

            DispatchQueue.main.async { [weak self] in
                self?.viewController?.navigationController?.pushViewController(
                    imageViewController,
                    animated: true)
            }
        }
    }

    func routeToMailStartScreen() {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.navigationController?.popViewController(animated: false)
        }
    }

    func routeToNewEmailCreate() {
        if let emailtype = dataStore?.emailType {
            let controller = NewEmailCreateBuilder().getControllerWith(
                messageModel: dataStore?.oneEmailMessage,
                pickedEmailAddresses: nil,
                emailType: emailtype)

            DispatchQueue.main.async { [weak self] in
                self?.viewController?.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }

    func routeToOpenData() {
        guard let store = dataStore,
              let fileData = store.fileData,
              let vc = viewController else { return }
        
        OpenFileManager.shared.openData(fileData,
                                        withFilename: store.fileNameWithExt,
                                        currentViewController: vc)
    }

    // MARK: - Private methods

    private func openData(_ data: Data, withFilename filename: String) {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(filename)
        
        do {
            // Запись данных во временный файл
            try data.write(to: fileURL)
            
            // Проверка, что файл существует
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                print("File does not exist at path: \(fileURL.path)")
                return
            }
            
            // Проверка, что можно открыть URL
            guard UIApplication.shared.canOpenURL(fileURL) else {
                print("Cannot open file at path: \(fileURL.path)")
                return
            }
            
            // Открытие файла с использованием UIApplication.shared
            UIApplication.shared.open(fileURL, options: [:]) { success in
                if success {
                    print("File opened successfully.")
                } else {
                    print("Failed to open file.")
                }
            }
        } catch {
            print("Failed to write data to temporary file: \(error)")
        }
    }
    
}

//
//  DataMapper.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation

protocol DataMapperProtocol {
    func decode<T: Decodable> (from data: Data,
                               toStruct: T.Type,
                               completion: @escaping (Result<T, DataMapperError>) -> Void)
}


// MARK: - DataMapper
class DataMapper: DataMapperProtocol {
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()

    private let concurrentQueque = DispatchQueue(label: "concurrentForParsing",
                                                 qos: .userInteractive,
                                                 attributes: .concurrent)


    func decode<T>(from data: Data,
                   toStruct: T.Type,
                   completion: @escaping (Result<T, DataMapperError>) -> Void) where T : Decodable {
        concurrentQueque.async {
           do {
                let parsedInfo = try self.decoder.decode(toStruct, from: data)
                DispatchQueue.main.async {
                    completion(.success(parsedInfo))
                }
            } catch {
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Key '\(key)' not found:", context.debugDescription)
                    case .typeMismatch(let type, let context):
                        print("Type '\(type)' mismatch:", context.debugDescription)
                    case .valueNotFound(let value, let context):
                        print("Value '\(value)' not found:", context.debugDescription)
                    case .dataCorrupted(let context):
                        print("Data corrupted:", context.debugDescription)
                    default:
                        print("Decoding error:", error.localizedDescription)
                    }
                } else {
                    print("Unexpected error:", error)
                }

                DispatchQueue.main.async {
                    completion(.failure(.failAtMapping))
                }
            }
        }
    }
}


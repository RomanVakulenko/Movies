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
                let parsedTasks = try self.decoder.decode(toStruct, from: data)
                DispatchQueue.main.async {
                    completion(.success(parsedTasks))
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(.failure(.failAtMapping))
                }
            }
        }
    }
}


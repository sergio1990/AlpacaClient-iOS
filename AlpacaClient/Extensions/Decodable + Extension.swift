//
//  Decodable + Extension.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 16.02.2023.
//

import Foundation

extension Decodable {
    static func decode(jsonData: Data) -> Self? {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(Self.self, from: jsonData)
        } catch {
            print("\(String(describing: Self.self)).decode failed with the error: \(error)")
            return nil
        }
    }
}

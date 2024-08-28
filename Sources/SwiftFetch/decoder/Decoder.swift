//
//  Decoder.swift
//
//
//  Created by yuz_chen on 8/27/24.
//

import Foundation

class Decoder {
    static func structDecode<T: Codable>(data: Data?) throws -> T? {
        guard let data = data else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw InvalidDataError()
        }
    }
    
}

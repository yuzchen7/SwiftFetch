//
//  File.swift
//  
//
//  Created by yuz_chen on 8/27/24.
//

import Foundation

struct Source: Codable {
    typealias ReturnType = Self
    
    var message: String
    
    var description: String {
        get {
            return "message: \(message)"
        }
    }
    
    static func initErrorDefault() -> Source {
        return Source(message: "error")
    }
}

//
//  File.swift
//  
//
//  Created by yuz_chen on 8/27/24.
//

import Foundation

struct Respond: Codable {
    typealias ReturnType = Self
    
    var route: String
    var ret: Source
    
    var description: String {
        get {
            return "Respond(message: \(route), ret: \(ret.description))"
        }
    }
    
    static func initErrorDefault() -> Respond {
        return Respond(route: "error", ret: Source.initErrorDefault())
    }
}

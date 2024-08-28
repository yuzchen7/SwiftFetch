//
//  File.swift
//  
//
//  Created by yuz_chen on 8/27/24.
//

import Foundation

struct InvalidDataError: Error {
    var message: String = "Error -> Data invalidation"
    var localizedDescription: String {
        return message
    }
}

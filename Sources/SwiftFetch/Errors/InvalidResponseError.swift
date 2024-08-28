//
//  File.swift
//  
//
//  Created by yuz_chen on 8/27/24.
//

import Foundation

struct InvalidResponseError: Error {
    var statusCode: Int
    var message: String {
        return "Error -> Response invalidation with Http Status Code: \(statusCode)"
    }
    var localizedDescription: String {
        return message
    }
}

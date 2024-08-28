//
//  File.swift
//  
//
//  Created by yuz_chen on 8/27/24.
//

import Foundation

struct InvalidHttpResponseError: Error {
    var message: String = "Error -> Response is not the Http Response Object"
    var localizedDescription: String {
        return message
    }
}

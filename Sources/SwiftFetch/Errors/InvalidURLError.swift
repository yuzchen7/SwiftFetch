//
//  File.swift
//  
//
//  Created by yuz_chen on 8/27/24.
//

import Foundation

struct InvalidURLError: Error {
    var message: String = "Error -> URL invalidation"
    var localizedDescription: String {
        return message
    }
}

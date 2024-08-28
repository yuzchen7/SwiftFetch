//
//  SFactory.swift
//  
//
//  Created by yuz_chen on 8/27/24.
//

import Foundation

final class SFactory {
    private static var sFetch: SFetch = SFetch()
    
    private init() {}
    
    static func getSFetch(_ config: URLSession? = nil) -> SFetch {
        return SFactory.sFetch
    }
    
    static func setSFetch(_ config: URLSession) {
        SFactory.sFetch.setHttpSession(config: config)
    }
    
    static func resetSwiftxios() {
        setSFetch(URLSession.shared)
    }
}

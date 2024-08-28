//
//  SResult.swift
//  
//
//  Created by yuz_chen on 8/27/24.
//

import Foundation

struct SResult<T> {
    public var statusCode: Int?
    public var data: T?
    public var error: Error?
    
    var description: String {
        get {
            return """
            {
                statusCode: \(String(describing: statusCode)),
                data: {
                    \(String(describing: data))
                },
                error:{
                    \(String(describing: error?.localizedDescription))
                }
            }
            """
        }
    }
    
    /// Copy function
    /// - Description: copy current SResult object
    /// - Returns: SResult object
    public func copy() -> SResult<T> {
        return SResult<T>(
            statusCode: self.statusCode,
            data: self.data,
            error: self.error
        )
    }
    
    /// next preprocess function
    /// - Description preprocess data T, only if T is an not nil value and error is nil, otherwise will return current object
    /// - Parameters:
    ///     - next: closure, preprocess of data, must have some return value
    /// - Returns: SResult object
    public func next<U>(_ preprocess: ((SResult<T>) throws -> U?)? = nil) -> SResult<U> {
        if self.error != nil {
            return self.copy() as! SResult<U>
        }
        if let preprocess = preprocess {
            do {
                let processedData: U? = try preprocess(self)
                return SResult<U>(statusCode: self.statusCode, data: processedData ?? nil, error: self.error)
            } catch {
                return SResult<U>(statusCode: self.statusCode, data: nil, error: error)
            }
        }
        return self.copy() as! SResult<U>
    }
    
    /// next preprocess function
    /// - Description preprocess data T, only if T is an not nil value and error is nil, otherwise will return current object
    /// - Parameters:
    ///     - next: closure, preprocess of data, must have some return value
    /// - Returns: SResult object
    public func next<U>(_ preprocess: ((T, SResult<T>) throws -> U?)? = nil) -> SResult<U> {
        if self.error != nil {
            return self.copy() as! SResult<U>
        }
        if let preprocess = preprocess, let dataV = self.data {
            do {
                let processedData: U? = try preprocess(dataV, self)
                return SResult<U>(statusCode: self.statusCode, data: processedData ?? nil, error: self.error)
            } catch {
                return SResult<U>(statusCode: self.statusCode, data: nil, error: error)
            }
        }
        return self.copy() as! SResult<U>
    }
    
    /// next preprocess function
    /// - Description preprocess data T, only if T is an not nil value and error is nil, otherwise will return current object
    /// - Parameters:
    ///     - next: closure, preprocess of data, must have some return value
    /// - Returns: SResult object
    public func next<U>(_ preprocess: ((T) throws -> U?)? = nil) -> SResult<U> {
        if self.error != nil {
            return self.copy() as! SResult<U>
        }
        if let preprocess = preprocess, let dataV = self.data {
            do {
                let processedData: U? = try preprocess(dataV)
                return SResult<U>(statusCode: self.statusCode, data: processedData ?? nil, error: self.error)
            } catch {
                return SResult<U>(statusCode: self.statusCode, data: nil, error: error)
            }
        }
        return self.copy() as! SResult<U>
    }
    
    /// catch error exception
    /// - Description: handling error
    /// - Parameters:
    ///     - handler: closure, preprocess error
    /// - Returns: new SResult object
    public func `catch`(_ handler: (Error) throws -> Void) throws -> SResult<T> {
        if let error = self.error {
            do {
                try handler(error)
            } catch {
                throw error
            }
        }
        return self
    }
    
    /// catch error exception
    /// - Description: handling error
    /// - Parameters:
    ///     - handler: closure, preprocess error
    /// - Returns: new SResult object
    public func `catch`(_ handler: (Int?, Error) throws -> Void) throws -> SResult<T> {
        if let error = self.error {
            do {
                try handler(self.statusCode, error)
            } catch {
                throw error
            }
        }
        return self
    }
}


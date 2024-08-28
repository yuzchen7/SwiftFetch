//
//  SFetch.swift
//  
//
//  Created by yuz_chen on 8/27/24.
//

import Foundation
import os

final class SFetch {
    
    private var httpSession: URLSession
    private var taskHandlder: URLSessionDataTask?
    
    init() {
        self.httpSession = URLSession.shared
    }
    
    /// customize the URLSession for fetching
    /// - Parameters
    ///     - config, URLSession object to be set
    public func setHttpSession(config: URLSession) {
        self.httpSession = config
    }
    
    private enum RequestMethod: String {
        case POST = "POST"
        case GET = "GET"
        case PUT = "PUT"
        case DELETE = "DELETE"
        case PATCH = "PATCH"
    }
    
    private func makeRequestObj(
        _ url: URL,
        _ method: RequestMethod,
        _ body: [String : Any]? = nil,
        _ config: [String : String]? = nil
    ) -> URLRequest {
        var request: URLRequest = URLRequest(url: url)
        
        // request object with post reuqest method
        request.httpMethod = method.rawValue
        
        // try to set body object
        if let body = body {
            let bodyData = try? JSONSerialization.data(withJSONObject: body)
            request.httpBody = bodyData
        }
        
        //try to set additional config that invoker require
        if let config = config {
            for (key, value) in config {
                request.setValue(key, forHTTPHeaderField: value)
            }
        }
        
        return request
    }
    
    /// core function: made the request of url
    /// - Parameters:
    ///     - request: URLRequest object with request information
    /// - Throws: error, any of error
    /// - Throws: InvalidHttpResponseError, if response is not a HTTPURLResponse object
    /// - Throws: InvalidDataError, if data is nil
    /// - Returns: (Data, HTTPURLResponse)
    /// - Example:
    ///     ```swift
    ///     let (data, response): (Data, HTTPURLResponse) = try await makeFetch(request: request)
    ///     ```
    private func makeFetch(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            self.taskHandlder = self.httpSession.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard
                    let response = response as? HTTPURLResponse
                else {
                    continuation.resume(throwing: InvalidHttpResponseError())
                    return
                }
                
                if let data = data {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: InvalidDataError())
                    return
                }
            }
            self.taskHandlder?.resume()
        }
    }
    
    /// function to cancel current request task
    /// - Parameters:
    ///     - time: DispatchTime object
    ///     - preprocess: closure, execute before cancel the http request, defualt in nil
    /// - Returns: Void
    /// - Example:
    ///     ```swift
    ///     swiftxios.cancelTask(time: .now() + 5) {
    ///         print("request cancel: after 5 second")
    ///     }
    ///     ```
    public func cancelTask(time: DispatchTime = .now(), _ preprocess: (() -> Void)? = nil) -> Void {
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            if let preprocess = preprocess {
                preprocess()
            }
            self.taskHandlder?.cancel()
        })
    }
    
    /// function to check input, set fetch and fetch
    /// - Parameters:
    ///     - urlEndpoint: String url to further request
    ///     - getURLRequest: Closure, expecting using makeRequestObj function to return a URLRequest object
    /// - Returns: SResult object
    /// - Throws: There is 4 type of exception will the throw,
    ///           InvalidURLError, InvalidHTTPResponseError, InvalidDataError, InvalidResponseError
    /// - Example:
    ///     ```swift
    ///     try await fetch(urlEndpoint) { url in makeRequestObj(url, RequestMethod.GET, nil, config) }
    ///    ```
    private func fetch<T: Codable>(
        _ urlEndpoint: String,
        _ getURLRequest: (URL) -> URLRequest
    ) async throws-> SResult<T> {
        do {
            guard
                let url: URL = URL(string: urlEndpoint)
            else {
                throw InvalidURLError()
            };
            
            let request: URLRequest = getURLRequest(url)
            
            let (data, response): (Data, HTTPURLResponse) = try await makeFetch(request: request)
            
            guard
                response.statusCode ~= 200
            else {
                throw InvalidResponseError(statusCode: response.statusCode)
            }
            
            let retData: T? = try Decoder.structDecode(data: data)
            
            return SResult(statusCode: response.statusCode, data: retData, error: nil)
        } catch {
            
            if let error = error as? InvalidResponseError {
                return SResult(statusCode: error.statusCode, data: nil, error: error)
            }
            
            return SResult(statusCode: nil, data: nil, error: error)
        }
    }
    
    /// get method to fetch a get request
    /// - Parameters:
    ///     - url: String url to further request
    ///     - config: Adddtion header config that need to customize
    /// - Throws: There is 4 type of exception will the throw,
    ///           InvalidURLError, InvalidHTTPResponseError, InvalidDataError, InvalidResponseError
    /// - Returns: SResult<T>(Optional(statusCode), Optional(T), Optional(Error))
    /// - Description: SwiftFetch to fetch the given endpoint ulr make a get request, then return the result data object
    /// - Example:
    ///     ```swift
    ///     try await swiftxios.get(
    ///        "http://localhost:8080/api/users/",
    ///        [
    ///            "application/json" : "Content-Type"
    ///        ]
    ///     )
    ///    ```
    public func get<T: Codable>(
        _ urlEndpoint: String,
        _ config: [String : String]? = nil
    ) async throws -> SResult<T> {
        return try await fetch(urlEndpoint) { url in
            makeRequestObj(url, RequestMethod.GET, nil, config)
        }
    }
    
    /// post method to fetch a post request
    /// - Parameters:
    ///     - url: String url to further request
    ///     - body : Dictionary for store the body data
    ///     - config: adddtion header config that need to customize
    /// - Throws: There is 4 type of exception will the throw,
    ///           invalidURL, invalidResponse, invalidData, invalidObjectConvert
    /// - Returns: SResult<T>(Optional(statusCode), Optional(T), Optional(Error))
    /// - Description: SwiftFetch to fetch the given endpoint ulr make a post request, then return the result data object
    /// - Example:
    ///     ```swift
    ///     try await swiftxios.post(
    ///        "http://localhost:8080/auth/signup",
    ///        [
    ///            "username" : username,
    ///            "password" : password,
    ///            "first_name": fname,
    ///            "last_name": lname,
    ///            "middle_name": mname
    ///        ],
    ///        [
    ///            "application/json" : "Content-Type"
    ///        ]
    ///     )
    ///    ```
    func post<T: Codable>(
        _ urlEndpoint: String,
        _ body: [String : Any]? = nil,
        _ config: [String : String]? = nil
    ) async throws -> SResult<T> {
        return try await fetch(urlEndpoint) { url in
            makeRequestObj(url, RequestMethod.POST, body, config)
        }
    }
    
    /// put method to fetch a put request
    /// - Parameters:
    ///     - url: String url to further request
    ///     - config: adddtion header config that need to customize
    /// - Throws: There is 4 type of exception will the throw,
    ///           invalidURL, invalidResponse, invalidData, invalidObjectConvert
    /// - Description: SwiftFetch to fetch the given endpoint ulr make a put request, then return the result data object
    /// - Returns: SResult<T>(Optional(statusCode), Optional(T), Optional(Error))
    /// - Example:
    ///     ```swift
    ///     try await swiftxios.get(
    ///        "http://localhost:8080/api/schedule/update",
    ///        [
    ///            "user_id" : userID
    ///            "Monday" : true,
    ///        ],
    ///        [
    ///            "application/json" : "Content-Type"
    ///        ]
    ///     )
    ///    ```
    func put<T: Codable>(
        _ urlEndpoint: String,
        _ body: [String : Any]? = nil,
        _ config: [String : String]? = nil
    ) async throws -> SResult<T> {
        return try await fetch(urlEndpoint) {url in makeRequestObj(url, RequestMethod.PUT, body, config)}
    }
    
    /// delete method to fetch a delete request
    /// - Parameters:
    ///     - url: String url to further request
    ///     - config: adddtion header config that need to customize
    /// - Throws: There is 4 type of exception will the throw,
    ///           invalidURL, invalidResponse, invalidData, invalidObjectConvert
    /// - Description: SwiftFetch to fetch the given endpoint ulr make a delete request, then return the result data object
    /// - Returns: SResult<T>(Optional(statusCode), Optional(T), Optional(Error))
    /// - Example:
    ///     ```swift
    ///     try await swiftxios.delete(
    ///        "http://localhost:8080/api/friend_request?currentUser=1&friend=5",
    ///        [
    ///            "application/json" : "Content-Type"
    ///        ]
    ///     )
    ///    ```
    func delete<T: Codable>(
        _ urlEndpoint: String,
        _ config: [String : String]? = nil
    ) async throws -> SResult<T> {
        return try await fetch(urlEndpoint) { url in
            makeRequestObj(url, RequestMethod.DELETE, nil, config)
        }
    }
    
    /// patch method to fetch a patch request
    /// - Parameters:
    ///     - url: String url to further request
    ///     - body : Dictionary for store the body data
    ///     - config: adddtion header config that need to customize
    /// - Throws: There is 4 type of exception will the throw,
    ///           invalidURL, invalidResponse, invalidData, invalidObjectConvert
    /// - Description: SwiftFetch to fetch the given endpoint ulr make a patch request, then return the result data object
    /// - Returns: SResult<T>(Optional(statusCode), Optional(T), Optional(Error))
    /// - Example:
    ///     ```swift
    ///     try await swiftxios.delete(
    ///        "http://localhost:8080/api/schedule/update",
    ///        [
    ///            "user_id" : userID
    ///            "Monday" : true,
    ///        ],
    ///        [
    ///            "application/json" : "Content-Type"
    ///        ]
    ///     )
    ///    ```
    func patch<T: Codable>(
        _ urlEndpoint: String, 
        _ body: [String : String]? = nil,
        _ config: [String : String]? = nil
    ) async throws -> SResult<T> {
        return try await fetch(urlEndpoint) { url in makeRequestObj(url, RequestMethod.PATCH, body, config) }
    }
}

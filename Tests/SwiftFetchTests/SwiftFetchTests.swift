import XCTest
@testable import SwiftFetch

final class SwiftFetchTests: XCTestCase {
    func testCancelation() throws {
        let expectation = XCTestExpectation(description: "Fetch data from API")
        Task {
            do {
                let ret: SResult<Respond> = try await sFetch.get(
                    "http://127.0.0.1:8999/test/v1/sources/getNoResponse",
                    ["application/json" : "Content-Type"]
                ).next({ (value: Respond) in
                    print(value)
                    return value
                }).catch({ (error: Error) in
                    print(error)
                })
                print("\n\nret data -> " + (ret.error?.localizedDescription ?? "no error") + "\n\n")
                
                expectation.fulfill()
            } catch {
                XCTFail("unknow error -> unexpected \(error.localizedDescription) (╯’ – ‘)╯︵")
                expectation.fulfill()
            }
        }
        
        sFetch.cancelTask(time: .now() + 5) {
            print("request cancel: after 5 second")
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testResultStruct() throws {
        let expectation = XCTestExpectation(description: "Fetch data from API")
        Task {
            do {
                let ret: Respond = try await sFetch.get(
                    "http://127.0.0.1:8999/test/v1/sources/get",
                    ["application/json" : "Content-Type"]
                ).next({ (value: Respond) in
                    print(value)
                    return value
                }).catch({ (error: Error) in
                    print(error)
                }).data!
                print("\n\nret data -> " + ret.description + "\n\n")
                
                expectation.fulfill()
            } catch {
                XCTFail("unknow error -> unexpected \(error.localizedDescription) (╯’ – ‘)╯︵")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetFetch() throws {
        let expectation = XCTestExpectation(description: "Fetch data from API")
        Task {
            do {
                let ret: SResult<Respond> = try await sFetch.get(
                    "http://127.0.0.1:8999/test/v1/sources/get",
                    ["application/json" : "Content-Type"]
                )
                print("ret data -> " + ret.description)
                if let data: Respond = ret.data, let statusCode = ret.statusCode {
                    print("status code -> \(statusCode)")
                    print("result ->\n\t \(data)")
                } else if let error = ret.error {
                    print("result ->\n\t nil")
                    print("error ->\n\t \(error.localizedDescription)")
                }
                expectation.fulfill()
            } catch {
                XCTFail("unknow error -> unexpected \(error.localizedDescription) (╯’ – ‘)╯︵")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testPatch() throws {
        let expectation = XCTestExpectation(description: "Fetch data from API")
        Task {
            do {
                let _ : SResult<Respond> = try await sFetch.patch(
                    "http://127.0.0.1:8999/test/v1/sources/patch",
                    ["application/json" : "Content-Type"]
                ).next {(value: Respond, ret) in
                    if let statusCode = ret.statusCode, statusCode == 200 {
                        print("status code -> \(statusCode)")
                        print("result ->\n\t \(value)")
                    }
                    return value
                }.catch { err in
                    throw err
                }
                expectation.fulfill()
            } catch {
                XCTFail("unknow error -> unexpected \(error.localizedDescription) (╯’ – ‘)╯︵")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }
}

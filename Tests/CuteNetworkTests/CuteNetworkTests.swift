import XCTest
@testable import CuteNetwork

final class CuteNetworkTests: XCTestCase {
    enum MockEndpoint: EndPointType {
        case test
        
        var baseURL: URL {
            return URL(string: "123")!
        }
        
        var path: String {
            return ""
        }
        
        var httpMethod: CuteNetwork.HTTPMethod {
            return .get
        }
        
        var task: CuteNetwork.HTTPTask {
            return .request
        }
        
        var headers: CuteNetwork.HTTPHeaders? {
            return [:]
        }
    }
    
    
    func testExample() async throws {
        
        let cute = Cute<MockEndpoint>()
        do {
//            XCTAssertNotEqual(a, Data())
        } catch {
            print("error: \(error)")
        }
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
    }
}

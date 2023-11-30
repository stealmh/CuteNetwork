//
//  NetworkLogger.swift
//  
//
//  Created by mino on 2023/11/29.
//

import Foundation

class NetworkLogger {
    
    static func log(request: URLRequest) {
        
        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = NSURLComponents(string: urlAsString)
        
        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
        let path = "\(urlComponents?.path ?? "")"
        let query = "\(urlComponents?.query ?? "")"
        let host = "\(urlComponents?.host ?? "")"
        
        var bodyLog: String = ""

        let headerLog = (request.allHTTPHeaderFields ?? [:])
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")

        if let body = request.httpBody {
            bodyLog += "\n \(NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "")"
        }
        
        debugPrint("🥚 [NetworkLogger Start]")
        defer { debugPrint("🐥 [NetworkLogger End]") }
        debugPrint("🐣 [NetworkLogger Request] URL: \(urlAsString)\n")
        debugPrint("🐣 [NetworkLogger Request] Method: \(method)")
        debugPrint("🐣 [NetworkLogger Request] Path: \(path)")
        debugPrint("🐣 [NetworkLogger Request] query: \(query)")
        
        #if DEBUG
        /// debugPrint는 멀티라인을 지원하지 않기 때문에 print로 사용하고 debug처리
        print("""
              "🐣 [NetworkLogger Header] header:\n \(headerLog)"\n
              """)
        
        print("""
              "🐣 [NetworkLogger Request] body:\n \(bodyLog)"\n
              """)
        #endif
    }
    
    static func log(response: URLResponse) {}
    
}

//
//  ResponseHandler.swift
//  
//
//  Created by mino on 2023/11/29.
//

import Foundation

class ResponseHandler {
    
    enum NetworkResponse: String {
        case success
        case invalidRequest = "잘못된 요청입니다 - 처리할 수 없음"
        case badRequest = "서버가 요청을 처리하지 못하였음"
        case failed = "네트워크 요청 실패"
        case noData = "decoding 할 데이터가 없는 응답이 반환되어 데이터가 없음"
        case unableToDecode = "응답을 decoding할 수 없음"
    }

    enum Result<String> {
        case success
        case failure(String)
    }

    class func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String> {
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.invalidRequest.rawValue + " Status Code: \(response.statusCode)")
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue + " Status Code: \(response.statusCode)")
        default: return .failure(NetworkResponse.failed.rawValue + " Status Code: \(response.statusCode)")
        }
    }
}

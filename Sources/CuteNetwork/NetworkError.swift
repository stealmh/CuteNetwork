//
//  NetworkError.swift
//  
//
//  Created by mino on 2023/11/29.
//

import Foundation

public enum NetworkError: Error {
    
    case parametersNil
    case encodingFailed
    case missingURL
    case noConnectionToInternet
    case noData
    case parsingError
    case paging
    case custom(message: String)
    
    var errorMessage: String {
        switch self {
        case .parametersNil:
            return "파라미터가 nil 입니다."
        case .encodingFailed:
            return "파라미터 encoding에 실패"
        case .missingURL:
            return "URL이 nil 입니다."
        case .noConnectionToInternet:
            return "네트워크 연결이 되어있지 않습니다."
        case .noData:
            return "decode를 시도했으나 값이 없습니다."
        case .parsingError:
            return "파싱에 문제가 있습니다."
        case .paging:
            return "페이지"
        case .custom(let message):
            return message
        }
    }
}


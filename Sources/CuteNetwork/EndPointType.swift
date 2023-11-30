//
//  EndPointType.swift
//  
//
//  Created by mino on 2023/11/29.
//

import Foundation
/// `Parameters` & `HTTPHeaders` typealias
public typealias Parameters = [String: Any]
public typealias HTTPHeaders = [String: String]
/// EndPointType
public protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
}

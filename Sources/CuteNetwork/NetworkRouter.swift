//
//  NetworkRouter.swift
//  
//
//  Created by mino on 2023/11/29.
//

import Foundation

public typealias NetworkRouterCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ()

protocol NetworkRouter: AnyObject {
    associatedtype EndPoint: EndPointType
    func petit(_ route: EndPoint, logAccess: Bool, completion: @escaping NetworkRouterCompletion)
    func cancel()
}

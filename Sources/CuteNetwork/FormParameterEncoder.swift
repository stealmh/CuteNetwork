//
//  File.swift
//  
//
//  Created by DEV IOS on 2023/11/29.
//

import Foundation

public struct FORMParameterEncoder: ParameterEncoder {
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        var parameterArray = [String]()
        for param in parameters {
            let newParam = "\(param.key)=\((param.value as AnyObject).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")"
            parameterArray.append(newParam)
        }
        let string = parameterArray.joined(separator: "&")
        urlRequest.httpBody = string.data(using: .utf8)
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
    }
}

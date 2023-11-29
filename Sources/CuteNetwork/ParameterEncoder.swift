//
//  ParameterEncoder.swift
//  
//
//  Created by mino on 2023/11/29.
//

import Foundation

public protocol ParameterEncoder {
    func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}

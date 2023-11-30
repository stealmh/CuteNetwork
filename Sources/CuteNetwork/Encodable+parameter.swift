//
//  Encodable+parameter.swift
//  
//
//  Created by DEV IOS on 2023/11/30.
//

import Foundation

extension Encodable {
    var toParameter: [String: Any]? {
        guard let object = try? JSONEncoder().encode(self) else { return nil }
        guard let dictionary = try? JSONSerialization.jsonObject(with: object, options: [])
                as? [String: Any] else { return nil }
        return dictionary
    }
}

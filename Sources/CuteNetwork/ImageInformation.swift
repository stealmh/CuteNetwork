//
//  ImageInformation.swift
//  
//
//  Created by mino on 2024/01/03.
//

import UIKit

public struct ImageInformation {
    let fieldName: String
    let fileName: String
    let mimeType: String
    let image: UIImage
}

public struct VideoInformation {
    let fieldName: String
    let fileName: String
    let mimeType: String
    let videoURL: URL
}

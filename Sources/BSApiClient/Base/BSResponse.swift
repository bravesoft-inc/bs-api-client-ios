//
//  BSResponse.swift
//  
//
//  Created by 斉藤　尚也 on 2022/01/16.
//

import Foundation

public struct BSResponse<Content: Codable> {
    public var code: Int?
    public var body: Content?
}

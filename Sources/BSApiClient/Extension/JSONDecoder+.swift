//
//  File.swift
//  
//
//  Created by 斉藤　尚也 on 2022/01/17.
//

import Foundation

extension JSONDecoder {
    public static var `default`: JSONDecoder {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "JST")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return decoder
    }
}

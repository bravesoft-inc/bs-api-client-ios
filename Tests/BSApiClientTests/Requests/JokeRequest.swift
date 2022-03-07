//
//  JokeService.swift
//  
//
//  Created by 斉藤　尚也 on 2022/01/17.
//

import Foundation
import BSApiClient

enum JokeRequest: BSRequestable {
    
    
    case getJoke
    
    var baseURL: String {
        return "https://icanhazdadjoke.com/"
    }
    
    var path: String {
        switch self {
        case .getJoke:
            return ""
        }
    }
    
    var method: BSRequestMethod {
        switch self {
        case .getJoke:
            return .get
        }
    }
    
    var bodyType: BSRequestBodyType {
        return .json
    }
    
    var headers: BSRequestHeaders? {
        get {
            ["Accept": "application/json"]
        }
        set { _ = newValue }
    }
    
    var parameters: BSRequestParameters? {
        switch self {
        case .getJoke:
            return nil
        }
    }
    
    var authorization: Bool {
        return false
    }
    
    mutating func updateHeaders(_ headers: BSRequestHeaders) {
        self.headers = headers
    }
}

//
//  File.swift
//  
//
//  Created by 斉藤　尚也 on 2022/01/16.
//

import Foundation

public enum BSNetworkError: Error {
    public enum ClientError: Int, Error {
        case badRequest = 400
        case unauthorized = 401
        case forbidden = 403
        case notFound = 404
        case tooManyRequest = 429
    }

    public enum ServerError: Int, Error {
        case internalServerError = 500
        case badGateway = 502
        case serviceUnavailable = 503
    }

    case noData
    case invalidResponse
    case invalidRequest
    case client(ClientError, msg: String? = nil)
    case server(ServerError, msg: String? = nil)
    case parseError(String? = nil)
    case unknown(msg: String? = nil)
    case failureTokenUpdate(code: Int? = nil)
    case failureSessionUpdate(code: Int? = nil)
    case collectionLost
    case dataNotAllowed
    case timeout
}

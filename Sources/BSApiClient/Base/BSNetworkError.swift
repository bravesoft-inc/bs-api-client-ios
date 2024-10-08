//
//  File.swift
//  
//
//  Created by 斉藤　尚也 on 2022/01/16.
//

import Foundation

public enum BSNetworkError: Error {
    case invalidResponse
    case invalidRequest
    case transfer(TransferError, data: Data?)
    case client(ClientError, data: Data?)
    case server(ServerError, data: Data?)
    case parseError(error: Error)
    case collectionLost
    case unknown(message: String? = nil)
}

// MARK: - ClientErrors
extension BSNetworkError {
    public enum ClientError: Int, Error {
        case badRequest = 400
        case unauthorized = 401
        case forbidden = 403
        case notFound = 404
        case methodNotAllowed = 405
        case proxyAuthenticationRequired = 407
        case requestTimeout = 408
        case confilict = 409
        case gone = 410
        case lengthRequired = 411
        case proconditionFailed = 412
        case payloadTooLarge = 413
        case uriTooLong = 414
        case unsupportedMediaType = 415
        case rangeNotSatisfiable = 416
        case expectationFailed = 417
        case misdirectedRequest = 421
        case tooEarly = 425
        case upgradeRequired = 426
        case preconditionRequired = 428
        case tooManyRequest = 429
        case requestHeaderFieldsTooLarge = 431
        case unavailableForLegalReasons = 451
    }
}

// MARK: - ServerErrors
extension BSNetworkError {
    public enum ServerError: Int, Error {
        case internalServerError = 500
        case notImplemented = 501
        case badGateway = 502
        case serviceUnavailable = 503
        case gatewayTimeout = 504
        case hTTPVersionNotSupported = 505
        case variantAlsoNegotiates = 506
        case notExtended = 510
        case networkAuthenticationRequired = 511
    }
}

// MARK: - TransfoerErrors
extension BSNetworkError {
    public enum TransferError: Int, Error {
        case multipleChoices = 300
        case movedParmanently = 301
        case movedTemporarily = 302
        case seeOther = 303
        case notModified = 304
        case useProxy = 305
        case temporaryRedirect = 307
    }
}

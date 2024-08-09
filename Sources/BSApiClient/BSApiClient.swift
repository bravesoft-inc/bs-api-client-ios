//
//  BSApiClient.swift
//
//
//  Created by 斉藤　尚也 on 2022/01/17.
//

import Foundation

@available(iOS 13.0, *)
public class BSApiClient {
    private let decoder: JSONDecoder
    public let waitTime: Int
    public var mockMode: Bool
    
    public init(decoder: JSONDecoder = .default, waitTime: Int = 20, isMockMode: Bool = false) {
        self.decoder = decoder
        self.waitTime = waitTime
        self.mockMode = isMockMode
    }

    public func fetch<T: Codable>(_ request: BSRequestable, session: URLSession = .shared) async throws -> BSResponse<T> {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard var urlRequest = mockMode ? request.mockModeURLRequest : request.urlRequst else {
                return continuation.resume(throwing: BSNetworkError.invalidRequest)
            }
            
            urlRequest.timeoutInterval = TimeInterval(waitTime)
            
            session.dataTask(with: urlRequest) { data, response, error in
                if let error = error as NSError? {
                    if error.domain == NSURLErrorDomain, error.code == NSURLErrorTimedOut {
                        return continuation.resume(throwing: BSNetworkError.client(.requestTimeout, data: nil))
                    } else if error.code == NSURLErrorNotConnectedToInternet || error.code == NSURLErrorDataNotAllowed {
                        return continuation.resume(throwing: BSNetworkError.collectionLost)
                    } else {
                        return continuation.resume(throwing: BSNetworkError.unknown(message: error.localizedDescription))
                    }
                }
                
                guard let data = data, let response = response as? HTTPURLResponse else {
                    return continuation.resume(throwing: BSNetworkError.invalidResponse)
                }

                let statusCode: Int = response.statusCode
                switch response.statusCode {
                case 200...299:
                    do {
                        var body: T? = nil

                        if !data.isEmpty {
                            body = try self.decoder.decode(T.self, from: data)
                        }
                        
                        continuation.resume(returning: BSResponse(code: statusCode, body: body))
                    } catch {
                        continuation.resume(throwing: BSNetworkError.parseError(error: error))
                    }
                case 300...399:
                    guard let transferError = BSNetworkError.TransferError(rawValue: statusCode) else {
                        return continuation.resume(throwing: BSNetworkError.unknown(message: "\(statusCode)"))
                    }

                    return continuation.resume(throwing: BSNetworkError.transfer(transferError, data: data))
                case 400...499:
                    guard let clientError = BSNetworkError.ClientError(rawValue: statusCode) else {
                        return continuation.resume(throwing: BSNetworkError.unknown(message: "\(statusCode)"))
                    }
                    
                    return continuation.resume(throwing: BSNetworkError.client(clientError, data: data))
                case 500...599:
                    guard let serverError = BSNetworkError.ServerError(rawValue: statusCode) else {
                        return continuation.resume(throwing: BSNetworkError.unknown(message: "\(statusCode)"))
                    }
                    
                    return continuation.resume(throwing: BSNetworkError.server(serverError, data: data))
                default:
                    return continuation.resume(throwing: BSNetworkError.unknown(message: "\(statusCode)"))
                }
            }
            .resume()
        }
    }
    
    public func getFileSize(fileURL: URL) async throws -> Int {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(
                url: fileURL,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                timeoutInterval: TimeInterval(waitTime)
            )
            request.httpMethod = BSRequestMethod.head.rawValue
            
            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    print("[BSApiClient] \(error.localizedDescription)")
                    return continuation.resume(throwing: error)
                }
                
                guard let response = response else {
                    print("[BSApiClient] invalid response.")
                    return continuation.resume(throwing: BSNetworkError.invalidResponse)
                }

                let contentLength: Int64 = response.expectedContentLength ?? NSURLSessionTransferSizeUnknown
                return continuation.resume(returning: Int(contentLength))
            }
            .resume()
        }
    }
}

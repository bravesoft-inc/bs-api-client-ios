//
//  BSApiClient.swift
//
//
//  Created by 斉藤　尚也 on 2022/01/17.
//

import Foundation

public class BSApiClient {
    private let decoder: JSONDecoder
    public let waitTime: Int
    
    public init(decoder: JSONDecoder = .default, waitTime: Int = 20) {
        self.decoder = decoder
        self.waitTime = waitTime
    }
    
    @available(iOS 13.0, *)
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
                    return continuation.resume(throwing: error)
                }
                
                guard let response = response else {
                    return continuation.resume(throwing: BSNetworkError.invalidResponse)
                }

                let contentLength: Int64 = response.expectedContentLength ?? NSURLSessionTransferSizeUnknown
                return continuation.resume(returning: Int(contentLength))
            }
            .resume()
        }
    }
}

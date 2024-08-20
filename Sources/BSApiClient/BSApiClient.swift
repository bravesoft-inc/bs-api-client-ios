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
        guard var urlRequest = mockMode ? request.mockModeURLRequest : request.urlRequst else {
            throw BSNetworkError.invalidRequest
        }

        urlRequest.timeoutInterval = TimeInterval(waitTime)

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BSNetworkError.invalidResponse
        }

        let statusCode = httpResponse.statusCode

        switch statusCode {
        case 200...299:
            do {
                var body: T? = nil

                if !data.isEmpty {
                    body = try self.decoder.decode(T.self, from: data)
                }

                return BSResponse(code: statusCode, body: body)
            } catch {
                throw BSNetworkError.parseError(error: error)
            }

        case 300...399:
            guard let transferError = BSNetworkError.TransferError(rawValue: statusCode) else {
                throw BSNetworkError.unknown(message: "\(statusCode)")
            }

            throw BSNetworkError.transfer(transferError, data: data)

        case 401:
            guard let serverError = BSNetworkError.ClientError(rawValue: statusCode) else {
                throw BSNetworkError.unknown(message: "\(statusCode)")
            }
            throw BSNetworkError.client(.unauthorized, data: data)

        case 400...499:
            guard let clientError = BSNetworkError.ClientError(rawValue: statusCode) else {
                throw BSNetworkError.unknown(message: "\(statusCode)")
            }

            throw BSNetworkError.client(clientError, data: data)

        case 500...599:
            guard let serverError = BSNetworkError.ServerError(rawValue: statusCode) else {
                throw BSNetworkError.unknown(message: "\(statusCode)")
            }

            throw BSNetworkError.server(serverError, data: data)

        default:
            throw BSNetworkError.unknown(message: "\(statusCode)")
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

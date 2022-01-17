//
//  BSApiClientPublisher.swift
//  
//
//  Created by 斉藤　尚也 on 2022/01/17.
//

import Foundation
import Combine

@available(iOS 13.0.0, *)
public actor BSApiClientPublisher {
    private let decoder: JSONDecoder
    private let waitTime: Int
    
    public init(decoder: JSONDecoder = .default, waitTime: Int = 20) {
        self.decoder = decoder
        self.waitTime = waitTime
    }
    
    public func fetch<T: Codable>(_ request: BSRequestable, session: URLSession = .shared) -> AnyPublisher<BSResponse<T>, BSNetworkError> {
        guard let urlRequest = request.urlRequst else {
            return Fail(error: BSNetworkError.invalidRequest).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .subscribe(on: DispatchQueue.global())
            .mapError { error -> BSNetworkError in
                guard !error.isNetworkError else { return .collectionLost }

                return .unknown()
            }
            .flatMap { output -> AnyPublisher<BSResponse<T>, BSNetworkError> in
                guard let response = output.response as? HTTPURLResponse else {
                    return Fail(error: .invalidResponse).eraseToAnyPublisher()
                }
                
                let statusCode: Int = response.statusCode
                switch response.statusCode {
                case 200...299:
                    return Future<BSResponse<T>, BSNetworkError> {
                        do {
                            let body = try self.decoder.decode(T.self, from: output.data)
                            $0(.success(BSResponse(code: statusCode, body: body)))
                        } catch {
                            $0(.failure(.parseError(error.localizedDescription)))
                        }
                    }.eraseToAnyPublisher()
                case 400...499:
                    guard let clientError = BSNetworkError.ClientError(rawValue: statusCode) else {
                        return Fail(error: .unknown(message: "\(statusCode)")).eraseToAnyPublisher()
                    }
                    
                    return Fail(error: .client(clientError)).eraseToAnyPublisher()
                case 500...599:
                    guard let serverError = BSNetworkError.ServerError(rawValue: statusCode) else {
                        return Fail(error: .unknown(message: "\(statusCode)")).eraseToAnyPublisher()
                    }
                    
                    return Fail(error: .server(serverError)).eraseToAnyPublisher()
                default:
                    return Fail(error: .unknown(message: "\(statusCode)")).eraseToAnyPublisher()
                }
            }
            .timeout(.seconds(waitTime), scheduler: DispatchQueue.main, options: nil) {
                return .client(.requestTimeout, message: nil)
            }
            .eraseToAnyPublisher()
    }
}
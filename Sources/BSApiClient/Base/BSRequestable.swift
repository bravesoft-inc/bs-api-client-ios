//
//  BSRequestable.swift
//  
//
//  Created by 斉藤　尚也 on 2022/01/16.
//

import Foundation

public enum BSRequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public enum BSRequestBodyType {
    case json
    case formData
}

public typealias BSRequestHeaders = [String: String]
public typealias BSRequestParameters = [String: Any]

// MARK: - BSRequestable
public protocol BSRequestable {
    var baseURL: String { get }
    var path: String { get }
    var method: BSRequestMethod { get }
    var bodyType: BSRequestBodyType { get }
    var headers: BSRequestHeaders? { get }
    var parameters: BSRequestParameters? { get }
    var authorization: Bool { get }
}

extension BSRequestable {
    public var urlRequst: URLRequest? {
        guard let url = url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        
        return request
    }
    
    public var mockModeURLRequest: URLRequest? {
        guard var urlComponents = URLComponents(string: baseURL) else {
            return nil
        }
        
        urlComponents.path += path
        
        var request = URLRequest(url: urlComponents.url)
        request.httpMethod = BSRequestMethod.get.rawValue
        
        return request
    }
    
    private var url: URL? {
        guard var urlComponents = URLComponents(string: baseURL) else {
            return nil
        }
        
        urlComponents.path += path
        urlComponents.queryItems = queryItems
        
        return urlComponents.url
    }
    
    private var queryItems: [URLQueryItem]? {
        guard method == .get, let parameters = parameters else {
            return nil
        }
        
        return parameters.compactMap {
            return URLQueryItem(name: $0.key, value: String(describing: $0.value))
        }
    }
    
    private var body: Data? {
        guard [.post, .put, .patch].contains(method), let parameters = parameters else {
            return nil
        }
        
        switch bodyType {
        case .json:
            return try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        case .formData:
            let urlQueryValueAllowed: CharacterSet = {
                let generalDelimitersToEncode = ":#[]@"
                let subDelimitersToEncode = "!$&'()*+,;="

                var allowed = CharacterSet.urlQueryAllowed
                allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
                return allowed
            }()
            
            return parameters
                .map { key, value in
                    let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: urlQueryValueAllowed) ?? ""
                    let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: urlQueryValueAllowed) ?? ""
                    return escapedKey + "=" + escapedValue
                }
                .joined(separator: "&")
                .data(using: .utf8)
        }
    }
}

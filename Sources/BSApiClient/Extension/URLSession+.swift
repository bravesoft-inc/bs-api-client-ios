//
//  URLSession+.swift
//  
//
//  Created by 斉藤　尚也 on 2022/01/17.
//

import Foundation

@available(iOS 13.0.0, *)
extension URLSession.DataTaskPublisher.Failure {
    public var isNetworkError: Bool {
        return errorCode == NSURLErrorNotConnectedToInternet || errorCode == NSURLErrorDataNotAllowed
    }
}

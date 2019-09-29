//
//  URLRequest+RxNetworkClient.swift
//  
//
//  Created by John Grange on 9/27/19.
//

import Foundation

extension URLRequest {

    /// Creates an instance with the specified `method`, `url` and `headers`.
    ///
    /// - parameter url:     The URL.
    /// - parameter method:  The HTTP method.
    /// - parameter headers: The HTTP headers. `nil` by default.
    ///
    /// - returns: The new `URLRequest` instance.
    public init(url: URL, method: HTTPMethod,
                headers: [String: String]? = nil,
                timeoutInterval: TimeInterval = HTTPREQUEST_TIMEOUT_SECS,
                httpBody: Data? = nil) {

        self.init(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: timeoutInterval)

        self.httpBody = httpBody
        self.httpMethod = method.rawValue

        if let headers = headers {
            for (headerField, headerValue) in headers {
                setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
    }
}

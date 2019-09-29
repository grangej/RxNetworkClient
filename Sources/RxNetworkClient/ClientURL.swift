//
//  File.swift
//  
//
//  Created by John Grange on 9/27/19.
//

import Foundation

public protocol ClientURL {
    
    /// The time the url should be cached if any, this is used for a very simplistic rate limting when making requests.
    var cacheTime: TimeInterval { get }
    
    /// Timeout value used for the url when making the request
    var timeout: TimeInterval { get }
    
    /// The absolute URL that will be used to genereate the request
    var absoluteUrl: URL! { get }
}

extension ClientURL {
    
    internal func fullURL(_ paramaters: [String: Any]) -> URL {
        
        var urlQueryItems: [URLQueryItem]? = nil
        if let urlParams = paramaters as? [String: String] {

            urlQueryItems = urlParams.map({ (paramater) -> URLQueryItem in

                return URLQueryItem(name: paramater.key, value: paramater.value)
            })
        }

        guard
            let baseUrl = self.absoluteUrl,
            let requestUrl = baseUrl.appendingQueryItems(queryItems: urlQueryItems) else {

                return self.absoluteUrl
        }

        return requestUrl
    }
    
    internal func isExpired(_ date: Date) -> Bool {

        return abs(date.timeIntervalSinceNow) > cacheTime
    }
}



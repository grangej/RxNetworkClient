//
//  URL+RxNetworkClient.swift
//  
//
//  Created by John Grange on 9/27/19.
//

import Foundation

extension URL {

    func appendingQueryItems(queryItems: [URLQueryItem]?) -> URL? {

        if queryItems == nil { return self }

        var mutableComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)

        mutableComponents?.queryItems = queryItems

        return mutableComponents?.url
    }
}

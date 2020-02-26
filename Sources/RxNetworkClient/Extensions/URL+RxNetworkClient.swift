//
//  URL+RxNetworkClient.swift
//  
//
//  Created by John Grange on 9/27/19.
//

import Foundation

extension URL {

    func appendingQueryItems(queryItems: [URLQueryItem]?) -> URL? {

        guard let queryItems = queryItems else { return self }

        var mutableComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)

        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        mutableComponents?.percentEncodedQuery = queryItems.map({ (item) -> String? in

            guard let itemValue = item.value,
                let key = item.name.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet),
                let value = itemValue.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) else { return nil }
            return "\(key)=\(value)"
        }).compactMap { $0 }.joined(separator: "&")

        return mutableComponents?.url
    }
}

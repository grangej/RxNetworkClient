//
//  String+RFC3986.swift
//  
//
//  Created by John Grange on 10/8/19.
//

import Foundation

extension String {
    
    public func stringByAddingPercentEncodingForRFC3986() -> String? {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet)
    }
}


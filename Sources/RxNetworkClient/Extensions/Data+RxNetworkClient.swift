//
//  Data+RxNetworkClient.swift
//  
//
//  Created by John Grange on 9/28/19.
//

import Foundation

public extension Data {
    
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
    
    var utf8String: String {

        return String(data: self, encoding: .utf8) ?? "Unable to convert error data to utf8 String!"
    }
}

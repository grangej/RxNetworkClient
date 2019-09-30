//
//  DictionaryEncoder.swift
//  
//
//  Created by John Grange on 9/29/19.
//

import Foundation

public class DictionaryEncoder {
    public var result: [String: String]

    public init() {
        result = [:]
    }

    public func encode(_ encodable: DictionaryEncodable) -> [String: String] {

        encodable.encode(self)
        return result
    }

    public func encode<T, K>(_ value: T, key: K) where K: RawRepresentable, K.RawValue == String, T: LosslessStringConvertible {
        result[key.rawValue] = String(value)
    }

    public func encodeIfPresent<T, K>(_ value: T?, key: K) where K: RawRepresentable, K.RawValue == String, T: LosslessStringConvertible {

        guard let value = value else { return }
        result[key.rawValue] = String(value)
    }
}

public protocol DictionaryEncodable {
    func encode(_ encoder: DictionaryEncoder)
}

extension Encodable {

    public func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization
            .jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                throw NSError()
        }
        return dictionary
    }
}


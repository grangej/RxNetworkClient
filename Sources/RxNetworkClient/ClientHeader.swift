//
//  ClientHeader.swift
//  
//
//  Created by John Grange on 9/28/19.
//

import Foundation

public protocol ClientHeader {
    
    func headers() throws -> [String: String]?
    var token: String? { get }
}

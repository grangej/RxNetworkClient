//
//  ClientHeader.swift
//  
//
//  Created by John Grange on 9/28/19.
//

import Foundation

public protocol ClientHeader {
    
    var headers: [String: String]? { get }
}

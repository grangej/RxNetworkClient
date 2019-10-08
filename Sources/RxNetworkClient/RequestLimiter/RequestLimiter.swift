//
//  RequestLimiter.swift
//  
//
//  Created by John Grange on 9/27/19.
//

import Foundation

internal struct RequestLimiterURL: Equatable, Hashable {

    let clientURL: AnyClientURL
    let fullURLString: String

    init(clientURL: AnyClientURL, fullURLString: String) {

        self.clientURL = clientURL
        self.fullURLString = fullURLString
    }

    public static func == (lhs: RequestLimiterURL, rhs: RequestLimiterURL) -> Bool {

        return lhs.clientURL.absoluteUrl == rhs.clientURL.absoluteUrl && lhs.fullURLString == rhs.fullURLString
    }

    public func hash(into hasher: inout Hasher) {

        hasher.combine(self.clientURL.absoluteUrl)
        hasher.combine(self.fullURLString)
    }
}

public struct AnyClientURL: Hashable, Equatable, ClientURL {
    public static func == (lhs: AnyClientURL, rhs: AnyClientURL) -> Bool {
        return lhs.absoluteUrl.absoluteString == rhs.absoluteUrl.absoluteString
    }
    
    public func hash(into hasher: inout Hasher) {
        
        hasher.combine(url.absoluteUrl.absoluteString.hashValue)
    }
    
    public var cacheTime: TimeInterval {
        return url.cacheTime
    }
    
    internal func isExpired(_ date: Date) -> Bool {
        return url.isExpired(date)
    }
    
    public var shouldEscape: Bool { return url.shouldEscape }
    public var timeout: TimeInterval { return url.timeout }
            
    public var absoluteUrl: URL! { return url.absoluteUrl }
    
    private let url: ClientURL
    
    public init(_ clientURL: ClientURL) {
            
        self.url = clientURL
    }
}

public class RequestLimiter {

    private let queue = DispatchQueue(label: "RequestLimiter.Queue")
    private var requests = [AnyClientURL: [RequestLimiterURL: Date]]()

    public func shouldMakeRequest(_ clientUrl: ClientURL, fullURL: URL) -> Bool {

        return queue.sync {

            let anyClientUrl = AnyClientURL(clientUrl)

            let reqMatcher = RequestLimiterURL(clientURL: anyClientUrl, fullURLString: fullURL.absoluteString)

            guard let existingRequests = requests[anyClientUrl] else { return true }

            guard let existingReqDate = existingRequests[reqMatcher] else { return true }

            return clientUrl.isExpired(existingReqDate)
        }
    }

    public func didCompleteRequest(_ clientUrl: ClientURL, fullURL: URL) {

        queue.sync { [weak self] in

            let anyClientUrl = AnyClientURL(clientUrl)

            let reqMatcher = RequestLimiterURL(clientURL: anyClientUrl, fullURLString: fullURL.absoluteString)

            guard var groupedRequests = self?.requests[anyClientUrl] else {

                let requests = [reqMatcher: Date()]
                self?.requests[anyClientUrl] = requests
                return
            }

            groupedRequests[reqMatcher] = Date()
            self?.requests[anyClientUrl] = groupedRequests
        }
    }

    public func invalidate(_ url: ClientURL) {
        
        let anyClientUrl = AnyClientURL(url)
        requests[anyClientUrl] = [:]
    }

    public func invalidateAll() {

        requests = [AnyClientURL: [RequestLimiterURL: Date]]()
    }
}

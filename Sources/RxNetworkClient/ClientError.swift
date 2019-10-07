//
//  ClientError.swift
//  
//
//  Created by John Grange on 9/28/19.
//

import Foundation

public typealias APIClientError = ClientError

public enum ClientError: LocalizedError, CustomDebugStringConvertible, CustomStringConvertible {

    case invalidUrlError
    case parseError
    case urlRequestError(error: Error)
    case serverDown
    case apiErrorWithCode(responseData: Data, statusCode: Int)
    case apiErrorWithBadRequest(responseData: Data, statusCode: Int)

    public var errorDescription: String? {

        return debugDescription
    }

    public var debugDescription: String {

        switch self {

        case .invalidUrlError: return "invalidUrlError"
        case .parseError: return "parseError"
        case .urlRequestError(error: let error):
            return "UrlRequestError: \(error.localizedDescription)"
        case .serverDown: return "severDown"
        case .apiErrorWithCode:
            return "apiErrorWithCode"
        case .apiErrorWithBadRequest:
            return "apiErrorWithBadRequest"
        }
    }

    public var description: String {
        return debugDescription
    }
}

public extension Error {

    var shouldRetry: Bool {

        let baseError = self as NSError

        if baseError.domain == NSURLErrorDomain {

            return true
        }

        if let rootError = baseError.userInfo[NSUnderlyingErrorKey] as? NSError {

            if rootError.domain == NSURLErrorDomain {

                return true
            }
        }
        
        do {

            throw self
        } catch ClientError.urlRequestError {

            return true
        } catch {

            return false
        }
    }

    var shouldFail: Bool {

        guard let connection = RxNetworkClient.reachability?.connection else { return false }

        if connection == .none { return true }
        
        let baseError = self as NSError

        if baseError.domain == NSURLErrorDomain {

            return false
        }

        if let rootError = baseError.userInfo[NSUnderlyingErrorKey] as? NSError {

            if rootError.domain == NSURLErrorDomain {

                return false
            }
        }

        do {

            throw self
        } catch ClientError.urlRequestError {
            return false
        } catch ClientError.serverDown {
            return true
        } catch {

            return false
        }
    }
}

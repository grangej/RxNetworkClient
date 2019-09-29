import Foundation
import RxSwift
import RxRelay
import WebKit
import Reachability

public typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void

public protocol URLSessionDataTaskProtocol {

    func resume()
}

/// Mock URLSessionProtocol so we can stub network responses
public protocol URLSessionProtocol {

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

public protocol Tracer {
    
    func onStart()
    func onStop(success: Bool)
}

public protocol TracingDataSource {
    
    func tracer(endpoint: ClientURL, requestType: HTTPMethod) -> Tracer
}

extension URLSession: URLSessionProtocol {}

public enum HTTPMethod: String {

    case options = "OPTIONS"
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case trace = "TRACE"
    case connect = "CONNECT"
}

public enum ParameterEncoding {

    case jsonEncoding
    case urlEncoding
    case multiPartForm(boundary: String)
}

public let HTTPREQUEST_TIMEOUT_SECS = 20.0

open class RxNetworkClient: NSObject {

    internal var urlSession: URLSessionProtocol!
    internal var externalAPIURLSession: URLSessionProtocol!
    internal let requestLimiter = RequestLimiter()

    public let disposeBag = DisposeBag()
    
    public static var reachability: Reachability?
    public let onConnectionError: PublishRelay<Reachability.Connection> = PublishRelay()
    public let onRecordError: PublishRelay<Error> = PublishRelay()
    public let onRecordTimeout: PublishRelay<ClientURL> = PublishRelay()
    public weak var tracingDataSource: TracingDataSource?
    
    public init(urlSession: URLSessionProtocol? = nil) {

        super.init()

        if let urlSession = urlSession {

            self.urlSession = urlSession
        } else {

            self.urlSession = self.defaultURLSession
        }
    }

    //FIXME: This needs to be migrated / and done
    private func setupCertificatePinning() {

    }

    public func clearStackAndCookies() {

        // Remove WKWebView cookies
        DispatchQueue.main.async {

            let dataStore = WKWebsiteDataStore.default()
            let allSites = WKWebsiteDataStore.allWebsiteDataTypes()
            dataStore.fetchDataRecords( ofTypes: allSites, completionHandler: { (dataRecordArray) in

                WKWebsiteDataStore.default().removeData(ofTypes: allSites,
                                                        for: dataRecordArray,
                                                        completionHandler: { })
            })
        }

        // Remove cookies from cookies store
        if let cookieStore = HTTPCookieStorage.shared.cookies {

            for cookie: HTTPCookie in cookieStore {

                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
}

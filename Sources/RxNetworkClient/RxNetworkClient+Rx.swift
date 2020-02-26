//
//  RxNetworkClient+Rx.swift
//  
//
//  Created by John Grange on 9/28/19.
//

import Foundation
import RxSwift
import Logger
import Multipart
import RxCocoa

public extension Reactive where Base: RxNetworkClient {
    
    /// Makes a request to member api servers returning the response as an Single<Data>
    /// This code will gaurentee that ther response is a success otherwise it will return an Single.Error
    ///
    /// NOTE: Convience method to convert [String: String] to Data
    /// - Parameters:
    ///   - apiClientURL: The API Endpoint
    ///   - requestType: .get, .post, .put, .delete
    ///   - parameters: parameters to convert into http post data
    ///   - header: ClientHeader
    /// - Returns: Single<Data> on 200 or 302, Single<Error> on all other codes
    func response(apiClientURL: ClientURL,
                  requestType: HTTPMethod,
                  parameters: [String: String],
                  header: ClientHeader) -> Single<Data> {
        
        do {
            
            let data = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            return self.response(apiClientURL: apiClientURL, requestType: requestType, httpBody: data, header: header)
        } catch let error {
            
            sdn_log(error: error, category: Category.api)
            return Single.error(error)
        }
    }
    
    /// Makes a request to member api servers returning the response as an Single<Data>
    /// This code will gaurentee that ther response is a success otherwise it will return an Single.Error
    ///
    /// NOTE: Convience method to convert [String: Any] to Data
    /// - Parameters:
    ///   - apiClientURL: The API Endpoint
    ///   - requestType: .get, .post, .put, .delete
    ///   - parameters: parameters to convert into http post data
    ///   - header: ClientHeader
    ///   - parameterEncoding: .jsonEncoding, urlEncoding
    /// - Returns: Single<Data> on 200 or 302, Single<Error> on all other codes
    func response(apiClientURL: ClientURL,
                  requestType: HTTPMethod,
                  parameters: [String: String],
                  parameterEncoding: ParameterEncoding = .jsonEncoding,
                  header: ClientHeader) -> Single<Data> {
        
        switch parameterEncoding {
            
        case .urlEncoding:
            
            let urlParams = parameters
            
            let queryItems = urlParams.map({ (paramater) -> URLQueryItem in

                return URLQueryItem(name: paramater.key, value: paramater.value)
            })
            
            return self.response(apiClientURL: apiClientURL,
                                 requestType: requestType,
                                 httpBody: nil,
                                 parameterEncoding: parameterEncoding,
                                 header: header,
                                 urlQueryItems: queryItems)
            
        case .multiPartForm:
            
            fatalError("Wrong method, use response(:codableData")
        default:
            do {
                let data = try JSONSerialization.data(withJSONObject: parameters, options: [])
                
                return self.response(apiClientURL: apiClientURL,
                                     requestType: requestType,
                                     httpBody: data,
                                     header: header)
                
            } catch let error {
                
                sdn_log(error: error, category: Category.api)
                return Single.error(error)
            }
        }
    }
    
    /// Makes a request to member api servers returning the response as an Single<Data>
    /// This code will gaurentee that ther response is a success otherwise it will return an Single.Error
    ///
    /// NOTE: Convience method to convert Encodable to Data
    /// - Parameters:
    ///   - apiClientURL: The API Endpoint
    ///   - requestType: .get, .post, .put, .delete
    ///   - codableData: Any encodable data
    ///   - header: ClientHeader
    /// - Returns: Single<Data> on 200 or 302, Single<Error> on all other codes
    func response<T: Encodable>(apiClientURL: ClientURL,
                                requestType: HTTPMethod,
                                codableData: T,
                                parameterEncoding: ParameterEncoding = .jsonEncoding,
                                header: ClientHeader) -> Single<Data> {
        
        do {
            
            switch parameterEncoding {
                
            case .jsonEncoding:
                let encoder = JSONEncoder()
                
                encoder.outputFormatting = .prettyPrinted
                let data = try encoder.encode(codableData)
                
                return self.response(apiClientURL: apiClientURL,
                                     requestType: requestType,
                                     httpBody: data,
                                     header: header)
            case .multiPartForm(let boundary):
                
                let encoder = FormDataEncoder()
                sdn_log(object: "FormData: \(codableData)", category: Category.api, logType: .debug)
                let data = try encoder.encode(codableData, boundary: boundary)
                
                return self.response(apiClientURL: apiClientURL,
                                     requestType: requestType,
                                     httpBody: data,
                                     parameterEncoding: parameterEncoding,
                                     header: header)
            case .urlEncoding:
                fatalError("Wrong method, use response(:parameters")
            }
            
            
        } catch let error {
            
            sdn_log(error: error, category: Category.api)
            return Single.error(error)
        }
    }
    
    /// Makes a request to member api servers returning the response as an Observable<Data>
    /// This code will gaurentee that ther response is a success otherwise it will return an Observable.Error
    ///
    /// - Parameters:
    ///   - apiClientURL: The API Endpoint
    ///   - requestType: .get, .post, .put, .delete
    ///   - httpBody: The http post body data
    ///   - header: APIClientHeader
    /// - Returns: Single<Data> on 200 or 302, Single<Error> on all other codes
    func response(apiClientURL: ClientURL,
                  requestType: HTTPMethod,
                  httpBody: Data?,
                  parameterEncoding: ParameterEncoding = .jsonEncoding,
                  header: ClientHeader,
                  urlQueryItems: [URLQueryItem]? = nil) -> Single<Data> {
        
        guard
            let baseUrl = apiClientURL.absoluteUrl,
            let requestUrl = baseUrl.appendingQueryItems(queryItems: urlQueryItems) else {
                
                return Single.error(APIClientError.invalidUrlError)
        }
        
        var headers: [String: String]?
        
        do {
            headers = try header.headers()
        } catch {
            return Single.error(error)
        }
        
        sdn_log(object: "APIClient request begin", category: Category.api, logType: .debug)
        
        sdn_log(object: "<----------------------Request parameters----------------------",
                category: Category.api, logType: .debug)
        sdn_log(object: "URL: \(requestUrl.absoluteString)", category: Category.api, logType: .debug)
        
        if let body = httpBody {
            
            if let prettyString = body.prettyPrintedJSONString {
                sdn_log(object: "Body: \n\(prettyString)\n", category: Category.api, logType: .debug)
            } else {
                sdn_log(object: "Body: \(body.utf8String)", category: Category.api, logType: .debug)
            }
        }
        
        if let params = urlQueryItems {
            
            sdn_log(object: "URLQueryItems: \(params)", category: Category.api, logType: .debug)
        }
        
        sdn_log(object: "parameterEncoding: \(parameterEncoding)", category: Category.api, logType: .debug)
        
        sdn_log(object: "Header: \(header)", category: Category.api, logType: .debug)
        
        if let headers = headers {
            
            sdn_log(object: "Headers: \(headers)", category: Category.api, logType: .debug)
        }
        
        sdn_log(object: "RequestType: \(requestType)", category: Category.api, logType: .debug)
        sdn_log(object: "----------------------Request parameters----------------------/>",
                category: Category.api, logType: .debug)
        
        return Observable.create { observer in
            
            let urlSession: URLSessionProtocol! = self.base.urlSession
            var request = URLRequest(url: requestUrl, method: requestType, headers: headers, timeoutInterval: apiClientURL.timeout, httpBody: httpBody)
            
            switch parameterEncoding {
                
            case .urlEncoding:
                request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            case .jsonEncoding:
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            case .multiPartForm(boundary: let boundary):
                request.setValue("multipart/form-data; charset=utf-8; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            }
            
            /// USE URLSessionProtocol
            
            sdn_log(object: "urlSession task created", category: Category.api, logType: .debug)
            let clientTrace = self.base.tracingDataSource?.tracer(endpoint: apiClientURL, requestType: requestType)
            clientTrace?.onStart()
            
            let task = urlSession.dataTask(with: request, completionHandler: { (responseData, response, error) in
                sdn_log(object: "<----------------------Response Received----------------------",
                        category: Category.api, logType: .debug)
                
                // Handle Response Error
                if let error = error {
                    
                    clientTrace?.onStop(success: false)
                    
                    sdn_log(error: error, category: Category.api)
                    
                    if (error as NSError).code != NSURLErrorCancelled {
                        self.base.onRecordError.accept(error)
                    }
                    
                    if (error as NSError).code == NSURLErrorTimedOut {
                        self.base.onRecordTimeout.accept(apiClientURL)
                    }
                    
                    observer.onError(APIClientError.urlRequestError(error: error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    
                    clientTrace?.onStop(success: false)
                    
                    self.base.onRecordError.accept(APIClientError.parseError)
                    observer.onError(APIClientError.parseError)
                    
                    return
                }
                
                let data = responseData ?? Data()
                
                if let urlString = request.url?.absoluteString {
                    sdn_log(object: "url: \(urlString)", category: Category.api, logType: .debug)
                }
                sdn_log(object: data.utf8String, category: Category.api, logType: .debug)
                
                switch httpResponse.statusCode {
                    
                case 200:
                    
                    clientTrace?.onStop(success: true)
                    observer.onNext(data)
                case 302:
                    clientTrace?.onStop(success: false)
                    
                    // FIXME: Can we handle redirect??
                    observer.onNext(data)
                case self.base.badRequestCodes:
                    clientTrace?.onStop(success: false)
                   
                    let error = APIClientError.apiErrorWithBadRequest(responseData: data, statusCode: httpResponse.statusCode)
                    self.base.onRecordError.accept(error)
                    observer.onError(error)
                case self.base.authorizationFailedCodes:
                    clientTrace?.onStop(success: false)
                    let error = APIClientError.apiErrorWithCode(responseData: data, statusCode: httpResponse.statusCode)
                    self.base.onRecordError.accept(error)
                    self.base.onAuthorizationFailed.accept(error)
                    observer.onError(error)
                case self.base.serverDownCodes:
                    clientTrace?.onStop(success: false)
                    
                    let error = ConnectionError.serverDown
                    self.base.onRecordError.accept(error)
                    observer.onError(error)
                default: // Handles 4xx, 5xx and other errors
                    clientTrace?.onStop(success: false)
                    
                    let error = APIClientError.apiErrorWithCode(responseData: data, statusCode: httpResponse.statusCode)
                    self.base.onRecordError.accept(error)
                    observer.onError(error)
                }
                
                sdn_log(object: "----------------------Response Received----------------------/>",
                        category: Category.api, logType: .debug)
                
                observer.onCompleted()
            })
            
            task.resume()
            sdn_log(object: "urlSession task resumed", category: Category.api, logType: .debug)
            
            return Disposables.create {
                
                task.cancel()
            }
        }.retryOnConnect(1).do(onError: { (error) in
            
            sdn_log(error: error, category: Category.api)
            
            guard error.shouldFail else { return }
            
            guard let connection = RxNetworkClient.reachability?.connection else { return }

            let errorType: ConnectionError = (connection != .none) ? .serverDown : .internetDown

            self.base.onConnectionError.accept(errorType)
            
        }).asSingle()
    }
}

func ~=<T : Equatable>(array: [T], value: T) -> Bool {
    return array.contains(value)
}

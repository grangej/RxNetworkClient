//
//  RxNetworkClient+URLSession.swift
//  
//
//  Created by John Grange on 9/28/19.
//

import Foundation

extension RxNetworkClient {

    private var defaultURLSessionConfiguration: URLSessionConfiguration {

        let urlSessionConfiguration = URLSessionConfiguration.ephemeral
        urlSessionConfiguration.httpMaximumConnectionsPerHost = 50 // what should this be?
        urlSessionConfiguration.timeoutIntervalForRequest = 50
        urlSessionConfiguration.timeoutIntervalForResource = 50
        return urlSessionConfiguration
    }

    internal var defaultURLSession: URLSessionProtocol {

        let urlSession = URLSession(configuration: self.defaultURLSessionConfiguration,
                                    delegate: self, delegateQueue: nil)

        return urlSession
    }
}


extension RxNetworkClient: URLSessionDelegate {

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        // FIXME: Enable Cert Pinning/Verification
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
        return

        /*
         if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate{

         completionHandler(Foundation.URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
         return
         }

         if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust{

         if let serverTrust = challenge.protectionSpace.serverTrust,
         let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0),
         let localCertPath = Bundle.main.path(forResource: "dev_partners", ofType: "cer"){

         let remoteCertificateData = SecCertificateCopyData(certificate)
         let localCertData = try? Data(contentsOf: URL(fileURLWithPath: localCertPath))

         if remoteCertificateData as Data == localCertData! {

         let credential = URLCredential(trust: serverTrust)
         challenge.sender?.use(credential, for: challenge)

         URLCredentialStorage.shared.set(credential, for: challenge.protectionSpace)

         completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, credential)
         return
         }
         }
         }
         completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil )
         */
    }
}

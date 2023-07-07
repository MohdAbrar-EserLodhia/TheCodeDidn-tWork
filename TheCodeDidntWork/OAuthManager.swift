//
//  OAuthManager.swift
//  ThisCodeAlsoWorks
//
//  Created by Eser Lodhia on 06/07/23.
//
//

import Foundation
import OAuthSwift

class OAuthManager {
    private let consumerKey = "????"
    private let consumerSecret = "???"
    private let baseURL = "https://api.audiomack.com/v1"
    private let callbackURL = "???" 

    private var oauth: OAuth1Swift?
    
    init() {
        oauth = OAuth1Swift(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            requestTokenUrl: "\(baseURL)/request_token",
            authorizeUrl: "https://www.audiomack.com/oauth/authenticate",
            accessTokenUrl: "\(baseURL)/access_token"
        )
    }
    
    func authorize(completion: @escaping (String?, String?) -> Void) {
        oauth?.authorize(
            withCallbackURL: URL(string: callbackURL)!,
            completionHandler: { result in
                switch result {
                case .success(let (credential, _, _)):
                    let accessToken = credential.oauthToken
                    let accessTokenSecret = credential.oauthTokenSecret
                    completion(accessToken, accessTokenSecret)
                case .failure(let error):
                    print("Authorization error: \(error.localizedDescription)")
                    completion(nil, nil)
                }
            }
        )
    }

}

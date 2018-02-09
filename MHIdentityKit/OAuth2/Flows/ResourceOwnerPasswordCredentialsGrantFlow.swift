//
//  ResourceOwnerPasswordCredentialsGrantFlow.swift
//  MHIdentityKit
//
//  Created by Milen Halachev on 4/12/17.
//  Copyright © 2017 Milen Halachev. All rights reserved.
//

import Foundation

//https://tools.ietf.org/html/rfc6749#section-1.3.3
//https://tools.ietf.org/html/rfc6749#section-4.3
open class ResourceOwnerPasswordCredentialsGrantFlow: AuthorizationGrantFlow {
    
    open let tokenEndpoint: URL
    open let credentialsProvider: CredentialsProvider
    open let scope: Scope?
    open let clientAuthorizer: RequestAuthorizer
    open let networkClient: NetworkClient

    //MARK: - Init
    
    /**
     Creates an instance of the receiver.

     - parameter tokenEndpoint: The URL of the token endpoint
     - parameter credentialsProvider: A credentials provider used to retrieve username and password in order authenticate the client. This could be your login view controller for example.
     - parameter scope: The scope of the access request.
     - parameter clientAuthorizer: An authorizer used to authorize the authentication request. Usually an instance of HTTPBasicAuthorizer with your clientID and secret.
     - parameter networkClient: A network client used to perform the authentication request.
     
     */
    
    public init(tokenEndpoint: URL, credentialsProvider: CredentialsProvider, scope: Scope?, clientAuthorizer: RequestAuthorizer, networkClient: NetworkClient = _defaultNetworkClient) {
        
        self.tokenEndpoint = tokenEndpoint
        self.credentialsProvider = credentialsProvider
        self.scope = scope
        self.clientAuthorizer = clientAuthorizer
        self.networkClient = networkClient
    }
    
    //MARK: - AuthorizationGrantFlow
    
    open func authenticate(handler: @escaping (AccessTokenResponse?, Error?) -> Void) {
        
        self.credentialsProvider.credentials { (username, password) in
            
            //build the request
            var request = URLRequest(url: self.tokenEndpoint)
            request.httpMethod = "POST"
            request.httpBody = AccessTokenRequest(username: username, password: password, scope: self.scope).dictionary.urlEncodedParametersData
            
            self.authorizeAndPerform(request: request, using: self.clientAuthorizer, and: self.networkClient, handler: { (accessTokenResponse, error) in
                                
                //any validation logic can go here
                handler(accessTokenResponse, error)
            })
        }
    }
}

extension ResourceOwnerPasswordCredentialsGrantFlow {
    
    /**
     Creates an instance of the receiver.
     
     - parameter tokenEndpoint: The URL of the token endpoint
     - parameter credentialsProvider: A credentials provider used to retrieve username and password in order authenticate the client. This could be your login view controller for example.
     - parameter scope: The scope of the access request.
     - parameter clientID: The client id used to autheorize the authentication request.
     - parameter secret: The secret used to autheorize the authentication request.
     - parameter networkClient: A network client used to perform the authentication request.
     
     */
    
    public convenience init(tokenEndpoint: URL, credentialsProvider: CredentialsProvider, scope: Scope?, clientID: String, secret: String, networkClient: NetworkClient = _defaultNetworkClient) {
        
        let clientAuthorizer = HTTPBasicAuthorizer(clientID: clientID, secret: secret)
        
        self.init(tokenEndpoint: tokenEndpoint, credentialsProvider: credentialsProvider, scope: scope, clientAuthorizer: clientAuthorizer, networkClient: networkClient)
    }
    
    /**
     Creates an instance of the receiver.
     
     - parameter tokenEndpoint: The URL of the token endpoint
     - parameter username: The username used for authentication.
     - parameter password: The password used for authentication.
     - parameter scope: The scope of the access request.
     - parameter clientID: The client id used to autheorize the authentication request.
     - parameter secret: The secret used to autheorize the authentication request.
     - parameter networkClient: A network client used to perform the authentication request.
     
     - note: It is highly recommended to implement your own CredentialsProvider and use it instead of providing username and password directly. This way you could implement a loginc screen as a CredentialsProvider and allow the user to enter their username and password when needed.
     */
    
    public convenience init(tokenEndpoint: URL, username: String, password: String, scope: Scope?, clientID: String, secret: String, networkClient: NetworkClient = _defaultNetworkClient) {
        
        let credentialsProvider = DefaultCredentialsProvider(username: username, password: password)
        let clientAuthorizer = HTTPBasicAuthorizer(clientID: clientID, secret: secret)
        
        self.init(tokenEndpoint: tokenEndpoint, credentialsProvider: credentialsProvider, scope: scope, clientAuthorizer: clientAuthorizer, networkClient: networkClient)
    }
    
    /**
     Creates an instance of the receiver.
     
     - parameter tokenEndpoint: The URL of the token endpoint
     - parameter username: The username used for authentication.
     - parameter password: The password used for authentication.
     - parameter scope: The scope of the access request.
     - parameter clientAuthorizer: An authorizer used to authorize the authentication request. Usually an instance of HTTPBasicAuthorizer with your clientID and secret.
     - parameter networkClient: A network client used to perform the authentication request.
     
     - note: It is highly recommended to implement your own CredentialsProvider and use it instead of providing username and password directly. This way you could implement a loginc screen as a CredentialsProvider and allow the user to enter their username and password when needed.
     */
    
    public convenience init(tokenEndpoint: URL, username: String, password: String, scope: Scope?, clientAuthorizer: RequestAuthorizer, networkClient: NetworkClient = _defaultNetworkClient) {
        
        let credentialsProvider = DefaultCredentialsProvider(username: username, password: password)
        
        self.init(tokenEndpoint: tokenEndpoint, credentialsProvider: credentialsProvider, scope: scope, clientAuthorizer: clientAuthorizer, networkClient: networkClient)
    }
}


//MARK: - Models

extension ResourceOwnerPasswordCredentialsGrantFlow {
    
    //https://tools.ietf.org/html/rfc6749#section-4.3.2
    public struct AccessTokenRequest {
        
        public let grantType: GrantType = .password
        public var username: String
        public var password: String
        public var scope: Scope?
        
        public init(username: String, password: String, scope: Scope? = nil) {
            
            self.username = username
            self.password = password
            self.scope = scope
        }
        
        public var dictionary: [String: Any] {
            
            var dictionary = [String: Any]()
            dictionary["grant_type"] = self.grantType.rawValue
            dictionary["username"] = self.username
            dictionary["password"] = self.password
            dictionary["scope"] = self.scope?.value
            
            return dictionary
        }
    }
    
    
}

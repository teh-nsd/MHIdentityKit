//
//  DefaultNetoworkClient.swift
//  MHIdentityKit
//
//  Created by Milen Halachev on 5/26/17.
//  Copyright © 2017 Milen Halachev. All rights reserved.
//

import Foundation

///A default implementation of a NetworkClient, used internally
class DefaultNetoworkClient: NetworkClient {
    
    func perform(request: URLRequest, handler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        let application = UIApplication.shared
        var id = UIBackgroundTaskInvalid
        id = application.beginBackgroundTask(withName: "MHIdentityKit.DefaultNetoworkClient.\(#function).backgroundTask") {
            
            let description = NSLocalizedString("Unable to complete network request", comment: "The description of the network error produced when the background time has expired")
            let reason = NSLocalizedString("Backgorund time has expired.", comment: "The reason of the network error produced when the background time has expired")
            let error = MHIdentityKitError.general(description: description, reason: reason)
            
            handler(nil, nil, error)
            application.endBackgroundTask(id)
            id = UIBackgroundTaskInvalid
        }
        
        let ssions = URLSession(configuration: .ephemeral)
        let task = ssions.dataTask(with: request) { (data, response, error) in
            
            handler(data, response, error)
            application.endBackgroundTask(id)
            id = UIBackgroundTaskInvalid
        }
        
        task.resume()
    }
}
//
//  RedditClient.swift
//  uva
//
//  Created by Andrew Carter on 3/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

enum RedditClientError: ErrorType {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
}

enum RedditClientResult<T> {
    case Success(T)
    case Failure(ErrorType)
}

struct RedditClient {
    let session: NSURLSession
    let host = "api.reddit.com"
    
    init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["Accept": "application/json"]
        session = NSURLSession(configuration: configuration)
    }
    
    func getListings(subreddit: String, after: String? = nil, count: Int? = nil, completionHandler: (RedditClientResult<Listing>) -> Void) throws -> NSURLSessionTask {
        let components = NSURLComponents()
        components.host = host
        components.scheme = "https"
        components.path = "/r/\(subreddit)/hot"
        
        var queryItems = [NSURLQueryItem]()
        if let after = after {
            queryItems.append(NSURLQueryItem(name: "after", value: after))
        }
        if let count = count {
            queryItems.append(NSURLQueryItem(name: "count", value: String(count)))
        }
        components.queryItems = queryItems
        
        guard let url = components.URL else {
            throw RedditClientError.invalidURL
        }
        
        let task = session.dataTaskWithURL(url) { data, response, error in
            self.handleGetListingsResponse(data, response: response, error: error, completionHandler: completionHandler)
        }
        task.resume()
        return task
    }
    
    func handleGetListingsResponse(data: NSData?, response: NSURLResponse?, error: NSError?, completionHandler: (RedditClientResult<Listing>) -> Void) {
        guard let response = response as? NSHTTPURLResponse,
        let data = data else {
            completionHandler(.Failure(RedditClientError.invalidResponse))
            return
        }
        
        let statusCode = response.statusCode
        switch statusCode {
        case 200..<300:
            do {
                let listing = try Listing.fromJSONDictionaryData(data)
                completionHandler(.Success(listing))
            } catch let error {
                completionHandler(.Failure(error))
            }
            
        default:
            completionHandler(.Failure(RedditClientError.httpError(statusCode: statusCode)))
        }
    }
}

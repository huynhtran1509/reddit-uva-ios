//
//  Model.swift
//  uva
//
//  Created by Andrew Carter on 3/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation
import UIKit

typealias JSON = AnyObject
typealias JSONDictionary = [String : JSON]
typealias JSONArray = [JSON]

enum ModelParseError : ErrorType {
    case InvalidJSONArrayContents
    case InvalidJSONDictionaryContents
    case InvalidJSONData
}

protocol Model {
    init(dictionary: JSONDictionary) throws
}

extension Model {
    static func fromJSONArrayData(data: NSData) throws -> [Self] {
        let array: JSONArray
        do {
            guard let object = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? JSONArray else {
                throw ModelParseError.InvalidJSONData
            }
            array = object
        } catch {
            throw ModelParseError.InvalidJSONData
        }
        return try Self.fromJSONArray(array)
    }
    
    static func fromJSONDictionaryData(data: NSData) throws -> Self {
        let dictionary: JSONDictionary
        do {
            guard let object = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? JSONDictionary else {
                throw ModelParseError.InvalidJSONData
            }
            dictionary = object
        } catch {
            throw ModelParseError.InvalidJSONData
        }
        return try Self(dictionary: dictionary)
    }
    
    static func fromJSONArray(array: JSONArray) throws -> [Self] {
        return try array.map { element in
            guard let element = element as? JSONDictionary else {
                throw ModelParseError.InvalidJSONArrayContents
            }
            return try Self(dictionary: element)
        }
    }
}


struct Listing: Model {
    
    let kind: Kind
    let data: Model
    
    init(dictionary: JSONDictionary) throws {
        guard let kindString = dictionary["kind"] as? String,
            let kind = Kind(rawValue: kindString),
            let data = dictionary["data"] as? JSONDictionary else {
                assertionFailure("Failed to init Listing")
                throw ModelParseError.InvalidJSONDictionaryContents
        }
        
        self.kind = kind
        
        switch self.kind {
            
        case .Listing:
            self.data = try ListingData(dictionary: data)
            
        case .Comment:
            self.data = try CommentData(dictionary: data)
            
        case .Account:
            self.data = try AccountData(dictionary: data)
            
        case .Link:
            self.data = try LinkData(dictionary: data)
            
        case .Message:
            self.data = try MessageData(dictionary: data)
            
        case.Subreddit:
            self.data = try SubredditData(dictionary: data)
            
        case .Award:
            self.data = try AwardData(dictionary: data)
            
        case .More:
            self.data = try MoreData(dictionary: data)
            
        case .PromoCampaign:
            self.data = try PromoCampaignData(dictionary: data)
        }
    }
}

struct ListingData: Model {
    let modhash: String?
    let children: [Listing]?
    let after: String?
    let before: String?
    
    init(dictionary: JSONDictionary) throws {
        self.modhash = dictionary["modhash"] as? String
        self.after = dictionary["after"] as? String
        self.before = dictionary["before"] as? String
        
        if let children = dictionary["children"] as? JSONArray {
            do {
                try self.children = Listing.fromJSONArray(children)
            } catch {
                self.children = nil
            }
        } else {
            self.children = nil
        }
    }
}

struct ArticleData: Model {
    init(dictionary: JSONDictionary) throws {
        
    }
}

struct CommentData: Model {
    
    let body: String
    let author: String
    let bodyHTML: String
    let replies: Listing?
    let score: Int
    let ups: Int
    let downs: Int
    
    init(dictionary: JSONDictionary) throws {
        self.body = dictionary["body"] as? String ?? ""
        self.author = dictionary["author"] as? String ?? ""
        self.bodyHTML = dictionary["body_html"] as? String ?? ""
        self.ups = dictionary["ups"] as? Int ?? 0
        self.downs = dictionary["downs"] as? Int ?? 0
        self.score = dictionary["score"] as? Int ?? 0
        
        if let replies = dictionary["replies"] as? JSONDictionary {
            self.replies = try Listing(dictionary: replies)
        } else {
            self.replies = nil
        }
    }
}

struct AccountData: Model {
    init(dictionary: JSONDictionary) throws {
        
    }
}

struct MoreData: Model {
    init(dictionary: JSONDictionary) throws {
        
    }
}

struct LinkData: Model {
    
    let title: String
    let subreddit: String
    let id: String
    let thumbnail: String
    let url: String
    let permalink: String
    let author: String
    let ups: Int
    let downs: Int
    let score: Int
    let isSelf: Bool
    let numComments: Int
    
    init(dictionary: JSONDictionary) throws {
        self.title = dictionary["title"] as? String ?? ""
        self.subreddit = dictionary["subreddit"] as? String ?? ""
        self.id = dictionary["id"] as? String ?? ""
        self.thumbnail = dictionary["thumbnail"] as? String ?? ""
        self.url = dictionary["url"] as? String ?? ""
        self.permalink = dictionary["permalink"] as? String ?? ""
        self.author = dictionary["author"] as? String ?? ""
        self.ups = dictionary["ups"] as? Int ?? 0
        self.downs = dictionary["downs"] as? Int ?? 0
        self.isSelf = dictionary["is_self"] as? Bool ?? false
        self.score = dictionary["score"] as? Int ?? 0
        self.numComments = dictionary["num_comments"] as? Int ?? 0
    }
}

struct MessageData: Model {
    init(dictionary: JSONDictionary) throws {
        
    }
}

struct SubredditData: Model {
    init(dictionary: JSONDictionary) throws {
        
    }
}

struct PromoCampaignData: Model {
    init(dictionary: JSONDictionary) throws {
        
    }
}

struct AwardData: Model {
    init(dictionary: JSONDictionary) throws {
        
    }
}

enum Kind: String {
    case More = "more"
    case Listing = "Listing"
    case Comment = "t1"
    case Account = "t2"
    case Link = "t3"
    case Message = "t4"
    case Subreddit = "t5"
    case Award = "t6"
    case PromoCampaign = "t8"
}

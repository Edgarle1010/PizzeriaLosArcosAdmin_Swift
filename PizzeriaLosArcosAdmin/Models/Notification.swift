//
//  Notification.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 25/03/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import SwiftUI

public class Notification: Codable {
    var folio: String?
    var imageURL: String?
    var title: String
    var description: String?
    var options: String?
    var userToken: String
    var viewed: Bool
    
    init(folio: String?, imageURL: String?, title: String, description: String?, options: String?, userToken: String, viewed: Bool) {
        self.folio = folio
        self.imageURL = imageURL
        self.title = title
        self.description = description
        self.options = options
        self.userToken = userToken
        self.viewed = viewed
    }
    
    enum CodingKeys: String, CodingKey {
        case folio
        case imageURL
        case title
        case description
        case options
        case userToken
        case viewed
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        folio = try values.decodeIfPresent(String.self, forKey: .folio)
        imageURL = try values.decodeIfPresent(String.self, forKey: .imageURL)
        title = try values.decodeIfPresent(String.self, forKey: .title)!
        description = try values.decodeIfPresent(String.self, forKey: .description)
        options = try values.decodeIfPresent(String.self, forKey: .options)
        userToken = try values.decodeIfPresent(String.self, forKey: .userToken)!
        viewed = try values.decodeIfPresent(Bool.self, forKey: .viewed)!
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(folio, forKey: .folio)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(options, forKey: .options)
        try container.encodeIfPresent(userToken, forKey: .userToken)
        try container.encodeIfPresent(viewed, forKey: .viewed)
    }
}

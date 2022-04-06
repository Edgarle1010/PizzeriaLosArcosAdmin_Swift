//
//  Item.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 20/01/22.
//

import Foundation
import FirebaseFirestoreSwift
import RealmSwift

public class Item: Object, Codable {
    @Persisted var id: String
    @Persisted var title: String
    @Persisted var isComplete: Bool
    @Persisted var extraIngredientList = List<ExtraIngredient>()
    @Persisted var size: String
    @Persisted var amount: Int
    @Persisted var comments: String?
    @Persisted var price: Double
    
    override init() {
            super.init()
    }
    
    init(id: String, title: String, isComplete: Bool, extraIngredientList: List<ExtraIngredient>, size: String, amount: Int, comments: String?, price: Double) {
        self.id = id
        self.title = title
        self.isComplete = isComplete
        self.extraIngredientList = extraIngredientList
        self.size = size
        self.amount = amount
        self.comments = comments
        self.price = price
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case isComplete
        case extraIngredientList
        case size
        case amount
        case comments
        case price
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decodeIfPresent(String.self, forKey: .id)!
        title = try values.decodeIfPresent(String.self, forKey: .title)!
        isComplete = try values.decodeIfPresent(Bool.self, forKey: .isComplete)!
        extraIngredientList = try values.decodeIfPresent(List<ExtraIngredient>.self, forKey: .extraIngredientList)!
        size = try values.decodeIfPresent(String.self, forKey: .size)!
        amount = try values.decodeIfPresent(Int.self, forKey: .amount)!
        comments = try values.decodeIfPresent(String.self, forKey: .comments)!
        price = try values.decodeIfPresent(Double.self, forKey: .price)!
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(isComplete, forKey: .isComplete)
        try container.encodeIfPresent(extraIngredientList, forKey: .extraIngredientList)
        try container.encodeIfPresent(size, forKey: .size)
        try container.encodeIfPresent(amount, forKey: .amount)
        try container.encodeIfPresent(comments, forKey: .comments)
        try container.encodeIfPresent(price, forKey: .price)
    }
}

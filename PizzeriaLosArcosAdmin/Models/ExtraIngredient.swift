//
//  ExtraIngredient.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 17/01/22.
//

import Foundation
import RealmSwift
import FirebaseFirestoreSwift

public class ExtraIngredient: Object, Codable {
    @Persisted var id: String
    @Persisted var title: String
    @Persisted var food: String
    @Persisted var bPrice: Int
    @Persisted var mPrice: Int?
    @Persisted var sPrice: Int?
    
    override init() {
            super.init()
    }
    
    init(id: String, title: String, food: String, bPrice: Int, mPrice: Int, sPrice: Int) {
        self.id = id
        self.title = title
        self.food = food
        self.bPrice = bPrice
        self.mPrice = mPrice
        self.sPrice = sPrice
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case food
        case bPrice
        case mPrice
        case sPrice
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decodeIfPresent(String.self, forKey: .id)!
        title = try values.decodeIfPresent(String.self, forKey: .title)!
        food = try values.decodeIfPresent(String.self, forKey: .food)!
        bPrice = try values.decodeIfPresent(Int.self, forKey: .bPrice)!
        mPrice = try values.decodeIfPresent(Int.self, forKey: .mPrice)
        sPrice = try values.decodeIfPresent(Int.self, forKey: .sPrice)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(food, forKey: .food)
        try container.encodeIfPresent(bPrice, forKey: .bPrice)
        try container.encodeIfPresent(mPrice, forKey: .mPrice)
        try container.encodeIfPresent(sPrice, forKey: .sPrice)
    }
    
    func getPrice(_ size: Int) -> Int {
        var price: Int = 0
        if size == 0 {
            price = bPrice
        } else if size == 1 {
            if let mPrice = mPrice {
                price = mPrice
            } else {
                price = bPrice
            }
        } else {
            if let sPrice = sPrice {
                price = sPrice
            } else {
                price = bPrice
            }
        }
        
        return price
    }
    
}

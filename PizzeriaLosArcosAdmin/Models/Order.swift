//
//  Order.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 15/03/22.
//

import Foundation
import FirebaseFirestoreSwift
import RealmSwift

public class Order: Codable {
    var folio: String
    var client: String
    var clientName: String
    var complete: Bool
    var status: String
    var dateRequest: Double
    var dateProcessed: Double?
    var dateFinished: Double?
    var dateDelivered: Double?
    var location: String
    var totalPrice: Double
    var items: Int
    var itemList = List<Item>()
    
    init(folio: String, client: String, clientName: String, complete: Bool, status: String, dateRequest: Double, dateProcessed: Double?, dateFinished: Double?, dateDelivered: Double?, location: String, totalPrice: Double, items: Int, itemList: List<Item>) {
        self.folio = folio
        self.client = client
        self.clientName = clientName
        self.complete = complete
        self.status = status
        self.dateRequest = dateRequest
        self.dateProcessed = dateProcessed
        self.dateFinished = dateFinished
        self.dateDelivered = dateDelivered
        self.location = location
        self.totalPrice = totalPrice
        self.items = items
        self.itemList = itemList
    }
    
    enum CodingKeys: String, CodingKey {
        case folio
        case client
        case clientName
        case complete
        case status
        case dateRequest
        case dateProcessed
        case dateFinished
        case dateDelivered
        case location
        case totalPrice
        case items
        case itemList
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        folio = try values.decodeIfPresent(String.self, forKey: .folio)!
        client = try values.decodeIfPresent(String.self, forKey: .client)!
        clientName = try values.decodeIfPresent(String.self, forKey: .clientName)!
        complete = try values.decodeIfPresent(Bool.self, forKey: .complete)!
        status = try values.decodeIfPresent(String.self, forKey: .status)!
        dateRequest = try values.decodeIfPresent(Double.self, forKey: .dateRequest)!
        dateProcessed = try values.decodeIfPresent(Double.self, forKey: .dateProcessed)
        dateFinished = try values.decodeIfPresent(Double.self, forKey: .dateFinished)
        dateDelivered = try values.decodeIfPresent(Double.self, forKey: .dateDelivered)
        location = try values.decodeIfPresent(String.self, forKey: .location)!
        totalPrice = try values.decodeIfPresent(Double.self, forKey: .totalPrice)!
        items = try values.decodeIfPresent(Int.self, forKey: .items)!
        itemList = try values.decodeIfPresent(List<Item>.self, forKey: .itemList)!
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(folio, forKey: .folio)
        try container.encodeIfPresent(client, forKey: .client)
        try container.encodeIfPresent(clientName, forKey: .clientName)
        try container.encodeIfPresent(complete, forKey: .complete)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(dateRequest, forKey: .dateRequest)
        try container.encodeIfPresent(dateProcessed, forKey: .dateProcessed)
        try container.encodeIfPresent(dateFinished, forKey: .dateFinished)
        try container.encodeIfPresent(dateDelivered, forKey: .dateDelivered)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(totalPrice, forKey: .totalPrice)
        try container.encodeIfPresent(items, forKey: .items)
        try container.encodeIfPresent(itemList, forKey: .itemList)
    }
    
    func getStatus(_ status: String) -> Double {
        if status == "Pedido" {
            return 0.05
        } else if status == "En proceso" {
            return 0.35
        } else if status == "Listo" {
            return 0.65
        } else {
            return 1.0
        }
    }
    
}

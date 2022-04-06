//
//  Food.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 13/01/22.
//

import Foundation

public class Food: Codable {
    let id: String
    let title: String
    let description: String?
    let bPrice: Int
    let mPrice: Int?
    let sPrice: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case bPrice
        case mPrice
        case sPrice
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
    
    func getSize(_ size: Int) -> String {
        var sizeText: String?
        var isDrink: Bool
        var isChocolate: Bool
        
        isDrink = title.contains("naranja") || title.contains("Limonada")
        isChocolate = title.contains("Chocolate")
        
        if size == 0 {
            if isDrink {
                sizeText = "Jarra"
            } else if isChocolate {
                sizeText = "Caliente"
            } else {
                sizeText = "Grande"
            }
        } else if size == 1 {
            sizeText = "Mediana"
        } else {
            if isDrink {
                sizeText = "Vaso"
            } else if isChocolate {
                sizeText = "Frío"
            } else {
                sizeText = "Chica"
            }
        }
        
        return sizeText!
    }
}

//
//  Registration.swift
//  HotelManzana
//
//  Created by Друмлевич on 05.02.2019.
//  Copyright © 2019 Alexey Drumlevich. All rights reserved.
//


import Foundation

struct Registration {
    var firstName: String
    var lastName: String
    var emailAddress: String
    
    var checkInDate: Date
    var checkOutDate: Date
    var numberOfAdults: Int
    var numberOfChildren: Int
    
    var roomType: RoomType
    var wifi: Bool
}

struct RoomType: Equatable {
    var id: Int
    var name: String
    var shortName: String
    var price: Int
    
    static var all: [RoomType] {
        return [
            RoomType(id: 1, name: "Two Queens", shortName: "2Q", price: 179),
            RoomType(id: 2, name: "One King", shortName: "K", price: 209),
            RoomType(id: 3, name: "Penthouse Suite", shortName: "PHS", price: 309),
        ]
    }
    
    static func == (left: RoomType, right: RoomType) -> Bool {
        return left.id == right.id
    }
}

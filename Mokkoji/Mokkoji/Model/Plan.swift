//
//  Plan.swift
//  Mokkoji
//
//  Created by 정종원 on 6/10/24.
//

import Foundation

struct Plan: Codable {
    var uuid: UUID
    var order: Int
    var title: String
    var body: String
    var date: Date
    var time: Date
    var mapInfo: [MapInfo]
    var currentLatitude: Double?
    var currentLongitude: Double?
    var participant: [User]?
}

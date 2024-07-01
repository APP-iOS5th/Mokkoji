//
//  Plan.swift
//  Mokkoji
//
//  Created by 정종원 on 6/10/24.
//  Created by 박지혜 on 6/11/24.
//

import Foundation

struct Plan: Codable {
    var uuid: UUID
    var order: Int?
    var title: String
    var body: String
    var date: String
    var time: Date? /// 제거
    var mapTimeInfo: [Date?]
    var detailTextInfo: [String]
    var mapInfo: [MapInfo]
    var participant: [User]?
}

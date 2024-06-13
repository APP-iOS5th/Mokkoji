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
    var date: String? /// 옵셔널 없애기
    var time: Date? /// 제거
    var mapTimeInfo: [Date]? /// 옵셔널 없애기
    var mapInfo: [MapInfo]
    var currentLatitude: Double? /// 제거
    var currentLongitude: Double? /// 제거
    var participant: [User]?
}

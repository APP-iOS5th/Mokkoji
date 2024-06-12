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

// Firestore에 저장할 데이터 형식으로 변환하기 위한 extension
extension Plan {
    var firestoreRepresentation: [String: Any] {
        var representation: [String: Any] = [
            "uuid": uuid.uuidString,
            "order": order,
            "title": title,
            "body": body,
            "date": date,
            "time": time,

        ]
        return representation
    }
}

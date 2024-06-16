//
//  MapInfo.swift
//  Mokkoji
//
//  Created by 정종원 on 6/10/24.
//  Created by 박지혜 on 6/11/24.
//

import Foundation

struct MapInfo: Codable, Hashable {
    var placeId: String
    var roadAddressName: String
    var placeLatitude: String /// y
    var placeLongitude: String /// x
    var placeName: String
    var poiId: String?
}

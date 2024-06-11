//
//  MapInfo.swift
//  Mokkoji
//
//  Created by 박지혜 on 6/11/24.
//

import Foundation

struct MapInfo: Codable {
    var placeId: String
    var roadAddressName: String
    var placeLatitude: String /// y
    var placeLongitude: String /// x
    var placeName: String

}

//
//  User.swift
//  Mokkoji
//
//  Created by 정종원 on 6/10/24.
//  Created by 박지혜 on 6/11/24.
//

import Foundation

struct User: Codable {
    var id: Int64
    var name: String
    var email: String
    var profileImageUrl: URL
    var plan: [Plan]?
    var plan: [Plan]?
    var friendList: [User]?
}

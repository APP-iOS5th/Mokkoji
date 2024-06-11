//
//  User.swift
//  Mokkoji
//
//  Created by 박지혜 on 6/11/24.
//

import Foundation

struct User: Codable {
    var id: Int64
    var name: String
    var email: String
    var profileImageUrl: URL
    var plan: [Plan]?
    var friendList: [User]?
}
//
//  User.swift
//  Mokkoji
//
//  Created by 정종원 on 6/10/24.
//  Created by 박지혜 on 6/11/24.
//

import Foundation

struct User: Codable, Equatable {
    var id: String
    var name: String
    var email: String
    var profileImageUrl: URL
    var plan: [Plan]?
    var sharedPlan: [Plan]?
    var friendList: [User]?
    
    /// Equatable 프로토콜 구현 - 친구 초대 시 중복된 친구 추가를 방지하기 위함
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.email == rhs.email && lhs.profileImageUrl == rhs.profileImageUrl
    }
}

//
//  UserInfo.swift
//  Mokkoji
//
//  Created by 정종원 on 6/10/24.
//

import Foundation

class UserInfo {
    static let shared = UserInfo()

    var user: User?

    private init() {}
}

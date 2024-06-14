//
//  UserInfo.swift
//  Mokkoji
//
//  Created by 정종원 on 6/10/24.
//

import Foundation

class AuthService {
    static let shared = AuthService()

    var user: User?

    private init() {}
}

//
//  User.swift
//  Mokkoji
//
//  Created by 정종원 on 6/10/24.
//  Created by 박지혜 on 6/11/24.
//  

import Foundation
import UIKit

struct User: Codable {
    var id: String
    var name: String
    var email: String
    var profileImageUrl: URL
    var plan: [Plan]?
    var sharedPlan: [Plan]?
    var friendList: [User]?

}

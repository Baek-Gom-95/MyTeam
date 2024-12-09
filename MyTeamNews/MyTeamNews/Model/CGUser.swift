//
//  CGUser.swift
//  MyTeamNews
//
//  Created by Baek on 12/6/24.
//

import Foundation

struct CGUser {
    let name: String
    let username: String
    let email: String
    let profileImageUrl: String
    let description: String
    let linkUrl: String
    let linkTitle: String
    let uid: String
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.linkUrl = dictionary["link_url"] as? String ?? ""
        self.linkTitle = dictionary["link_title"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}

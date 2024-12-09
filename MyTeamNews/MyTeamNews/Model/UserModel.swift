//
//  UserModel.swift
//  MyTeamNews
//
//  Created by Baek on 10/24/24.
//

import FirebaseFirestoreInternal

struct UserModel {
    let id: Int64
    let nickname: String
    let email: String?
    
    var dictionary: [String: Any] {
        return [
            "kakaoId": id,
            "nickname": nickname,
            "email": email ?? "",
            "createdAt": FieldValue.serverTimestamp()
        ]
    }
}

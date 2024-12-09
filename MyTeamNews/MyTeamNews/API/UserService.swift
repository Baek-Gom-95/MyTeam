//
//  UserService.swift
//  MyTeamNews
//
//  Created by Baek on 12/6/24.
//

import Firebase
import FirebaseAuth

let COLLECTION_USERS = Firestore.firestore().collection("users")

struct UserService {
    static func fetchUser() async throws -> CGUser {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FetchError.noCurrentUser
        }
        return try await withCheckedThrowingContinuation { continuation in
            COLLECTION_USERS.document(uid).getDocument { snapshot, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let dictionary = snapshot?.data() {
                    let user = CGUser(dictionary: dictionary)
                    continuation.resume(returning: user)
                } else {
                    continuation.resume(throwing: FetchError.noSnapshotData)
                }
            }
        }
    }
    
    static func fetchUsers() async throws -> [CGUser] {
        return try await withCheckedThrowingContinuation { continuation in
            COLLECTION_USERS.getDocuments { snapshot, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let documents = snapshot?.documents {
                    let users = documents.map({ CGUser(dictionary: $0.data()) })
                    continuation.resume(returning: users)
                } else {
                    continuation.resume(throwing: FetchError.noSnapshotData)
                }
            }
        }
    }
}

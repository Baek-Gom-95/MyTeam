//
//  AuthService.swift
//  MyTeamNews
//
//  Created by Baek on 12/5/24.
//

import Firebase
import FirebaseFirestore
import FirebaseAuth

struct AuthService {
    static func signinUser(withCredential credential: AuthCredential) async throws -> FirebaseAuth.User {
        do {
            let result = try await Auth.auth().signIn(with: credential)
            return result.user
        } catch {
            print("DEBUG: Failed to signinUser\(error.localizedDescription)")
            throw error
        }
    }
    
    static func signinUser(withEmail email: String, password: String) async throws -> FirebaseAuth.User {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return result.user
        } catch {
            print("DEBUG: Failed to signinUser\(error.localizedDescription)")
            throw error
        }
    }
    
    static func registerUser(withEmail email: String, password: String) async throws -> FirebaseAuth.User {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return result.user
        } catch {
            print("DEBUG: Failed to registerUser\(error.localizedDescription)")
            throw error
        }
    }
    
    static func registerUser(withCredential credentials: AuthCredentials) async throws {
        do {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let data: [String: Any] = ["name": credentials.name, "username": credentials.username, "uid": uid, "email": credentials.email]
            try await Firestore.firestore().collection("users").document(uid).setData(data)
        } catch {
            print("DEBUG: AuthService.registerUser(withCredential) failed.")
            throw error
        }
    }
    
    static func fetchEmail() async throws -> String {
        do {
            guard let email = Auth.auth().currentUser?.email else { throw AuthError.fetchEmailFailed }
            return email
        } catch {
            print("DEBUG: AuthService.fetchEmail() failed.")
            throw AuthError.fetchEmailFailed
        }
    }
}

//
//  LoginViewModel.swift
//  MyTeamNews
//
//  Created by Baek on 9/13/24.
//

import Foundation
import KakaoSDKCommon
import KakaoSDKUser
import KakaoSDKAuth
import GoogleSignIn
import Firebase
import FirebaseAuth
import FirebaseFirestore
import RxSwift
import CryptoKit

class LoginViewModel {
    // MARK: - Properties
    
    typealias FirebaseUser = FirebaseAuth.User
    typealias KakaoUser = KakaoSDKUser.User
    
    private var user: FirebaseUser?
    
    let output = PublishSubject<Output>()
    
    enum Output {
        case didFirstSignIn
        case didAlreadySignIn
        case didFailToSignIn(error: Error)
    }
    
    
    // MARK: - KakaoSignIn
    
    func kakaoSignin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            signInWithKakaoTalkApp()
        } else {
            signInWithKakaoWeb()
        }
    }
    
    private func signInWithKakaoTalkApp() {
        UserApi.shared.loginWithKakaoTalk() { [weak self] _, error in
            if let error = error {
                self?.output.onNext(.didFailToSignIn(error: error))
            }
            self?.validateKakaoUserData()
        }
    }
    
    private func signInWithKakaoWeb() {
        UserApi.shared.loginWithKakaoAccount { [weak self] _, error in
            if let error = error {
                self?.output.onNext(.didFailToSignIn(error: error))
            }
            self?.validateKakaoUserData()
        }
    }
    
    private func validateKakaoUserData() {
        UserApi.shared.me { [weak self] kakaoUser, error in
            if let error = error {
                self?.output.onNext(.didFailToSignIn(error: error))
            } else {
                self?.registerKakaoUserToAuth(user: kakaoUser)
            }
        }
    }
    
    private func registerKakaoUserToAuth(user kakaoUser: KakaoUser?) {
        
        Task {
            do {
                
                guard let email = kakaoUser?.kakaoAccount?.email,
                      let password = kakaoUser?.id else {
                    return
                }
                
                let result = try await AuthService.registerUser(withEmail: email, password: String(password))
                
                validateKakaoUserInAuth(user: kakaoUser)
            } catch let error as NSError {
                if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    validateKakaoUserInAuth(user: kakaoUser)
                } else {
                    output.onNext(.didFailToSignIn(error: error))
                }
            }
        }
    }
    
    private func validateKakaoUserInAuth(user: KakaoUser?) {
        Task {
            do {
                guard let email = user?.kakaoAccount?.email,
                      let password = (user?.id) else { return }
                let user = try await AuthService.signinUser(withEmail: email, password: String(password))
                self.user = user
                await didUserAlreadyRegisterInFirestore()
            } catch {
                output.onNext(.didFailToSignIn(error: error))
            }
        }
    }
    
    // MARK: - AppleSignIn
    
    func appleSignin(withTokenId tokenId: String) {
        Task {
            do {
                let nonce = await sha256(await randomNonceString())
                let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenId, rawNonce: nonce)
                let user = try await AuthService.signinUser(withCredential: credential)
                self.user = user
                await didUserAlreadyRegisterInFirestore()
            } catch {
                output.onNext(.didFailToSignIn(error: error))
            }
        }
    }
    
    private func sha256(_ input: String) async -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func randomNonceString(length: Int = 32) async -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    // MARK: - GoogleSignIn
    
    func googleSignin(presentingViewController: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            output.onNext(.didFailToSignIn(error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Client ID not found"])))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
            if let error = error {
                self?.output.onNext(.didFailToSignIn(error: error))
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self?.output.onNext(.didFailToSignIn(error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid user data"])))
                return
            }
            
            Task {
                await self?.handleGoogleSignIn(withTokenId: idToken)
            }
        }
    }
    
    private func handleGoogleSignIn(withTokenId tokenId: String) async {
        // 기존 googleSignin 메서드의 내용
        do {
            let credential = GoogleAuthProvider.credential(
                withIDToken: tokenId,
                accessToken: GIDSignIn.sharedInstance.currentUser?.accessToken.tokenString ?? ""
            )
            
            let user = try await AuthService.signinUser(withCredential: credential)
            self.user = user
            await didUserAlreadyRegisterInFirestore()
        } catch {
            output.onNext(.didFailToSignIn(error: error))
        }
    }
    
    // MARK: - DidUserAlreadyRegisterInFirestore
    
    private func didUserAlreadyRegisterInFirestore() async {
        do {
            guard let user = user else { return }
            let status = try await FirebaseService.isUserAlreadyExisted(user: user)
            output.onNext(status ? .didAlreadySignIn : .didFirstSignIn)
        } catch {
            output.onNext(.didFailToSignIn(error: error))
        }
    }
}

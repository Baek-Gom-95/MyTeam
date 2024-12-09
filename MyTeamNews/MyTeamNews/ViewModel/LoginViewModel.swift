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
                print("에러1")
                self?.output.onNext(.didFailToSignIn(error: error))
            }
            self?.validateKakaoUserData()
        }
    }
    
    private func signInWithKakaoWeb() {
        UserApi.shared.loginWithKakaoAccount { [weak self] _, error in
            if let error = error {
                print("에러2")
                self?.output.onNext(.didFailToSignIn(error: error))
            }
            self?.validateKakaoUserData()
        }
    }
    
    private func validateKakaoUserData() {
        UserApi.shared.me { [weak self] kakaoUser, error in
            if let error = error {
                print("에러3")
                self?.output.onNext(.didFailToSignIn(error: error))
            } else {
                self?.registerKakaoUserToAuth(user: kakaoUser)
            }
        }
    }
    
    private func registerKakaoUserToAuth(user kakaoUser: KakaoUser?) {
        // 먼저 kakaoUser 자체가 nil인지 확인
        print("DEBUG: kakaoUser - \(String(describing: kakaoUser))")
        
        Task {
            do {
                // guard문 이전에 각 값들을 확인
                print("DEBUG: kakaoUser email - \(String(describing: kakaoUser?.kakaoAccount?.email))")
                print("DEBUG: kakaoUser id - \(String(describing: kakaoUser?.id))")
                
                guard let email = kakaoUser?.kakaoAccount?.email,
                      let password = kakaoUser?.id else {
                    print("DEBUG: Guard문에서 실패 - email 또는 id가 nil입니다")
                    return
                }
                
                print("DEBUG: Guard문 통과 - email: \(email), password: \(password)")
                
                let result = try await AuthService.registerUser(withEmail: email, password: String(password))
                
                print("DEBUG: 회원가입 성공")
                validateKakaoUserInAuth(user: kakaoUser)
            } catch let error as NSError {
                if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    print("DEBUG: 이미 존재하는 이메일")
                    validateKakaoUserInAuth(user: kakaoUser)
                } else {
                    print("DEBUG: 기타 에러 발생 - \(error.localizedDescription)")
                    output.onNext(.didFailToSignIn(error: error))
                }
            }
        }
    }
    
    private func validateKakaoUserInAuth(user: KakaoUser?) {
        Task {
            do {
                print("에러5")
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
    
    // MARK: - DidUserAlreadyRegisterInFirestore
    
    private func didUserAlreadyRegisterInFirestore() async {
        do {
            print("에러6")
            guard let user = user else { return }
            let status = try await FirebaseService.isUserAlreadyExisted(user: user)
            output.onNext(status ? .didAlreadySignIn : .didFirstSignIn)
        } catch {
            output.onNext(.didFailToSignIn(error: error))
        }
    }
}

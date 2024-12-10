//
//  ViewController.swift
//  MyTeamNews
//
//  Created by Baek on 9/4/24.
//

import UIKit
import AuthenticationServices
import RxSwift

class LoginViewController: UIViewController {
    // MARK: - Properties
    
    private let loginView = LoginView()
    private lazy var loginViewModel = LoginViewModel()
    private let disposeBag = DisposeBag()
    weak var delegate: AuthenticationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraint()
        kakaoLoginButton()
        appleLoginButton()
        bind()
    }
}

extension LoginViewController {
    
    // SetUp UI
    private func setupUI() {
        self.view.addSubview(loginView)
    }
    
    private func setupConstraint() {
        loginView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loginView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            loginView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            loginView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            loginView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        ])
    }
    
    // SetUp Button
    private func kakaoLoginButton() {
        loginView.kakaoLoginButton.addTarget(self, action: #selector(loginKaKao), for: .touchUpInside)
    }
    
    private func googleLoginButton() {
        
    }
    
    private func appleLoginButton() {
        loginView.appleLoginButton.addTarget(self, action: #selector(loginApple), for: .touchUpInside)
    }
    
    // objc
    @objc private func loginKaKao() {
        loginViewModel.kakaoSignin()
    }
    
    @objc private func loginApple() {
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authrizationController = ASAuthorizationController(authorizationRequests: [request])
        authrizationController.delegate = self
        authrizationController.presentationContextProvider = self
        authrizationController.performRequests()
        
    }
    
    // func
    
    func bind() {
        loginViewModel.output
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .didFirstSignIn:
                    //                        let controller = FirstNameController()
                    //                        self?.navigationController?.pushViewController(controller, animated: true)
                    print("첫로그인")
                case .didAlreadySignIn:
                    Task {
                        do {
                            try await AuthManager.shared.updateUser()
                            self?.dismiss(animated: true, completion: nil)
                        } catch {
                            print("DEBUG: 로그인 할 수 없습니다.")
                        }
                    }
                case .didFailToSignIn(let error):
                    print("DEBUG: Failed sign in user \(error.localizedDescription)")
                }
            }).disposed(by: disposeBag)
    }
}


// MARK: - ASAuthorizationControllerDelegate

extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if case let appleIDCredential as ASAuthorizationAppleIDCredential = authorization.credential {
            guard let appleIDToken = appleIDCredential.identityToken else { return }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { return }
            loginViewModel.appleSignin(withTokenId: idTokenString)
        }
    }
}

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraint()
        kakaoLoginButton()
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
        loginView.kakaoLoginButton.addTarget(self, action: #selector(checkKaKao), for: .touchUpInside)
    }
    
    private func googleLoginButton() {
        
    }
    
    // objc
    @objc private func checkKaKao() {
        loginViewModel.kakaoSignin()
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
                        print("실패")
                    }
                }).disposed(by: disposeBag)
        }
}


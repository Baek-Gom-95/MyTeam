//
//  LoginView.swift
//  MyTeamNews
//
//  Created by Baek on 9/10/24.
//
import UIKit
import Foundation

final class LoginView: UIView {
    
    // - MARK: Properties
    
    private let loginStackView: UIStackView  = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = CGFloat(LoginViewSetEnum.loginViewStackViewSpacing)
        return stackView
    }()
    
    private let myTeamLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.text = LoginViewSetEnum.loginLogoText
        return label
    }()
    
    // - MARK: Login Button Properties
    
    private let loginButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = CGFloat(LoginViewSetEnum.loginButtonSpacing)
        return stackView
    }()
    
    var kakaoLoginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "kakao_login_normal"), for: .normal)
        
        return button
    }()
    
    var googleLoginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "google_login"), for: .normal)
        
        return button
    }()
    
    var appleLoginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "apple_login"), for: .normal)
        
        return button
    }()
    
    // - MARK: Login View Setting
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        self.backgroundColor = .black
        setupUI()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension LoginView {
    
    private func setupUI() {
        self.addSubview(loginStackView)
        
        loginStackView.addArrangedSubview(myTeamLabel)
        loginStackView.addArrangedSubview(loginButtonStackView)
        
        loginButtonStackView.addArrangedSubview(kakaoLoginButton)
        loginButtonStackView.addArrangedSubview(googleLoginButton)
        loginButtonStackView.addArrangedSubview(appleLoginButton)
    }
    
    private func setupConstraint(){
        
        // 버튼 이미지 크기 설정
        setButtonImageSize(kakaoLoginButton, width: 280, height: 70, cornerRadius: 15)
        setButtonImageSize(googleLoginButton, width: 280, height: 70, cornerRadius: 15)
        setButtonImageSize(appleLoginButton, width: 280, height: 70, cornerRadius: 15)
        
        NSLayoutConstraint.activate([
            loginStackView.topAnchor.constraint(equalTo: self.topAnchor),
            loginStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            loginStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            loginStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            loginButtonStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            loginButtonStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
                
        ])
    }
    
    private func setButtonImageSize(_ button: UIButton, width: CGFloat, height: CGFloat, cornerRadius: CGFloat) {
        button.widthAnchor.constraint(equalToConstant: width).isActive = true
        button.heightAnchor.constraint(equalToConstant: height).isActive = true
        button.layer.cornerRadius = cornerRadius
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
    }
}

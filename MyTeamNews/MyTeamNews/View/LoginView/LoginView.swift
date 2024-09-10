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
    
    private let LoginStackView: UIStackView  = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = CGFloat(LoginViewSetEnum.LoginViewStackViewSpacing)
        return stackView
    }()
    
    private let myTeamLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.text = LoginViewSetEnum.LoginLogoText
        return label
    }()
    
    // - MARK: Login View Setting
    
    override init(frame: CGRect) {
        super .init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension LoginView {
    
}

//
//  LoginViewModelDelegate.swift
//  MyTeamNews
//
//  Created by Baek on 10/25/24.
//

import Foundation

protocol LoginViewModelDelegate: AnyObject {
    // AnyObject를 채택하여 class 타입만 delegate가 될 수 있도록 제한
    // 이는 weak 참조를 사용하기 위해 필요합니다
    
    func loginViewModel(_ viewModel: LoginViewModel, didChangeLoginState isLoggedIn: Bool)
    // 로그인 상태가 변경될 때마다 ViewController에 알리는 메서드
    // viewModel 파라미터를 전달하여 여러 ViewModel의 delegate를 구분할 수 있게 함
    
    func loginViewModel(_ viewModel: LoginViewModel, didChangeLoadingState isLoading: Bool)
    // 로딩 상태 변경을 ViewController에 알리는 메서드
    // 로딩 인디케이터 표시/숨김을 위해 사용
    
    func loginViewModel(_ viewModel: LoginViewModel, didReceiveError error: Error)
    // 에러 발생 시 ViewController에 알리는 메서드
    // 에러 메시지 표시를 위해 사용
}

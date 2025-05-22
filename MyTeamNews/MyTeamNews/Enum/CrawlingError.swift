//
//  CrawlingError.swift
//  MyTeamNews
//
//  Created by Baek on 5/21/25.
//

import Foundation

enum CrawlingError: Error {
    case invalidURL
    case encodingError
    case parseError
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다."
        case .encodingError:
            return "인코딩 오류입니다."
        case .parseError:
            return "HTML 파싱 오류입니다."
        }
    }
}

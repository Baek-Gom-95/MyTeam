//
//  NewsCrawler.swift
//  MyTeamNews
//
//  Created by Baek on 5/21/25.
//

import Foundation
import SwiftSoup

class NewsCrawler {
    private let session: URLSession
    private let extrac = ExtractManager()
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        self.session = URLSession(configuration: config)
    }
    
    // 메인 크롤링 함수
    func crawlNewsContent(from url: String) async throws -> NewsData? {
        guard let requestURL = URL(string: url) else {
            throw CrawlingError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        
        // User-Agent 헤더에 특정 값을 설정
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, _) = try await session.data(for: request)
            guard let html = String(data: data, encoding: .utf8) else {
                throw CrawlingError.encodingError
            }
            
            let doc = try SwiftSoup.parse(html)
            
            return NewsData(
                url: url,
                title: try extrac.extractTitle(from: doc),
                content: try extrac.extractContent(from: doc),
                images: try extrac.extractImages(from: doc),
                publishDate: try extrac.extractDate(from: doc)
            )
            
        } catch {
            print("크롤링 오류 - \(url): \(error)")
            return nil
        }
        
    }
    
    
    
}

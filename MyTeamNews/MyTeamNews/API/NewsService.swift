//
//  NewsService.swift
//  MyTeamNews
//
//  Created by Baek on 5/22/25.
//

import Foundation

class NewsService {
    private let crawler = NewsCrawler()
    
    // 네이버 API 결과에서 상세 정보를 크롤링
    func fetchDetailedNews(from apiItems: [NaverNewsItem]) async -> [NewsData] {
        var detailedNews: [NewsData] = []
        
        for item in apiItems {
            // 원문 링크가 있으면 크롤링
            if !item.originalLink.isEmpty {
                do {
                    if let newsData = try await crawler.crawlNewsContent(from: item.originalLink) {
                        detailedNews.append(newsData)
                    }
                } catch {
                    print("크롤링 실패: \(item.originalLink) - \(error)")
                }
                
                // 서버 부하 방지를 위한 딜레이
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1초
            }
        }
        
        return detailedNews
    }
}

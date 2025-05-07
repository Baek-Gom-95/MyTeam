//
//  NaverNewsAPI.swift
//  MyTeamNews
//
//  Created by Baek on 12/10/24.
//

import Foundation

struct NaverNewsAPI {
    private let clientID = "L2q7REj6GnXeEBl_UuqM"
    private let clientSecret = "o5OAAKiWNo"
    private let baseURL = "https://openapi.naver.com/v1/search/news.json"
    
    func fetchNews(query: String) async throws -> [NewsItem] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?query=\(encodedQuery)&display=50") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.addValue(clientID, forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(NewsResponse.self, from: data).items
    }
}

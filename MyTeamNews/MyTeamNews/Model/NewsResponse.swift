//
//  NewsResponse.swift
//  MyTeamNews
//
//  Created by Baek on 12/10/24.
//

import Foundation

struct NewsResponse: Codable {
    let lastBuildDate: String
    let total: Int
    let start: Int
    let display: Int
    let items: [NewsItem]
}

//
//  NewsItem.swift
//  MyTeamNews
//
//  Created by Baek on 12/10/24.
//

import Foundation

struct NewsItem: Codable {
    let title: String
    let originallink: String
    let link: String
    let description: String
    let pubDate: String
}

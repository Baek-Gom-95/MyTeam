//
//  NavigationEvent.swift
//  MyTeamNews
//
//  Created by Baek on 6/2/25.
//

enum NavigationEvent {
    case openNewsDetail(NewsItem)
    case showError(String)
    case requireLogin
    case showTeamSelection
}

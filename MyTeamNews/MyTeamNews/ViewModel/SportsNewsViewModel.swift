//
//  SportsNewsViewModel.swift
//  MyTeamNews
//
//  Created by Baek on 12/10/24.
//

import Foundation
import RxSwift

class SportsNewsViewModel {
    private let newsAPI = NaverNewsAPI()
    private let output = PublishSubject<[NewsItem]>()
    private let disposeBag = DisposeBag()
    
    func fetchSportsNews(team: String) {
        Task {
            do {
                let query = "\(team) 야구"  // 예: "두산 야구"
                let news = try await newsAPI.fetchNews(query: query)
                output.onNext(news)
            } catch {
                // 에러 처리
                print("Error fetching news: \(error)")
            }
        }
    }
    
    // RxSwift를 사용한 바인딩
    func bind(to view: NewsListView) {
        output
            .observe(on: MainScheduler.instance)
            .bind(to: view.newsItems)
            .disposed(by: disposeBag)
    }
}

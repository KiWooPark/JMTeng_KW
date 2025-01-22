//
//  UserLocationViewModel.swift
//  JMTeng
//
//  Created by PKW on 2024/01/19.
//

import Foundation

class UserLocationViewModel {
    weak var coordinator: UserLocationCoordinator?
    
    var recentLocations = [String]()
    var resultLocations = [SearchLocationModel]()
    
    var enterPoint = 0
  
    var isSearch = false
    var currentPage = 1
    var isFetching = false
    var isEmpty = false
    var isFinishSearch = false
    var previousCount = 0
    
    var onSuccess: (() -> Void)?
}

// 검색 관련 메소드
extension UserLocationViewModel {
    
    func fetchSearchLocationData(keyword: String) async throws {
        guard !isFetching else { return }
        
        isFetching = true
        
        defer {
            isFetching = false
        }
        
        let newLocationData = try await LocationAPI.getSearchLocations(request: SearchLocationRequest(query: keyword, page: currentPage)).toDomain
        
        if let lastNewItem = newLocationData.last,
            self.resultLocations.contains(where: { $0.placeName == lastNewItem.placeName }) {
            self.previousCount = self.resultLocations.count
            self.isEmpty = true
            return
        } else {
            self.previousCount = self.resultLocations.count
            self.resultLocations.append(contentsOf: newLocationData)
            self.currentPage += 1
        }
    }
}

// 최근 검색어 관련 메소드
extension UserLocationViewModel {
    
    func fetchRecentLocations() -> Bool {
        recentLocations = UserDefaultManager.getRecentSearchKeywords(type: UserDefaultManager.Keys.recenLocationKeywords)
        
        return recentLocations.isEmpty
    }
    
    func fetchRecentLocations1() {
        recentLocations = UserDefaultManager.getRecentSearchKeywords(type: UserDefaultManager.Keys.recenLocationKeywords)
    }

    func saveRecentLocation(keyword: String) {
        UserDefaultManager.saveSearchKeyword(keyword, type: UserDefaultManager.Keys.recenLocationKeywords)
    }
    
    func deleteRecentLocation(_ row: Int) {
        let keywoard = recentLocations[row]
        recentLocations.remove(at: row)
        UserDefaultManager.deleteSearchKeyword(keywoard, type: UserDefaultManager.Keys.recenLocationKeywords)
        onSuccess?()
    }
    
    func deleteAllRecentLocation() {
        recentLocations.removeAll()
        UserDefaultManager.removeAllSearchKeywords(type: UserDefaultManager.Keys.recenLocationKeywords)
        onSuccess?()
    }
}

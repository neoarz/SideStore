//
//  PageInfoManager.swift
//  AltStore
//
//  Created by Magesh K on 11/01/25.
//  Copyright © 2025 SideStore. All rights reserved.
//

// This is a utility class
class PageInfoManager {
    static var shared = PageInfoManager()
    private var pageInfoMap: [Int: NavigationEvent] = [:]
    
    private init() {}
    
    func setPageInfo(for key: Int, value: NavigationEvent?) {
        pageInfoMap[key] = value
    }
    
    func getPageInfo(for key: Int) -> NavigationEvent? {
       return pageInfoMap[key]
    }

    func popPageInfo(for key: Int) -> NavigationEvent? {
        return pageInfoMap.removeValue(forKey: key)
    }

    func clearAll() {
        pageInfoMap.removeAll()
    }
}

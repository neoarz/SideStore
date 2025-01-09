//
//  PaginationViewModel.swift
//  AltStore
//
//  Created by Magesh K on 09/01/25.
//  Copyright © 2025 SideStore. All rights reserved.
//

import Foundation

class PaginationDataHolder: ObservableObject {
    
    public static let MAX_ROWS_PER_PAGE: UInt = 3

    private static var instances: [String:PaginationDataHolder] = [:]
    
    public static func instance(_ widgetID: String) -> PaginationDataHolder {
        let instance = PaginationDataHolder(widgetID)
        Self.instances[widgetID] = instance
        return instance
    }

    public static func holder(for widgetID: String) -> PaginationDataHolder? {
        return Self.instances[widgetID]
    }
    
    private lazy var serializationQ = {
        DispatchQueue(label: widgetID)
    }()

    public let widgetID: String
    private var currentPageindex: UInt = 0
    
    private init(_ widgetID: String){
        self.widgetID = widgetID
    }
    
    deinit {
        Self.instances.removeValue(forKey: widgetID)
    }
    
    public func updateDirection(_ direction: Direction) {
        switch(direction){
        case .up:
            let pageIndex = Int(currentPageindex)
            currentPageindex = UInt(max(0, pageIndex-1))
        case .down:
            // upper-bounds is checked when computing targetPageIndex in getUpdatedData
            currentPageindex+=1
        }
    }
    
    public func getUpdatedData(entries: [AppSnapshot]) -> [AppSnapshot] {
        let count = UInt(entries.count)
        
        if(count == 0) { return entries }
        
        let availablePages = UInt(ceil(Double(entries.count) / Double(Self.MAX_ROWS_PER_PAGE)))
        let targetPageIndex: UInt = currentPageindex < availablePages ? currentPageindex : availablePages-1

        // do blocking update
        serializationQ.sync {
            self.currentPageindex = targetPageIndex     // preserve it
        }
        
        let startIndex = targetPageIndex * Self.MAX_ROWS_PER_PAGE
        let estimatedEndIndex = startIndex + (Self.MAX_ROWS_PER_PAGE-1)
        let endIndex: UInt = min(count-1, estimatedEndIndex)
        let currentPageEntries = entries[Int(startIndex) ... Int(endIndex)]
        return Array(currentPageEntries)
    }
}

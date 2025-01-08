//
//  PaginationViewModel.swift
//  AltStore
//
//  Created by Magesh K on 09/01/25.
//  Copyright © 2025 SideStore. All rights reserved.
//

import Foundation
import Combine

class PaginationViewModel: ObservableObject {
    
    private static var instances: [String:PaginationViewModel] = [:]
    
    public static let MAX_ROWS_PER_PAGE = 3
    
    @Published public var sliding_window: [AppSnapshot] = []
    @Published public var refreshed: Bool = false
    
    private init(){}
    
    private var _widgetID: String?
    public lazy var widgetID: String = {
        return _widgetID!
    }()
    
    public static func getNewInstance(_ widgetID: String) -> PaginationViewModel {
        let instance = PaginationViewModel()
        PaginationViewModel.instances[widgetID] = instance
        instance._widgetID = widgetID
        return instance
    }

    public static func instance(_ widgetID: String) -> PaginationViewModel? {
        return PaginationViewModel.instances[widgetID]
    }
    
    public private(set) var backup_entries: [AppSnapshot] = []
    
    private var r_queue: [AppSnapshot] = []
    private var l_queue: [AppSnapshot] = []
    
    private var lastIndex: Int { r_queue.count - 1 }

    public func setEntries(_ entries: [AppSnapshot]) {
        r_queue = entries
        backup_entries = entries
    }
    
    public func handlePagination(_ direction: Direction) {
        
        var sliding_window = Array(sliding_window)
        var l_queue = Array(l_queue)
        var r_queue = Array(r_queue)
        
        // If entries is empty, do nothing
        guard !backup_entries.isEmpty else {
            sliding_window.removeAll()
            return
        }
        
        switch direction {
        case .up:
            // move window contents to left-q since we are moving right side
            if !sliding_window.isEmpty {
                // take the window as-is and put it to right of l_queue
                l_queue.append(contentsOf: sliding_window)
            }
            
            // clear the window
            sliding_window.removeAll()
        
            let size = min(r_queue.count, Self.MAX_ROWS_PER_PAGE)
            for _ in 0..<size {
                if !r_queue.isEmpty {
                    sliding_window.append(r_queue.removeFirst())
                }
            }
            
        case .down:
            // move window contents to right-q since we are moving left side
            if !sliding_window.isEmpty {
                // take the window as-is and put it to left of r_queue
                r_queue.insert(contentsOf: sliding_window, at: 0)
            }
            
            // clear the window
            sliding_window.removeAll()
            
            let size = min(l_queue.count, Self.MAX_ROWS_PER_PAGE)
            for _ in 0..<size {
                sliding_window.insert(l_queue.removeLast(), at: 0)
            }
        }
        
        if !sliding_window.isEmpty {
            // commit
            self.sliding_window = sliding_window
            self.l_queue = l_queue
            self.r_queue = r_queue
            self.refreshed = true
        }
    }
}

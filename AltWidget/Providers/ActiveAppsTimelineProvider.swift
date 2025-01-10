//
//  ActiveAppsTimelineProvider.swift
//  AltStore
//
//  Created by Magesh K on 10/01/25.
//  Copyright © 2025 SideStore. All rights reserved.
//

import WidgetKit

protocol Navigation{
    var direction: Direction? { get }
}

@available(iOS 17, *)
class ActiveAppsTimelineProvider: AppsTimelineProviderBase<Navigation> {
    
    let uuid = UUID().uuidString
    
    private let dataHolder: PaginationDataHolder
    private let widgetID: String
    
    init(kind: String){
        print("Executing ActiveAppsTimelineProvider.init() for instance \(uuid)")
        
        let itemsPerPage = ActiveAppsWidget.Constants.MAX_ROWS_PER_PAGE
        self.dataHolder = PaginationDataHolder(itemsPerPage: itemsPerPage)
        self.widgetID = kind
    }
    
    override func getUpdatedData(_ apps: [AppSnapshot], _ context: Navigation?) -> [AppSnapshot] {
        guard let context = context else { return apps }
        
        var apps = apps
        
//        #if DEBUG
//        apps = getSimulatedData(apps: apps)
//        #endif
        
        if let direction = context.direction{
            // get paged data if available
            switch (direction){
                case Direction.up:
                    apps = dataHolder.prevPage(inItems: apps, whenUnavailable: .current)!
                case Direction.down:
                    apps = dataHolder.nextPage(inItems: apps, whenUnavailable: .current)!
            }
        }else{
            // retain what ever page we were on as-is
            apps = dataHolder.currentPage(inItems: apps)
        }
                
        return apps
    }
}

@available(iOS 17, *)
extension ActiveAppsTimelineProvider: AppIntentTimelineProvider {
    
    struct IntentData: Navigation{
        let direction: Direction?
    }

    typealias Intent = WidgetUpdateIntent

    func snapshot(for intent: Intent, in context: Context) async -> AppsEntry {
        let data = IntentData(direction: intent.getDirection(widgetID))
        
        let bundleIDs = await super.fetchActiveAppBundleIDs()
        
        let snapshot = await self.snapshot(for: bundleIDs, in: data)
        
        return snapshot
    }
    
    func timeline(for intent: Intent, in context: Context) async -> Timeline<AppsEntry> {
        let data = IntentData(direction: intent.getDirection(widgetID))
 
        let bundleIDs = await self.fetchActiveAppBundleIDs()
        
        let timeline = await self.timeline(for: bundleIDs, in: data)

        return timeline
    }
}

//
//  ActiveAppsTimelineProvider.swift
//  AltStore
//
//  Created by Magesh K on 10/01/25.
//  Copyright © 2025 SideStore. All rights reserved.
//

import WidgetKit

protocol WidgetInfo{
    var ID: Int? { get }
}

@available(iOS 17, *)
class ActiveAppsTimelineProvider<T:  WidgetInfo>: AppsTimelineProviderBase<WidgetInfo> {
    public struct WidgetData: WidgetInfo {
        let ID: Int?
    }

    private let dataHolder = PaginationDataHolder(
        itemsPerPage: ActiveAppsWidget.Constants.MAX_ROWS_PER_PAGE
    )
    
    deinit{
        // if this provider goes out of scope, clear all entries
        PageInfoManager.shared.clearAll()
    }
    
    override func getUpdatedData(_ apps: [AppSnapshot], _ context: WidgetInfo?) -> [AppSnapshot] {
        var apps = apps
        
        #if targetEnvironment(simulator)
        apps = getSimulatedData(apps: apps)
        #endif
        
        var currentPageApps = dataHolder.currentPage(inItems: apps)
        if  let widgetInfo = context,
            let widgetID = widgetInfo.ID {
            
            var navEvent: NavigationEvent? = PageInfoManager.shared.getPageInfo(for: widgetID)
            if  let event = navEvent,
                let direction = event.direction
            {
                // process navigation request only if event wasn't consumed yet
                if !event.consumed {
                    switch (direction){
                        case Direction.up:
                            currentPageApps = dataHolder.prevPage(inItems: apps, whenUnavailable: .current)!
                        case Direction.down:
                            currentPageApps = dataHolder.nextPage(inItems: apps, whenUnavailable: .current)!
                    }
                    // mark the event as consumed
                    // this prevents duplicate getUpdatedData() requests for same navigation event
                    navEvent!.consumed = true
                }
            }
            PageInfoManager.shared.setPageInfo(for: widgetID, value: navEvent)
        }
                
        return currentPageApps
    }
}

/// TimelineProvider for WidgetAppIntentConfiguration widget type
@available(iOS 17, *)
extension ActiveAppsTimelineProvider: AppIntentTimelineProvider {
    
    typealias Intent = WidgetUpdateIntent

    func snapshot(for intent: Intent, in context: Context) async -> AppsEntry<WidgetInfo> {
        // system retains the previously configured ID value and posts the same here
        let widgetData = WidgetData(ID: intent.ID)
        
        let bundleIDs = await super.fetchActiveAppBundleIDs()
        let snapshot = await self.snapshot(for: bundleIDs, in: widgetData)
        
        return snapshot
    }
    
    func timeline(for intent: Intent, in context: Context) async -> Timeline<AppsEntry<WidgetInfo>> {
        // system retains the previously configured ID value and posts the same here
        let widgetData = WidgetData(ID: intent.ID)

        let bundleIDs = await self.fetchActiveAppBundleIDs()
        let timeline = await self.timeline(for: bundleIDs, in: widgetData)

        return timeline
    }
}

//
//  PaginationIntent.swift
//  AltStore
//
//  Created by Magesh K on 08/01/25.
//  Copyright © 2025 SideStore. All rights reserved.
//

import AppIntents
import Intents
import WidgetKit

public enum Direction: String, Sendable{
    case up
    case down
}

public struct NavigationEvent {
    let direction: Direction?
    var consumed: Bool = false
}

@available(iOS 17, *)
class PaginationIntent: AppIntent, @unchecked Sendable {
    
    private let COMMON_WIDGET_ID = 1
    
    static var title: LocalizedStringResource = "Page Navigation Intent"
    static var isDiscoverable: Bool = false
    
    @Parameter(title: "widgetID")
    var widgetID: Int

    @Parameter(title: "Direction")
    var direction: String

    required init(){}
    
    init(_ widgetID: Int?, _ direction: Direction){
        // if id was not passed in, then we assume the widget isn't customized yet
        // hence we use the common ID, if this is not present in registry of PageInfoManager
        // then it will return nil, triggering to show first page in the provider
        self.widgetID = widgetID ?? COMMON_WIDGET_ID
        self.direction = direction.rawValue
    }
    
    func perform() async throws -> some IntentResult {
        let widgetIdString = String(widgetID)
        DispatchQueue(label: widgetIdString).sync {
            let navigationEvent = NavigationEvent(direction: Direction(rawValue: direction))
            PageInfoManager.shared.setPageInfo(for: widgetID, value: navigationEvent)
            WidgetCenter.shared.reloadTimelines(ofKind: widgetIdString)
        }
        return .result()
    }
}

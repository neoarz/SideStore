//
//  PaginationIntent.swift
//  AltStore
//
//  Created by Magesh K on 08/01/25.
//  Copyright © 2025 SideStore. All rights reserved.
//

import AppIntents
import WidgetKit

public enum Direction: String, Sendable{
    case up = "up"
    case down = "down"
}

@available(iOS 17, *)
class PaginationIntent: AppIntent, @unchecked Sendable {
    static var title: LocalizedStringResource { "Scroll up or down in Active Apps Widget" }
    static var isDiscoverable: Bool { false }

    @Parameter(title: "Direction")
    var direction: String

    @Parameter(title: "Widget Identifier")
    var widgetID: String
        
    private lazy var widgetHolderQ = {
        DispatchQueue(label: widgetID)
    }()
    
    required init(){}
    
    init(_ direction: Direction, _ widgetID: String){
        self.direction = direction.rawValue
        self.widgetID = widgetID
    }

    func perform() async throws -> some IntentResult {
        guard let direction = Direction(rawValue: self.direction) else {
            return .result()
        }
        
        widgetHolderQ.sync {
            // update direction for this widgetID
            let dataholder = PaginationDataHolder.holder(for: self.widgetID)
            dataholder?.updateDirection(direction)

            // ask widget views to be re-drawn by triggering timeline update
            // for the widget uniquely identified by the 'kind: widgetID'
            WidgetCenter.shared.reloadTimelines(ofKind: self.widgetID)
        }
        
        return .result()
    }
}


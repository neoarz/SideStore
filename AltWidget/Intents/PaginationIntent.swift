//
//  PaginationIntent.swift
//  AltStore
//
//  Created by Magesh K on 08/01/25.
//  Copyright © 2025 SideStore. All rights reserved.
//

import AppIntents

public enum Direction: String, Sendable{
    case up = "up"
    case down = "down"
}

@available(iOS 17, *)
final class PaginationIntent: AppIntent, @unchecked Sendable {
    
    static var title: LocalizedStringResource { "Page Navigation Intent" }
    static var isDiscoverable: Bool { false }

    @Parameter(title: "Direction")
    var direction: String

    @Parameter(title: "WidgetID")
    var widgetID: String
    
    var uuid: String = UUID().uuidString
    
    required init(){
        print()
    }
    
    init(_ direction: Direction, _ widgetID: String){
        self.direction = direction.rawValue
        self.widgetID = widgetID
    }
    
    func perform() async throws -> some IntentResult {
//        if let widgetID = self.widgetID
//        {
//            WidgetCenter.shared.reloadTimelines(ofKind: widgetID)
//        }
//        return .result()

        let result = try await WidgetUpdateIntent(
            Direction(rawValue: self.direction),
            self.widgetID
        ).perform()
        
        return result
    }
}



//
//  PaginationIntent.swift
//  AltStore
//
//  Created by Magesh K on 08/01/25.
//  Copyright © 2025 SideStore. All rights reserved.
//

import AppIntents
import WidgetKit

public enum Direction: String{
    case up = "up"
    case down = "down"
}

@available(iOS 17, *)
struct PaginationIntent: AppIntent, @unchecked Sendable {
    static var title: LocalizedStringResource { "Scroll up or down in Active Apps Widget" }
    static var isDiscoverable: Bool { false }

    @Parameter(title: "Direction")
    var direction: String

    @Parameter(title: "Widget Identifier")
    var widgetID: String
        
    init(){}
    
    init(_ direction: Direction, _ widgetID: String){
        self.direction = direction.rawValue
        self.widgetID = widgetID
    }

    func perform() async throws -> some IntentResult {
        let direction = Direction(rawValue: direction)!
        guard let viewModel = PaginationViewModel.instance(widgetID) else{
            print("viewModel for widgetID: \(widgetID) not found, ignoring request")
            return .result()
        }
        viewModel.handlePagination(direction)
        WidgetCenter.shared.reloadTimelines(ofKind: viewModel.widgetID)
        return .result()
    }
}


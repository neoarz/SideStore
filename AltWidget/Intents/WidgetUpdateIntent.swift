//
//  WidgetUpdateIntent.swift
//  AltStore
//
//  Created by Magesh K on 10/01/25.
//  Copyright © 2025 SideStore. All rights reserved.
//

import AppIntents

@available(iOS 17, *)
final class WidgetUpdateIntent: WidgetConfigurationIntent, @unchecked Sendable {
    
    static var title: LocalizedStringResource { "Intent for WidgetAppIntentConfiguration receiver type" }
    static var isDiscoverable: Bool { false }
    
    var uuid: String = UUID().uuidString
    private var widgetID: String?
    
    @Parameter(title: "ID", description: "Change this to unique ID to keep changes isolated from other widgets", default: "1")
    var ID: String?
    
    // this static hack is required, coz we are making these intents stateful
    private static var directionMap: [String: Direction] = [:]
    
    init(){
        print()
    }
    
    func getDirection( _ widgetID: String) -> Direction? {
        // remove it, since the event is processed. if needed it will be added again
        return Self.directionMap.removeValue(forKey: widgetID)
    }
    
    init(_ direction: Direction?, _ widgetID: String){
        Self.directionMap[widgetID] = direction
    }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

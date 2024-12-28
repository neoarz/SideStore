//
//  ConsoleLogView.swift
//  AltStore
//
//  Created by Magesh K on 29/12/24.
//  Copyright © 2024 SideStore. All rights reserved.
//
import SwiftUI

class ConsoleLogViewModel: ObservableObject {
    @Published var logLines: [String] = []
    
    private var fileWatcher: DispatchSourceFileSystemObject?
    
    private let backgroundQueue = DispatchQueue(label: "com.myapp.backgroundQueue", qos: .background)
    private var logURL: URL
    
    init(logURL: URL) {
        self.logURL = logURL
        startFileWatcher() // Start monitoring the log file for changes
        reloadLogData() // Load initial log data
    }
    
    private func startFileWatcher() {
        let fileDescriptor = open(logURL.path, O_RDONLY)
        guard fileDescriptor != -1 else {
            print("Unable to open file for reading.")
            return
        }
        
        fileWatcher = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .write, queue: backgroundQueue)
        fileWatcher?.setEventHandler {
            self.reloadLogData()
        }
        fileWatcher?.resume()
    }
    
    private func reloadLogData() {
        if let fileContents = try? String(contentsOf: logURL) {
            let lines = fileContents.split(whereSeparator: \.isNewline).map { String($0) }
            DispatchQueue.main.async {
                self.logLines = lines
            }
        }
    }
    
    deinit {
        fileWatcher?.cancel()
    }
}


public struct ConsoleLogView: View {
    
    @ObservedObject var viewModel: ConsoleLogViewModel
    @State private var isAtBottom: Bool = true
//    private let linesToShow: Int = 100  // Number of lines to show at once
    @State private var scrollToBottom: Bool = false  // State variable to trigger scroll

    init(logURL: URL) {
        self.viewModel = ConsoleLogViewModel(logURL: logURL)
    }
    
    public var body: some View {
       VStack {
           // Custom Header Bar (similar to QuickLook's preview screen)
           HStack {
               Text("Console Log")
                   .font(.system(size: 22, weight: .semibold))
                   .foregroundColor(.white)
               Spacer()
               SwiftUI.Button(action: {
                   scrollToBottom.toggle()
               }) {
                   Image(systemName: "ellipsis")
                       .foregroundColor(.white)
                       .imageScale(.large)
               }
           }
           .padding(15)
           .padding(.top, 5)
           .padding(.bottom, 2.5)
           .background(Color.black.opacity(0.9))
           .overlay(
               Rectangle()
                   .frame(height: 1)
                   .foregroundColor(Color.gray.opacity(0.2)), alignment: .bottom
           )

           // Main Log Display (scrollable area)
           ScrollView(.vertical) {
               ScrollViewReader { scrollViewProxy in
                   LazyVStack(alignment: .leading, spacing: 4) {
                       ForEach(viewModel.logLines.indices, id: \.self) { index in
                           Text(viewModel.logLines[index])
                               .font(.system(size: 12, design: .monospaced))
                               .foregroundColor(.white)
                       }
                   }
                   .onChange(of: scrollToBottom) { _ in
                       scrollToBottomIfNeeded(scrollViewProxy: scrollViewProxy)
                   }
               }
           }
       }
       .background(Color.black)  // Set background color to mimic QL's dark theme
       .edgesIgnoringSafeArea(.all)
    }
    
    // Scroll to the last index (bottom) only if logLines is not empty
    private func scrollToBottomIfNeeded(scrollViewProxy: ScrollViewProxy) {
        // Ensure we have log data before attempting to scroll
        guard !viewModel.logLines.isEmpty else {
            return
        }
        
        let last    = viewModel.logLines.count - 1
        let lastIdx = viewModel.logLines.indices.last
        assert(last == lastIdx)
//        scrollViewProxy.scrollTo(lastIdx, anchor: .bottom)
        scrollViewProxy.scrollTo(last, anchor: .bottom)
    }
}

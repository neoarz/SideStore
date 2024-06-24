//
//  AnisetteServerList.swift
//  SideStore
//
//  Created by ny on 6/18/24.
//  Copyright © 2024 SideStore. All rights reserved.
//

import UIKit
import SwiftUI
import AltStoreCore

typealias SUIButton = SwiftUI.Button

// MARK: - AnisetteServerData
struct AnisetteServerData: Codable {
    let servers: [Server]
}

// MARK: - Server
struct Server: Codable {
    var name: String
    var address: String
}

struct AniServer: Codable {
    var name: String
    var url: URL
}

class AnisetteViewModel: ObservableObject {
    @Published var selected: String = ""

    @Published var source: String = "https://servers.sidestore.io/servers.json"
    @Published var servers: [Server] = []
    
    func getListOfServers() {
        URLSession.shared.dataTask(with: URL(string: source)!) { data, response, error in
            if let error = error {
                return
            }
            if let data = data {
                do {
                    let servers = try Foundation.JSONDecoder().decode(AnisetteServerData.self, from: data)
                    DispatchQueue.main.async {
                        self.servers = servers.servers.map { Server(name: $0.name, address: $0.address) }
                    }
                } catch {
                    
                }
            }
        }
        .resume()
        for server in servers {
            print(server)
            print(server.name.count)
            print(server.name)
        }
    }
    
}

struct AnisetteServers: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: AnisetteViewModel = AnisetteViewModel()
    @State var selected: String? = nil
    var errorCallback: () -> ()

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor(named: "SettingsBackground")!).ignoresSafeArea(.all)
                    .onAppear {
                        viewModel.getListOfServers()
                    }
                VStack {
                    if #available(iOS 16.0, *) {
                        SwiftUI.List($viewModel.servers, id: \.address, selection: $selected) { server in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(server.name.wrappedValue)")
                                            .font(.headline)
                                            .underline(true, color: .white)
                                        Text("\(server.address.wrappedValue)")
                                            .fontWeight(.thin)
                                    }
                                    if selected != nil {
                                        if server.address.wrappedValue == selected {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                                .onAppear {
                                                    UserDefaults.standard.menuAnisetteURL = server.address.wrappedValue
                                                    print(UserDefaults.synchronize(.standard)())
                                                    print(UserDefaults.standard.menuAnisetteURL)
                                                    print(server.address.wrappedValue)
                                                }
                                        }
                                    }
                                }
                                .backgroundStyle((selected == nil) ? Color(UIColor(named: "SettingsHighlighted")!) : Color(UIColor(named: "SettingsBackground")!))
                            .listRowSeparatorTint(.white)
                            .listRowBackground((selected == nil) ? Color(UIColor(named: "SettingsHighlighted")!).ignoresSafeArea(.all) : Color(UIColor(named: "SettingsBackground")!).ignoresSafeArea(.all))
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .listRowBackground(Color(UIColor(named: "SettingsBackground")!).ignoresSafeArea(.all))
                        
                    } else {
                        List(selection: $selected) {
                            ForEach($viewModel.servers, id: \.name) { server in
                                VStack {
                                    HStack {
                                        Text("\(server.name.wrappedValue)")
                                            .foregroundColor(.white)
                                            .frame(alignment: .center)
                                        Text("\(server.address.wrappedValue)")
                                            .foregroundColor(.white)
                                            .frame(alignment: .center)
                                    }
                                }
                                Spacer()
                            }
                        }
                        .listStyle(.plain)
                        // Fallback on earlier versions
                    }
                    if #available(iOS 15.0, *) {
                        TextField("Anisette Server List", text: $viewModel.source)
                            .padding(.leading, 5)
                            .padding(.vertical, 10)
                            .frame(alignment: .center)
                            .textFieldStyle(.plain)
                            .border(.white, width: 1)
                            .onSubmit {
                                UserDefaults.standard.menuAnisetteList = viewModel.source
                                viewModel.getListOfServers()
                            }
                        SUIButton(action: {
                            viewModel.getListOfServers()
                        }, label: {
                            Text("Refresh Servers")
                        })
                        .padding(.bottom, 20)
                        SUIButton(role: .destructive, action: {
#if !DEBUG
                            if Keychain.shared.adiPb != nil {
                                Keychain.shared.adiPb = nil
                            }
#endif
                            print("Cleared adi.pb from keychain")
                            errorCallback()
                            self.presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text("Reset adi.pb")
//                            if (selected != nil) {
//                                Text("\(selected!.uuidString)")
//                            }
                        })
                        .padding(.bottom, 20)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Anisette Servers")
        .onAppear {
            if UserDefaults.standard.menuAnisetteList != "" {
                viewModel.source = UserDefaults.standard.menuAnisetteList
            } else {
                viewModel.source = "https://servers.sidestore.io/servers.json"
            }
            print(UserDefaults.standard.menuAnisetteURL)
            print(UserDefaults.standard.menuAnisetteList)
        }
    }
}


#Preview {
    AnisetteServers(selected: "", errorCallback: {})
}

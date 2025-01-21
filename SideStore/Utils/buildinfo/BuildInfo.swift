//
//  BuildInfo.swift
//  AltStore
//
//  Created by Magesh K on 21/01/25.
//  Copyright © 2025 SideStore. All rights reserved.
//

public class BuildInfo{
    private static let BUILD_REVISION_TAG  = "BuildRevision"    // commit ID for now (but could be any, set by build env vars
    private static let BUILD_CHANNEL_TAG   = "BuildChannel"     // set by build env, ex CI will set it via env vars, for xcode builds this is empty
    
    private static let MARKETING_VERSION_TAG        = "CFBundleShortVersionString"
    private static let CURRENT_PROJECT_VERSION_TAG  = kCFBundleVersionKey as String
    
    private static let XCODE_VERSION_TAG  = "DTXcode"
    private static let XCODE_REVISION_TAG = "DTXcodeBuild"

    public enum Channel: String {
        case unknown
        case local          // xcodebuilds can use this by setting BUILD_CHANNEL in CodeSigning.xcconfig
        
        case alpha
        case beta
        case stable
    }
    
    public lazy var channel: Channel = {
        let channel  = Bundle.main.object(forInfoDictionaryKey: Self.BUILD_CHANNEL_TAG) as? String
        return Channel(rawValue: channel ?? "") ?? .unknown
    }()

    public lazy var revision: String? = {
        let revision  = Bundle.main.object(forInfoDictionaryKey: Self.BUILD_REVISION_TAG) as? String
        return revision
    }()

    public lazy var project_version: String? = {
        let revision  = Bundle.main.object(forInfoDictionaryKey: Self.CURRENT_PROJECT_VERSION_TAG) as? String
        return revision
    }()

    public lazy var marketing_version: String? = {
        let revision  = Bundle.main.object(forInfoDictionaryKey: Self.MARKETING_VERSION_TAG) as? String
        return revision
    }()

    public lazy var xcode: String? = {
        let xcode  = Bundle.main.object(forInfoDictionaryKey: Self.XCODE_VERSION_TAG) as? String
        return xcode
    }()

    public lazy var xcode_revision: String? = {
        let revision  = Bundle.main.object(forInfoDictionaryKey: Self.XCODE_REVISION_TAG) as? String
        return revision
    }()

}

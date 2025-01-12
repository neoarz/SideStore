//
//  RefreshAppOperation.swift
//  AltStore
//
//  Created by Riley Testut on 2/27/20.
//  Copyright © 2020 Riley Testut. All rights reserved.
//

import Foundation

import AltStoreCore
import Roxas
import AltSign

@objc(RemoveAppExtensionsOperation)
final class RemoveAppExtensionsOperation: ResultOperation<Void>
{
    let context: AppOperationContext
    let appInDatabase: AppProtocol
    
    init(context: AppOperationContext, appInDatabase: AppProtocol)
    {
        self.context = context
        self.appInDatabase = appInDatabase
        super.init()
    }
    
    override func main()
    {
        super.main()
        
        if let error = self.context.error
        {
            self.finish(.failure(error))
            return
        }
        
        guard let targetAppBundle = context.app else {
            return self.finish(.failure(
                OperationError.invalidParameters("RemoveAppExtensionsOperation: context.app is nil")
            ))
        }
        
        self.removeAppExtensions(from: targetAppBundle,
                                  appInDatabase: appInDatabase as? InstalledApp,
                                  extensions: targetAppBundle.appExtensions,
                                  context.authenticatedContext.presentingViewController)
        
    }
    
    
    private static func removeExtensions(from extensions: Set<ALTApplication>) throws {
        for appExtension in extensions {
            print("Deleting extension \(appExtension.bundleIdentifier)")
            try FileManager.default.removeItem(at: appExtension.fileURL)
        }
    }
                                  
    
    
    private func removeAppExtensions(from targetAppBundle: ALTApplication,
                             appInDatabase: InstalledApp?,
                             extensions: Set<ALTApplication>,
                             _ presentingViewController: UIViewController?)
    {
            
        // target App Bundle doesn't contain extensions so don't bother
        guard !targetAppBundle.appExtensions.isEmpty else {
            return self.finish(.success(()))
        }
        
        //App-Extensions: Ensure existing app's extensions in DB and currently installing app bundle's extensions must match
        let existingAppEx: Set<InstalledExtension> = appInDatabase?.appExtensions ?? Set()
        let targetAppEx: Set<ALTApplication> = targetAppBundle.appExtensions
        
        let existingAppExNames = existingAppEx.map{ appEx in appEx.bundleIdentifier}
        let targetAppExNames  = targetAppEx.map{ appEx in appEx.bundleIdentifier}
        
        let excessExtensionsInTargetApp = targetAppEx.filter{
            !(existingAppExNames.contains($0.bundleIdentifier))
        }
        
        let necessaryExtensionsInExistingApp = existingAppEx.filter{
            targetAppExNames.contains($0.bundleIdentifier)
        }
        
        // always cleanup existing app (app-in-db) based on incoming app that is targeted for install
        appInDatabase?.appExtensions = necessaryExtensionsInExistingApp
        
        let isMatching = (targetAppEx.count == existingAppEx.count) && excessExtensionsInTargetApp.isEmpty
        let diagnosticsMsg = "RemoveAppExtensionsOperation: App Extensions in existingApp and targetAppBundle are matching: \(isMatching)\n"
                           + "RemoveAppExtensionsOperation: existingAppEx: \(existingAppExNames); targetAppBundleEx: \(String(describing: targetAppExNames))\n"
        print(diagnosticsMsg)
     
        // if background mode, then remove only the excess extensions
        guard let presentingViewController: UIViewController = presentingViewController else {
            // perform silent extensions cleanup for those that aren't already present in existing app
            print("\n    Performing background mode Extensions removal    \n")
            print("RemoveAppExtensionsOperation: Excess Extensions In TargetAppBundle: \(excessExtensionsInTargetApp)")
            print("RemoveAppExtensionsOperation: Necessary Extensions In ExistingAppInDatabase: \(necessaryExtensionsInExistingApp)")
            
            do {
                try Self.removeExtensions(from: excessExtensionsInTargetApp)
                return self.finish(.success(()))
            } catch {
                return self.finish(.failure(error))
            }
        }

        
        
        
        let firstSentence: String
        
        if UserDefaults.standard.activeAppLimitIncludesExtensions
        {
            firstSentence = NSLocalizedString("Non-developer Apple IDs are limited to 3 active apps and app extensions.", comment: "")
        }
        else
        {
            firstSentence = NSLocalizedString("Non-developer Apple IDs are limited to creating 10 App IDs per week.", comment: "")
        }
        
        let message = firstSentence + " " + NSLocalizedString("Would you like to remove this app's extensions so they don't count towards your limit? There are \(extensions.count) Extensions", comment: "")
        
        
        
        let alertController = UIAlertController(title: NSLocalizedString("App Contains Extensions", comment: ""), message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: UIAlertAction.cancel.title, style: UIAlertAction.cancel.style, handler: { (action) in
            self.finish(.failure(OperationError.cancelled))
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Keep App Extensions", comment: ""), style: .default) { (action) in
            self.finish(.success(()))
        })
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Remove App Extensions", comment: ""), style: .destructive) { (action) in
            do {
                try Self.removeExtensions(from: targetAppBundle.appExtensions)
                return self.finish(.success(()))
            } catch {
                return self.finish(.failure(error))
            }
        })
        
        
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Choose App Extensions", comment: ""), style: .default) { (action) in

            
            let popoverContentController = AppExtensionViewHostingController(extensions: extensions) { (selection) in
                do {
                    try Self.removeExtensions(from: Set(selection))
                    return self.finish(.success(()))
                } catch {
                    return self.finish(.failure(error))
                }
            }
            
            let suiview = popoverContentController.view!
            suiview.translatesAutoresizingMaskIntoConstraints = false
            
            popoverContentController.modalPresentationStyle = .popover
            
            if let popoverPresentationController = popoverContentController.popoverPresentationController {
                popoverPresentationController.sourceView = presentingViewController.view
                popoverPresentationController.sourceRect = CGRect(x: 50, y: 50, width: 4, height: 4)
                popoverPresentationController.delegate = popoverContentController
                
                DispatchQueue.main.async {
                    presentingViewController.present(popoverContentController, animated: true)
                }
            }else{
                self.finish(.failure(
                    OperationError.invalidParameters("RemoveAppExtensionsOperation: popoverContentController.popoverPresentationController is nil"))
                )
            }
        })
        
        DispatchQueue.main.async {
            presentingViewController.present(alertController, animated: true)
        }
    }
}

//
//  AppDelegate.swift
//  NavigationUI
//
//  Created by Ihor Demchenko on 02.04.2022.
//

import Foundation
import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private lazy var renderer: NavigationHierarchyRenderer = NavigationHierarchyRenderer()

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let window = UIWindow()
        
        let hierarchy = NavigationHierarchy()
        let rootViewController = renderer.render(hierarchy: hierarchy)
        window.rootViewController = rootViewController
        
        self.window = window
        return true
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        self.window?.makeKeyAndVisible()
        return true
    }
}

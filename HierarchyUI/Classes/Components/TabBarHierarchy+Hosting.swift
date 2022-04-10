//
//  TabBarHierarchy+Hosting.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 09.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import SwiftUI

extension TabBarHierarchy {
    /// Constructs TabBar through UIKit, attaches `TabBarItem`s and wraps it into UIHostingController.
    /// - Parameter navigator: EnvironmentObject that controls Navigation.
    /// - Returns: `NavigationEventNotifyingController` which is `ViewController` that notifies
    /// of navigation events.
    internal func provideHostingController(
        with navigator: HierarchyNavigator,
        for parentContainerRoute: NavigationHierarchyRoute,
        onPopToRootEvent: ((_ tabIndex: Int) -> Void)? = nil
    ) -> NavigationEventNotifyingController {
        let tabBarController = RouteHoldingTabBarControllerProxy(
            associatedRouteReference: parentContainerRoute
        )
        tabBarController.onSelectedIndexChanged = { [weak self] (index: Int) in
            self?.currentlySelectedIndex = index
        }
        let hostingControllers: [UIViewController] = self.tabs
            .map { (tab: TabBarHierarchyTabProperties) in
                switch tab.route.type {
                case .screen where !tab.route.nextRoute().isEmpty:
                    let hosting = NavigationManagingHostingControllerProxy(
                        associatedRouteReference: tab.route,
                        navigator: navigator
                    )
                    hosting.tabBarItem = tab.item
                    tab.route.ownerHostingController = hosting
                    tab.route.rootNavigationRoute = tab.route
                    tab.route.parentContainerRoute = parentContainerRoute
                    let controller = NavigationControllerProxy(rootViewController: hosting)
                    return controller
                case .screen:
                    let hosting: UIHostingController = NavigationManagingHostingControllerProxy(
                        associatedRouteReference: tab.route,
                        navigator: navigator
                    )
                    tab.route.ownerHostingController = hosting
                    tab.route.parentContainerRoute = parentContainerRoute
                    hosting.tabBarItem = tab.item
                    return hosting
                case .tabBar:
                    assertionFailure("Trying to embed TabBar inside TabBar. This leads to poor UX.")
                    return UIHostingController(rootView: AnyView(EmptyView()))
                }
            }
        tabBarController.viewControllers = hostingControllers
        tabBarController.selectedIndex = currentlySelectedIndex
        return tabBarController
    }
}

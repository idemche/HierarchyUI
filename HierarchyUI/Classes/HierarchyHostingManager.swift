//
//  HierarchyHostingManager.swift
//  HierarchyUI_Example
//
//  Created by Ihor Demchenko on 10.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import Foundation

internal final class HostingManager {
    typealias R = NavigationHierarchyRoute

    func renderInHostingController(
        route: R,
        embedding navigator: HierarchyNavigator,
        decorated decorator: HierarchyDecorator
    ) -> NavigationEventNotifyingController {
        switch route.type {
        case .screen:
            return NavigationManagingHostingControllerProxy(
                associatedRouteReference: route,
                navigator: navigator,
                decorator: decorator
            )
        case .tabBar(let hierarchy):
            return hierarchy.provideHostingController(
                with: navigator,
                and: decorator,
                for: route
            )
        }
    }
}

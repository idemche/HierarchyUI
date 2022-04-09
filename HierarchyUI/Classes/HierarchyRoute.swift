//
//  HierarchyRoute.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 04.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import SwiftUI

enum HierarchyRouteType {
    case screen(provider: () -> AnyView)
    case tabBar(hierarchy: TabBarHierarchyBuilder)
    
    var hasChildViewRoutes: Bool {
        switch self {
        case .screen: return false
        case .tabBar: return true
        }
    }
}

public final class NavigationHierarchyRoute {
    /// Push stack navigation and management
    /// =======================================================
    internal var previousRoute: NavigationHierarchyRoute?
    internal var nextRoute: () -> [AnyHashable: NavigationHierarchyRoute] = { [:] }
    /// =======================================================

    /// Modals navigation and management
    /// =======================================================
    internal weak var modalParentRoute: NavigationHierarchyRoute?
    internal var modals: () -> [AnyHashable: NavigationHierarchyRoute] = { [:] }
    /// =======================================================

    /// Replace navigation and management
    /// =======================================================
    internal var replacers: () -> [AnyHashable: NavigationHierarchyRoute] = { [:] }
    /// =======================================================

    /// Child navigation and management
    /// =======================================================
    internal weak var parentContainerRoute: NavigationHierarchyRoute?
    /// =======================================================

    /// Storable view provider properties
    /// =======================================================
    internal let key: AnyHashable
    internal let type: HierarchyRouteType
    /// =======================================================
    
    /// UIKit bridge
    /// =======================================================

    /// Hosting controller which owns current root view.
    internal weak var ownerHostingController: UIViewController?
    /// =======================================================

    internal init(key: AnyHashable, type: HierarchyRouteType) {
        self.key = key
        self.type = type
    }
}

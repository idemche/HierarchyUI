//
//  TabBarControllerProxy.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 08.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import SwiftUI

/// Used to notify whenever TabBarController dismisses or removes itself from Navigation Stack.
internal class NavigationEventNotifyingTabBarControllerProxy: UITabBarController, NavigationEventNotifyingController {
    
    var onPopEvent: (() -> Void)?
    var onPopToRootEvent: (() -> Void)?
    var onPopToViewControllerEvent: (() -> Void)?
    
    var onDismissEvent: (() -> Void)?

    func set(onDismissEvent: @escaping () -> Void) -> Self {
        self.onDismissEvent = onDismissEvent
        return self
    }
    
    func set(onPopEvent: @escaping () -> Void) -> Self {
        self.onPopEvent = onPopEvent
        return self
    }
    
    func set(onPopToRootEvent: @escaping () -> Void) -> Self {
        self.onPopToRootEvent = onPopToRootEvent
        return self
    }
    
    func set(onPopToViewControllerEvent: @escaping () -> Void) -> Self {
        self.onPopToViewControllerEvent = onPopToViewControllerEvent
        return self
    }
}

/// Used to hold reference of `NavigationHierarchyRoute` to avoid its deallocation.
/// Used to notify whenever TabBarController changes its index.
internal final class RouteHoldingTabBarControllerProxy: NavigationEventNotifyingTabBarControllerProxy {
    var onSelectedIndexChanged: ((Int) -> Void)?
    
    let associatedRouteReference: NavigationHierarchyRoute

    override var selectedViewController: UIViewController? {
        didSet {
            onSelectedIndexChanged?(selectedIndex)
        }
    }

    init(associatedRouteReference: NavigationHierarchyRoute) {
        self.associatedRouteReference = associatedRouteReference
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

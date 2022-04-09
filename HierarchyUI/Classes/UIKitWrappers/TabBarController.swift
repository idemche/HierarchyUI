//
//  TabBarController.swift
//  HierarchyUI_Example
//
//  Created by Ihor Demchenko on 08.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import SwiftUI

/// Used to notify whenever TabBarController dismisses or removes itself from Navigation Stack.
internal class NavigationEventNotifyingTabBarController: UITabBarController, NavigationEventNotifyingController {
    private var onDismiss: (() -> Void)?

    private var isBeingDismissedState: Bool {
        return isBeingDismissed || navigationController?.isBeingDismissed == true
    }

    func set(onDismiss: @escaping () -> Void) -> Self {
        self.onDismiss = onDismiss
        return self
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isMovingFromParent || isBeingDismissedState {
            onDismiss?()
        }
    }
}

/// Used to hold reference of `NavigationHierarchyRoute` to avoid its deallocation.
/// Used to notify whenever TabBarController changes its index.
internal final class RouteHoldingTabBarController: NavigationEventNotifyingTabBarController {
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

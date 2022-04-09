//
//  HostingControllers.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 04.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import SwiftUI

/// Used to notify whenever Hosting Controller dismisses or removes itself from Navigation Stack.
internal class NavigationEvenNotifyingHostingController: UIHostingController<AnyView>, NavigationEventNotifyingController {
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

/// Used to hold reference of Hierarchy Route to avoid its deallocation.
/// Used to find by `route.key` during pop action.
internal final class RouteHoldingHostingController: NavigationEvenNotifyingHostingController {
    let associatedRouteReference: NavigationHierarchyRoute

    init(associatedRouteReference: NavigationHierarchyRoute, navigator: HierarchyNavigator) {
        self.associatedRouteReference = associatedRouteReference
        if case .screen(let rootView) = associatedRouteReference.type {
            super.init(rootView: AnyView(rootView().environmentObject(navigator)))
        } else {
            assertionFailure("Only Routes without Child Views can be attached to Hosting Controller.")
            super.init(rootView: AnyView(EmptyView()))
        }
    }

    @MainActor
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

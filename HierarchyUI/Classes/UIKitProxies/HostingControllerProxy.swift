//
//  HostingControllerProxy.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 04.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import SwiftUI

extension UIViewController {
    var asManuallyControllableHosting: BaseManuallyControllableHostingControllerProxy? {
        guard let self = self as? BaseManuallyControllableHostingControllerProxy else {
            assertionFailure("Casting ViewController to unrelated parent class BaseManuallyControllableHostingControllerProxy.")
            return nil
        }
        return self
    }
}

internal class BaseManuallyControllableHostingControllerProxy: UIHostingController<AnyView> {
    func manuallyDismiss(animated: Bool, completion: @escaping () -> Void) {
        super.dismiss(animated: animated, completion: completion)
    }
}

/// Used to hold reference of Hierarchy Route to avoid its deallocation.
/// Used to notify whenever Hosting Controller dismisses or removes itself from Navigation Stack.
/// Used to find by `route.key` during pop action.
internal final class NavigationManagingHostingControllerProxy: BaseManuallyControllableHostingControllerProxy {
    let associatedRouteReference: NavigationHierarchyRoute
    
    var onPopEvent: (() -> Void)?
    var onPopToRootEvent: (() -> Void)?
    var onPopToViewControllerEvent: (() -> Void)?
    
    var onDismissEvent: (() -> Void)?

    init(
        associatedRouteReference: NavigationHierarchyRoute,
        navigator: HierarchyNavigator,
        decorator: HierarchyDecorator
    ) {
        self.associatedRouteReference = associatedRouteReference
        if case .screen(let rootView) = associatedRouteReference.type {
            super.init(
                rootView: AnyView(
                    rootView()
                        .environmentObject(navigator)
                        .environmentObject(decorator)
                )
            )
        } else {
            assertionFailure("Only Routes without Child Views can be attached to Hosting Controller.")
            super.init(rootView: AnyView(EmptyView()))
        }
        self.presentationController?.delegate = self
    }

    @MainActor
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NavigationManagingHostingControllerProxy: NavigationEventNotifyingController {
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

extension NavigationManagingHostingControllerProxy: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onDismissEvent?()
    }
}

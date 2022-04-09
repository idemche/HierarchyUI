//
//  NavigationHierarchyRouteRenderer.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 03.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import SwiftUI

public struct PushSettings {
    public var hidesBottomBarWhenPushed: Bool
    public static let `default`: PushSettings = .init(hidesBottomBarWhenPushed: false)
}

public struct ModalSettings {
    public var isFullscreen: Bool
    
    public static let `default`: ModalSettings = .init(isFullscreen: false)
}

enum NavigationHierarchyNavigationEvent {
    case push(key: AnyHashable?, settings: PushSettings = .default)
    case pop(key: AnyHashable?)
    case modal(key: AnyHashable?, settings: ModalSettings = .default)
    case replace(key: AnyHashable?)
    case dismiss
}

/// Core of HierarchyUI. Manages views by wrapping them in corresponding UIHostingControllers
/// and forwarding them by a corresponding navigation event.
public final class NavigationHierarchyRouteRenderer {

    /// Current route which gets rendered.
    private weak var currentNavigationRoute: NavigationHierarchyRoute?

    /// Navigation action handler. Processes actions handled by routes.
    private lazy var navigator: HierarchyNavigator = HierarchyNavigator(
        onNavigationEvent: { [weak self] event in
            self?.render(for: event)
        }
    )
    
    public init() {}

    public func render(hierarchy: NavigationHierarchy) -> some UIViewController {
        let currentRoute = hierarchy.structure()
        let rootViewController = constructController(from: currentRoute)
        let rootNavigationController = UINavigationController(rootViewController: rootViewController)
        self.currentNavigationRoute = currentRoute
        currentRoute.ownerHostingController = rootViewController
        return rootNavigationController
    }
    
    private func constructController(
        from route: NavigationHierarchyRoute
    ) -> NavigationEventNotifyingController {
        switch route.type {
        case .screen:
            return RouteHoldingHostingController(associatedRouteReference: route, navigator: navigator)
        case .tabBar(let hierarchy):
            return hierarchy.provideHostingController(with: self.navigator, for: route)
        }
    }
    
    private func render(for navigationEvent: NavigationHierarchyNavigationEvent) {
        switch navigationEvent {
        case .push(let key, let settings):
            guard let currentNavigationRoute = self.currentNavigationRoute else { return assertionFailure() }

            /// Find route
            /// ======================================================================
            
            let nextAvailableRouteOptions: [AnyHashable: NavigationHierarchyRoute]

            switch currentNavigationRoute.type {
            case .screen:
                nextAvailableRouteOptions = currentNavigationRoute.nextRoute()
            case .tabBar(let hierarchy):
                nextAvailableRouteOptions = hierarchy.currentTabRoute.nextRoute()
            }

            let nextRouteByKey = key.flatMap { nextAvailableRouteOptions[$0] }
            let nextRouteRandomized = nextAvailableRouteOptions.values.first

            if nextRouteByKey == nil, nextRouteRandomized != nil, nextAvailableRouteOptions.keys.count > 1 {
                assertionFailure(
                    """
                    "Note that you're trying to invoke navigation.push() without specifying a key.
                    That will lead to a random provided screen in navigation stack.
                    Avoid as possible any potential undefined behaviour.
                    """
                )
            }

            guard let nextRoute = nextRouteByKey ?? nextRouteRandomized else { return assertionFailure() }
            /// ======================================================================
            
            /// Install route
            /// ======================================================================
            let nextRouteHostingController = self.constructController(from: nextRoute)
                .set(onDismiss: { [weak self] in
                    guard let self = self else { return assertionFailure() }
                    if self.currentNavigationRoute == nextRoute {
                        self.currentNavigationRoute = nextRoute.previousRoute
                    }
                })
            nextRouteHostingController.hidesBottomBarWhenPushed = settings.hidesBottomBarWhenPushed
            nextRoute.ownerHostingController = nextRouteHostingController
            self.currentNavigationRoute = nextRoute
            /// ======================================================================
            
            /// Selecting controller which executes navigation
            /// ======================================================================
            
            let navigationExecutionRoute: NavigationHierarchyRoute
            
            switch currentNavigationRoute.type {
            case .tabBar(let hierarchy):
                navigationExecutionRoute = hierarchy.currentTabRoute
            case .screen:
                navigationExecutionRoute = currentNavigationRoute
            }
            /// ======================================================================
            
            /// Navigate to route
            /// ======================================================================
            guard let ownerHostingController = navigationExecutionRoute.ownerHostingController else {
                return assertionFailure("Missing owner hosting controller for current route.")
            }
            guard let navigationController = ownerHostingController.navigationController else {
                return assertionFailure("Missing navigation controller for current stack.")
            }
            navigationController.pushViewController(nextRouteHostingController, animated: true)
            /// ======================================================================
        case .pop(let key):
            guard let currentNavigationRoute = self.currentNavigationRoute else { return assertionFailure() }
            
            /// Find route
            /// ======================================================================
            var scannedRoute: NavigationHierarchyRoute? = currentNavigationRoute.previousRoute

            while let key = key, scannedRoute?.key != key, scannedRoute != nil {
                scannedRoute = scannedRoute?.previousRoute
            }

            guard let previousRoute = scannedRoute else {
                if let key = key {
                    return assertionFailure(
                        "No View with key: \(key) is found in navigation stack to pop to."
                    )
                } else {
                    return assertionFailure(
                        "There are no Views to pop to. You are trying to pop from root View."
                    )
                }
            }
            /// ======================================================================

            /// Install route
            /// ======================================================================
            self.currentNavigationRoute = previousRoute
            /// ======================================================================
            
            /// Navigate to route
            /// ======================================================================
            
            guard let ownerHostingController = currentNavigationRoute.ownerHostingController else {
                return assertionFailure("Missing owner hosting controller for current route.")
            }
            guard let navigationController = ownerHostingController.navigationController else {
                return assertionFailure("Missing navigation controller for current stack.")
            }

            if let key = key { // Find ViewController and pop to it if key is provided
                let scannedViewController = navigationController
                    .viewControllers
                    .first { (viewController: UIViewController) in
                        if let viewController = viewController as? RouteHoldingHostingController {
                            return viewController.associatedRouteReference.key == key
                        }
                        return false
                    }

                guard let viewController = scannedViewController else {
                    return assertionFailure("Haven't found ViewController with corresponding key while popping to it.")
                }

                navigationController.popToViewController(viewController, animated: true)
            
            } else { // Pop to previous VC

                navigationController.popViewController(animated: true)
            }
            /// ======================================================================
        case .modal(let key, let settings):
            guard let currentNavigationRoute = self.currentNavigationRoute else { return assertionFailure() }
            
            /// Find route
            /// ======================================================================

            let modalAvailableRouteOptions: [AnyHashable: NavigationHierarchyRoute]

            switch currentNavigationRoute.type {
            case .screen:
                modalAvailableRouteOptions = currentNavigationRoute.modals()
            case .tabBar(let hierarchy):
                modalAvailableRouteOptions = hierarchy.currentTabRoute.modals()
            }
            
            let modalRouteByKey = key.flatMap { modalAvailableRouteOptions[$0] }
            let modalRouteRandomized = modalAvailableRouteOptions.values.first
            
            if modalRouteByKey == nil, modalRouteRandomized != nil, modalAvailableRouteOptions.keys.count > 1 {
                assertionFailure(
                    """
                    "Note that you're trying to invoke navigation.modal() without specifying a key.
                    That will lead to a random modally provided screen.
                    Avoid as possible any potential undefined behaviour.
                    """
                )
            }
            
            guard let modalRoute = modalRouteByKey ?? modalRouteRandomized else {
                if let key = key {
                    return assertionFailure(
                        "No View with key: \(key) is found to present modally."
                    )
                } else {
                    return assertionFailure(
                        """
                        There are no Views to present modally from.
                        You are trying to present modally without any provided modal screen..
                        """
                    )
                }
            }
            /// ======================================================================
            
            /// Install route
            /// ======================================================================
            let hosting = self.constructController(from: modalRoute)
                .set(onDismiss: { [weak self] in
                    guard let self = self else { return assertionFailure() }
                    if self.currentNavigationRoute == modalRoute {
                        self.currentNavigationRoute = modalRoute.modalParentRoute
                    }
                })
            hosting.modalPresentationStyle = settings.isFullscreen ? .fullScreen : .automatic
            modalRoute.ownerHostingController = hosting
            self.currentNavigationRoute = modalRoute

            /// Navigate to route
            /// ======================================================================

            guard let ownerHostingController = currentNavigationRoute.ownerHostingController else {
                return assertionFailure("Missing owner hosting controller for current route.")
            }

            if !modalRoute.nextRoute().isEmpty {
                let navigation = UINavigationController(rootViewController: hosting)
                ownerHostingController.present(navigation, animated: true)
            } else {
                ownerHostingController.present(hosting, animated: true)
            }
            /// ======================================================================
        case .replace(let key):
            guard let currentNavigationRoute = self.currentNavigationRoute else { return assertionFailure() }
            
            /// Find route
            /// ======================================================================
            let nextReplacerAvailableRouteOptions = currentNavigationRoute.replacers()
            let nextReplacerByKey = key.flatMap { nextReplacerAvailableRouteOptions[$0] }
            let nextReplacerRandomized = nextReplacerAvailableRouteOptions.values.first
            
            if nextReplacerByKey == nil, nextReplacerRandomized != nil, nextReplacerAvailableRouteOptions.keys.count > 1 {
                assertionFailure(
                    """
                    "Note that you're trying to invoke navigation.replace() without specifying a key.
                    That will lead to a random provided screen in navigation stack.
                    Avoid as possible any potential undefined behaviour.
                    """
                )
            }
            
            guard let nextReplacerRoute = nextReplacerByKey ?? nextReplacerRandomized else { return assertionFailure() }
            /// ======================================================================
            
            /// Install route
            /// ======================================================================
            let hosting = self.constructController(from: nextReplacerRoute)
            nextReplacerRoute.ownerHostingController = hosting
            self.currentNavigationRoute = nextReplacerRoute
            /// ======================================================================
            
            /// Navigate to route
            /// ======================================================================
            let windowWrapped = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }?
                .windows
                .first

            guard let window = windowWrapped else {
                return assertionFailure("Haven't found an active window.")
            }

            if !nextReplacerRoute.nextRoute().isEmpty {
                let navigation: UIViewController = UINavigationController(rootViewController: hosting)
                window.rootViewController = navigation
            } else {
                window.rootViewController = hosting
            }
            /// ======================================================================
        case .dismiss:
            guard let currentNavigationRoute = self.currentNavigationRoute else { return assertionFailure() }
            guard let parent = currentNavigationRoute.modalParentRoute else { return assertionFailure() }

            /// Navigate to route
            /// ======================================================================
            
            guard let ownerHostingController = currentNavigationRoute.ownerHostingController else {
                return assertionFailure("Missing owner hosting controller for current route.")
            }

            ownerHostingController.dismiss(animated: true) { [weak self] in
                guard let self = self else { return assertionFailure() }
                self.currentNavigationRoute = parent
            }
            /// ======================================================================
        }
    }
}

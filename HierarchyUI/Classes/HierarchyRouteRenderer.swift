//
//  NavigationHierarchyRouteRenderer.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 03.04.2022.
//

import UIKit

public final class NavigationHierarchyRouteRenderer {
    
    private var currentNavigationRoute: NavigationHierarchyRoute?
    
    private lazy var navigator: HierarchyNavigator = HierarchyNavigator(onPush: { [weak self] key in
        guard let self = self else { return assertionFailure() }
        guard let currentNavigationRoute = self.currentNavigationRoute else { return assertionFailure() }

        /// Find route
        /// ======================================================================
        let nextAvailableRouteOptions = currentNavigationRoute.nextRoute()
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
        let nextRootView = nextRoute.rootViewProvider().environmentObject(self.navigator)
        let hosting = EventNotifyingHostingController(key: nextRoute.key, rootView: nextRootView).set(onDismiss: { [weak self] in
            guard let self = self else { return assertionFailure() }
            if self.currentNavigationRoute == nextRoute {
                self.currentNavigationRoute = nextRoute.previousRoute
            }
        })
        nextRoute.parentHostingController = hosting
        self.currentNavigationRoute = nextRoute
        /// ======================================================================
        
        /// Navigate to route
        /// ======================================================================
        currentNavigationRoute
            .parentHostingController?
            .navigationController?
            .pushViewController(hosting, animated: true)
        /// ======================================================================

    }, onModal: { [weak self] key in
        guard let self = self else { return assertionFailure() }
        guard let currentNavigationRoute = self.currentNavigationRoute else { return assertionFailure() }
        
        /// Find route
        /// ======================================================================
        
        let modalAvailableRouteOptions = currentNavigationRoute.modals()
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
                    "No View with key: \(key) is found in navigation stack to push to."
                )
            } else {
                return assertionFailure(
                    """
                    There are no Views to push to.
                    You are trying to pop from last View in navigation stack.
                    """
                )
            }
        }
        /// ======================================================================
        
        /// Install route
        /// ======================================================================
        let view = modalRoute.rootViewProvider().environmentObject(self.navigator)
        let hosting = EventNotifyingHostingController(key: modalRoute.key, rootView: view)
            .set(onDismiss: { [weak self] in
                guard let self = self else { return assertionFailure() }
                if self.currentNavigationRoute == modalRoute {
                    self.currentNavigationRoute = modalRoute.parent
                }
            })
        modalRoute.parentHostingController = hosting
        self.currentNavigationRoute = modalRoute

        /// Navigate to route
        /// ======================================================================
        if !modalRoute.nextRoute().isEmpty {
            let navigation = UINavigationController(rootViewController: hosting)
            currentNavigationRoute.parentHostingController?.present(navigation, animated: true)
        } else {
            currentNavigationRoute.parentHostingController?.present(hosting, animated: true)
        }
        /// ======================================================================

    }, onPop: { [weak self] key in
        guard let self = self else { return assertionFailure() }
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
        if let key = key { // Find ViewController and pop to it if key is provided
            let scannedViewController = currentNavigationRoute
                .parentHostingController?
                .navigationController?
                .viewControllers
                .first { (viewController: UIViewController) in
                    if let viewController = viewController as? KeyHoldableHostingController {
                        return viewController.key == key
                    }
                    return false
                }
            
            guard let viewController = scannedViewController else { return assertionFailure() }
            
            currentNavigationRoute
                .parentHostingController?
                .navigationController?
                .popToViewController(viewController, animated: true)
        } else { // Pop to previous VC
            currentNavigationRoute
                .parentHostingController?
                .navigationController?
                .popViewController(animated: true)
        }
        /// ======================================================================

    }, onReplace: { [weak self] key in
        guard let self = self else { return assertionFailure() }
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
        let view = nextReplacerRoute.rootViewProvider().environmentObject(self.navigator)
        let hosting = EventNotifyingHostingController(key: nextReplacerRoute.key, rootView: view)
        
        nextReplacerRoute.parentHostingController = hosting
        self.currentNavigationRoute = nextReplacerRoute
        /// ======================================================================
        
        /// Navigate to route
        /// ======================================================================
        let windowWrapped = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }?
            .windows
            .first
        
        guard let window = windowWrapped else { return assertionFailure() }

        if !nextReplacerRoute.nextRoute().isEmpty {
            let navigation = UINavigationController(rootViewController: hosting)
            window.rootViewController = navigation
        } else {
            window.rootViewController = hosting
        }
        /// ======================================================================

    }, onDismiss: { [weak self] in
        guard let self = self else { return assertionFailure() }
        guard let currentNavigationRoute = self.currentNavigationRoute else { return assertionFailure() }
        guard let parent = currentNavigationRoute.parent else { return assertionFailure() }

        /// Navigate to route
        /// ======================================================================
        currentNavigationRoute.parentHostingController?.dismiss(animated: true) { [weak self] in
            guard let self = self else { return assertionFailure() }
            self.currentNavigationRoute = parent
        }
        /// ======================================================================
    })

    public func render(hierarchy: NavigationHierarchy) -> some UIViewController {
        let currentRoute = hierarchy.structure()
        let rootView = currentRoute.rootViewProvider().environmentObject(navigator)
        let rootViewController = EventNotifyingHostingController(key: currentRoute.key, rootView: rootView)
        let rootNavigationController = UINavigationController(rootViewController: rootViewController)
        self.currentNavigationRoute = currentRoute
        currentRoute.parentHostingController = rootViewController
        return rootNavigationController
    }
}

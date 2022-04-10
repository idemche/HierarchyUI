//
//  NavigationHierarchyRouteRenderer.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 03.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import SwiftUI

/// Core of HierarchyUI. Manages views by wrapping them in corresponding UIHostingControllers
/// and forwarding them by a corresponding navigation event.
public final class NavigationHierarchyRouteRenderer {

    /// Wraps routes in corresponding Hosting/View controllers.
    private lazy var hostingManager: HostingManager = HostingManager()
    /// Manages routes traversing over the graph.
    private lazy var graphManager: HierarchyGraphManager = HierarchyGraphManager()
    /// Navigation action handler. Processes actions handled by routes.
    private lazy var navigator: HierarchyNavigator = HierarchyNavigator(
        onNavigationEvent: { [weak self] event in
            self?.handle(navigationEvent: event)
        }
    )
    
    public init() {}

    public func render(hierarchy: NavigationHierarchy) -> UIViewController {
        let route = hierarchy.structure()
        graphManager.move(to: route)

        let hosting = hostingManager.renderInHostingController(route: route, embedding: navigator)

        switch route.type {
        case .screen:
            let rootNavigationControllerProxy = NavigationControllerProxy(rootViewController: hosting)
            route.ownerHostingController = hosting
            route.rootNavigationRoute = route
            return rootNavigationControllerProxy
        case .tabBar:
            return hosting
        }
    }

    private func handle(navigationEvent: NavigationHierarchyNavigationEvent) {
        switch navigationEvent {
        case .push(let key, let settings):
            /// Selecting controller which executes navigation
            /// ======================================================================
            
            let navigationExecutingRoute = graphManager.getNavigationExecutingRoute(navType: .pushable)
            /// ======================================================================
            
            /// Finding route
            /// ======================================================================
            guard let nextPushableRoute = graphManager.getNextRoute(type: .pushable, for: key) else { return assertionFailure() }
            graphManager.move(to: nextPushableRoute)

            let nextRouteHostingController = hostingManager.renderInHostingController(
                route: nextPushableRoute,
                embedding: navigator
            )
            .set(onPopEvent: { [weak graphManager] in
                guard let graphManager = graphManager else { return assertionFailure("Self reference deallocated") }
                let targetRouteWrapped = graphManager.getPreviousHierarchyRoute(navType: .pushable, for: nil)
                guard let targetRoute = targetRouteWrapped else { return assertionFailure() }
                graphManager.move(to: targetRoute)
            })
            .set(onPopToRootEvent: { [weak graphManager] in
                guard let graphManager = graphManager else { return assertionFailure("Self reference deallocated") }
                let targetRouteWrapped = graphManager.getPreviousRootRoute()
                guard let targetRoute = targetRouteWrapped else { return assertionFailure() }
                graphManager.move(to: targetRoute)
            })
            .set(onPopToViewControllerEvent: { [weak graphManager] in
                guard let graphManager = graphManager else { return assertionFailure("Self reference deallocated") }
                let targetRouteWrapped = graphManager.getPreviousRootRoute()
                guard let targetRoute = targetRouteWrapped else { return assertionFailure() }
                graphManager.move(to: targetRoute)
            })

            nextRouteHostingController.hidesBottomBarWhenPushed = settings.hidesBottomBarWhenPushed
            nextPushableRoute.ownerHostingController = nextRouteHostingController
            /// ======================================================================
        
            /// Navigating to route
            /// ======================================================================
            guard let ownerHostingController = navigationExecutingRoute?.ownerHostingController else {
                return assertionFailure("Missing owner hosting controller for current route.")
            }
            guard let navigationController = ownerHostingController.navigationController else {
                return assertionFailure("Missing navigation controller for current stack.")
            }
            navigationController.pushViewController(nextRouteHostingController, animated: true)
            /// ======================================================================
        case .pop(let key):
            
            /// Selecting controller which executes navigation
            /// ======================================================================
            guard let ownerHostingController = graphManager.getNavigationExecutingRoute(navType: .pushable)?.ownerHostingController else {
                return assertionFailure("Missing owner hosting controller for current route.")
            }
            guard let navigationController = ownerHostingController.navigationController else {
                return assertionFailure("Missing navigation controller for current stack.")
            }
            /// ======================================================================
            
            /// Finding route
            /// ======================================================================
            guard let previousRoute = graphManager.getPreviousHierarchyRoute(navType: .pushable, for: key) else {
                return assertionFailure("Missing previous route.")
            }
            graphManager.move(to: previousRoute)
            /// ======================================================================
            
            /// Navigating to route
            /// ======================================================================
            if previousRoute.type.hasChildViewRoutes, previousRoute.key == key {
                navigationController.asLocalNavigationControllerProxy?.manuallyPopToRootViewController()
            } else if let key = key { // Find ViewController and pop to it if key is provided
                navigationController.asLocalNavigationControllerProxy?.manuallyPopToViewController(by: key)
            } else { // Pop to previous VC
                navigationController.asLocalNavigationControllerProxy?.manuallyPopViewController()
            }
            /// ======================================================================
        
        case .popToRoot:
            
            /// Selecting controller which executes navigation
            /// ======================================================================
            guard let ownerHostingController = graphManager.getNavigationExecutingRoute(navType: .pushable)?.ownerHostingController else {
                return assertionFailure("Missing owner hosting controller for current route.")
            }
            guard let navigationController = ownerHostingController.navigationController else {
                return assertionFailure("Missing navigation controller for current route.")
            }
            /// ======================================================================
            
            /// Finding route
            /// ======================================================================
            guard let rootRoute = graphManager.getPreviousRootRoute() else { return assertionFailure() }
            graphManager.move(to: rootRoute)
            /// ======================================================================
        
            /// Navigate to route
            /// ======================================================================
            navigationController.popToRootViewController(animated: true)
            /// ======================================================================
            
        case .modal(let key, let settings):
            
            /// Selecting controller which executes navigation
            /// ======================================================================
            guard let ownerHostingController = graphManager.getNavigationExecutingRoute(navType: .modal)?.ownerHostingController else {
                return assertionFailure("Missing owner hosting controller for current route.")
            }
            /// ======================================================================
            
            /// Finding route
            /// ======================================================================
            guard let modalRoute = graphManager.getNextRoute(type: .modal, for: key) else { return assertionFailure() }
            graphManager.move(to: modalRoute)
            /// ======================================================================
            
            /// Setting up and installing the route
            /// ======================================================================
            let hosting = hostingManager.renderInHostingController(route: modalRoute, embedding: navigator)
                .set(onDismissEvent: { [weak graphManager] in
                    guard let graphManager = graphManager else { return assertionFailure("Self reference deallocated") }
                    let targetRouteWrapped = graphManager.getPreviousHierarchyRoute(navType: .modal, for: nil)
                    guard let targetRoute = targetRouteWrapped else { return assertionFailure() }
                    graphManager.move(to: targetRoute)
                })
            hosting.modalPresentationStyle = settings.isFullscreen ? .fullScreen : .automatic
            modalRoute.ownerHostingController = hosting

            /// Navigating to the route
            /// ======================================================================

            if !modalRoute.nextRoute().isEmpty {
                let navigation = NavigationControllerProxy(rootViewController: hosting)
                modalRoute.rootNavigationRoute = modalRoute
                ownerHostingController.present(navigation, animated: true)
            } else {
                ownerHostingController.present(hosting, animated: true)
            }
            /// ======================================================================
        case .replace(let key):
            
            /// Selecting controller which executes navigation
            /// ======================================================================
            let windowWrapped = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first {
                    $0.activationState == .foregroundActive
                    || $0.activationState == .foregroundInactive
                }?
                .windows
                .first

            guard let window = windowWrapped else {
                return assertionFailure("Haven't found an active window.")
            }
            /// ======================================================================
        
            /// Finding the route
            /// ======================================================================
            guard let nextReplacerRoute = graphManager.getNextRoute(type: .replacer, for: key) else {
                return assertionFailure()
            }
            graphManager.move(to: nextReplacerRoute)
            /// ======================================================================
            
            /// Installing the route
            /// ======================================================================
            let hosting = hostingManager.renderInHostingController(route: nextReplacerRoute, embedding: navigator)
            nextReplacerRoute.ownerHostingController = hosting
            /// ======================================================================
            
            /// Navigating to the route
            /// ======================================================================
            if !nextReplacerRoute.nextRoute().isEmpty {
                let navigation: UIViewController = NavigationControllerProxy(rootViewController: hosting)
                window.rootViewController = navigation
            } else {
                window.rootViewController = hosting
            }
            /// ======================================================================
        case .dismiss:
            /// Selecting controller which executes navigation
            /// ======================================================================
            guard let ownerHostingController = graphManager.getNavigationExecutingRoute(navType: .modal)?.ownerHostingController?.asManuallyControllableHosting else {
                return assertionFailure("Missing owner hosting controller for current route.")
            }
            /// Finding the route
            /// ======================================================================
            guard let previousNavigationRoute = graphManager.getPreviousHierarchyRoute(navType: .modal, for: nil) else {
                return assertionFailure("Haven't found a parent route.")
            }
            /// Navigating to the route
            /// ======================================================================
            ownerHostingController.manuallyDismiss(animated: true) { [weak graphManager] in
                guard let graphManager = graphManager else { return assertionFailure() }
                graphManager.move(to: previousNavigationRoute)
            }
            /// ======================================================================
        }
    }
}

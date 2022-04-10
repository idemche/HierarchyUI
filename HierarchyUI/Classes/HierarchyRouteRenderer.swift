//
//  NavigationHierarchyRouteRenderer.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 03.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import SwiftUI

final class HostingManager {
    typealias R = NavigationHierarchyRoute

    func renderInHostingController(
        route: R,
        embedding navigator: HierarchyNavigator
    ) -> NavigationEventNotifyingController {
        switch route.type {
        case .screen:
            return RouteHoldingHostingController(
                associatedRouteReference: route,
                navigator: navigator
            )
        case .tabBar(let hierarchy):
            return hierarchy.provideHostingController(
                with: navigator,
                for: route
            )
        }
    }
}

final class HierarchyGraphManager {
    typealias R = NavigationHierarchyRoute
    typealias WR = WeakReference<NavigationHierarchyRoute>
    
    enum NavigationType {
        case modal
        case pushable
        case replacer
    }
    
    private enum GraphState {
        case singleRoute(route: WR)
        case routesTree(rootRoute: WR, routes: [Int: WR])
        
        var currentRoute: R? {
            switch self {
            case .singleRoute(let route):
                return route.reference
            case .routesTree(let root, let routes):
                if case .tabBar(let hierarchy) = root.reference?.type {
                    return routes[hierarchy.currentlySelectedIndex]?.reference
                }
                return nil
            }
        }
    }
    
    /// Current route which gets rendered.
    private var currentGraphState: GraphState?
    
    var currentHierarchyRoute: R? {
        return currentGraphState?.currentRoute
    }

    func getNextRoute(type: NavigationType, for key: AnyHashable?) -> R? {
        let nextAvailableRouteOptions: [AnyHashable: NavigationHierarchyRoute]

        switch currentGraphState {
        case .singleRoute(let route):
            switch route.reference?.type {
            case .screen:
                switch type {
                case .modal:
                    nextAvailableRouteOptions = route.reference?.modals() ?? [:]
                case .pushable:
                    nextAvailableRouteOptions = route.reference?.nextRoute() ?? [:]
                case .replacer:
                    nextAvailableRouteOptions = route.reference?.replacers() ?? [:]
                }
            case .tabBar:
                assertionFailure(
                    "Unsupported single-view screen type. Probably this is not a single-view type?"
                )
                nextAvailableRouteOptions = [:]
            case .none:
                assertionFailure("Weak reference was deallocated and lost.")
                nextAvailableRouteOptions = [:]
            }
        case .routesTree(let rootRoute, let routes):
            switch rootRoute.reference?.type {
            case .tabBar(let hierarchy):
                let route = routes[hierarchy.currentlySelectedIndex]
                switch type {
                case .modal:
                    nextAvailableRouteOptions = route?.reference?.modals() ?? [:]
                case .pushable:
                    nextAvailableRouteOptions = route?.reference?.nextRoute() ?? [:]
                case .replacer:
                    nextAvailableRouteOptions = route?.reference?.replacers() ?? [:]
                }
            default:
                assertionFailure(
                    "Unsupported multi-view screen type. Probably this is not a multi-view type?"
                )
                nextAvailableRouteOptions = [:]
            }
        case .none:
            assertionFailure("Graph State is empty and wasn't constructed in a first place.")
            nextAvailableRouteOptions = [:]
        }

        /// Trying to unwrap next view:
        /// Firstly - by key if next route exists with that key.
        let nextRouteByKey = key.flatMap { nextAvailableRouteOptions[$0] }
        /// Secondly - first available.
        let nextRouteRandomized = nextAvailableRouteOptions.values.first
        
        if key != nil, nextRouteByKey == nil {
            assertionFailure("Route by key hasn't been found")
            return nil
        }

        /// If no route available -> throw an assertionFailure.
        guard let nextRoute = nextRouteByKey ?? nextRouteRandomized else {
            assertionFailure(
                """
                "Note that you're trying to invoke navigation action without specifying a key in hierarchy structure.
                That will lead to a random provided screen in navigation stack.
                Avoid as possible any potential undefined behaviour.
                """
            )
            return nil
        }
        return nextRoute
    }
    
    func getPreviousRootRoute() -> R? {
        switch currentGraphState {
        case .singleRoute(let route):
            guard let reference = route.reference else {
                assertionFailure("Weak reference was deallocated and lost.")
                return nil
            }
            guard let parent = reference.rootNavigationRoute else {
                assertionFailure("No root route found")
                return nil
            }
            return parent
        case .routesTree(let rootRoute, let routes):
            if case .tabBar(let hierarchy) = rootRoute.reference?.type {
                guard let currentTabRoute = routes[hierarchy.currentlySelectedIndex]?.reference else {
                    assertionFailure("Weak reference was deallocated and lost.")
                    return nil
                }
                guard let rootTabRoute = currentTabRoute.rootNavigationRoute else {
                    assertionFailure("Hierarchy route doesn't have a root route.")
                    return nil
                }
                return rootTabRoute
            }
            assertionFailure("Unhandled child tab?")
            return nil
        case .none:
            assertionFailure("GraphState is empty.")
            return nil
        }
    }
    
    func getPreviousHierarchyRoute(navType: NavigationType, for key: AnyHashable?) -> R? {

        let anchorRoute: R

        switch currentGraphState {
        case .singleRoute(let route):
            guard let reference = route.reference else {
                assertionFailure("Weak reference was deallocated and lost.")
                return nil
            }
            anchorRoute = reference
        case .routesTree(let rootRoute, let routes):
            switch rootRoute.reference?.type {
            case .tabBar(let hierarchy):
                guard let reference = routes[hierarchy.currentlySelectedIndex]?.reference else {
                    assertionFailure("Weak reference was deallocated and lost.")
                    return nil
                }
                anchorRoute = reference
            default:
                assertionFailure(
                    "Unsupported multi-view screen type. Probably this is not a multi-view type?"
                )
                return nil
            }
        case .none:
            assertionFailure("Graph State is empty and wasn't constructed in a first place.")
            return nil
        }
        
        /// Find route
        /// ======================================================================

        var scannedRoute: NavigationHierarchyRoute?

        switch navType {
        case .modal:
            scannedRoute = anchorRoute.modalParentRoute
        case .pushable:
            scannedRoute = anchorRoute.previousRoute
            while let key = key, scannedRoute?.key != key, scannedRoute != nil {
                if scannedRoute?.parentContainerRoute?.key == key {
                    scannedRoute = scannedRoute?.parentContainerRoute
                } else {
                    scannedRoute = scannedRoute?.previousRoute
                }
            }
        case .replacer:
            assertionFailure("Go back from replacer in unsupported. New replaced view removes all previous routes.")
            return scannedRoute
        }
        /// ======================================================================

        
        guard let previousRoute = scannedRoute else {
            if let key = key {
                assertionFailure("No View with key: \(key) is found in navigation stack to \(navType) to.")
                return nil
            } else {
                assertionFailure("There are no Views to pop to. You are trying to \(navType) from root View.")
                return nil
            }
        }
        
        return previousRoute
    }

    func move(to nextRoute: R) {
        switch currentGraphState {
        case .routesTree(let currentRootRoute, var currentChildRoutes):
            switch currentRootRoute.reference?.type {
            case .tabBar(let currentHierarchy):
                switch nextRoute.type {
                case .screen:
                    currentChildRoutes[currentHierarchy.currentlySelectedIndex] = WR(nextRoute)
                    self.currentGraphState = .routesTree(
                        rootRoute: currentRootRoute,
                        routes: currentChildRoutes
                    )
                case .tabBar(let nestedHierarchy) where currentHierarchy.key == nestedHierarchy.key:
                    let currentTabRoute = currentChildRoutes[currentHierarchy.currentlySelectedIndex]
                    guard let rootNavigationRouteForTab = currentTabRoute?.reference?.rootNavigationRoute else {
                        return assertionFailure("Root Navigation reference was deallocated")
                    }
                    currentChildRoutes[currentHierarchy.currentlySelectedIndex] = WR(rootNavigationRouteForTab)
                    self.currentGraphState = .routesTree(
                        rootRoute: currentRootRoute,
                        routes: currentChildRoutes
                    )
                case .tabBar:
                    assertionFailure("TabBar inside TabBar is not supported.")
                }
            case .none:
                return assertionFailure("Weak reference was deallocated and lost.")
            default:
                return assertionFailure(
                    "Unsupported multi-view screen type. Probably this is not a multi-view type?"
                )
            }
        case .singleRoute, .none:
            switch nextRoute.type {
            case .screen:
                self.currentGraphState = .singleRoute(
                    route: WR(nextRoute)
                )
            case .tabBar(let hierarchy):
                self.currentGraphState = .routesTree(
                    rootRoute: WR(nextRoute),
                    routes: hierarchy.tabs.enumerated().reduce([:]) { (routes, bundle) in
                        var routes = routes
                        routes[bundle.offset] = WR(bundle.element.route)
                        return routes
                    }
                )
            }
        }
    }
    
    func getNavigationExecutingRoute(navType: NavigationType) -> NavigationHierarchyRoute? {
        switch self.currentGraphState {
        case .singleRoute(let route):
    
            switch navType {
            case .modal:
                guard let reference = route.reference else {
                    assertionFailure("Weak reference was deallocated.")
                    return nil
                }
                assert(reference.ownerHostingController != nil, "No owner hosting controller")
                return reference
            case .pushable:
                guard let reference = route.reference else {
                    assertionFailure("Weak reference was deallocated.")
                    return nil
                }
                guard let root = reference.rootNavigationRoute else {
                    assertionFailure("No root reference attached.")
                    return nil
                }
                return root
            case .replacer:
                assertionFailure("Replacer uses global UIWindow in current implementation.")
                return nil
            }

        case .routesTree(let rootRoute, let currentActiveTabRoutes):
            switch rootRoute.reference?.type {
            case .tabBar(let hierarchy):
                let reference = currentActiveTabRoutes[hierarchy.currentlySelectedIndex]?.reference
                assert(reference != nil, "Weak reference was deallocated.")

                switch navType {
                case .modal:
                    return reference
                case .pushable:
                    let root = reference?.rootNavigationRoute
                    assert(root != nil, "No root reference attached.")
                    return root
                case .replacer:
                    assertionFailure("Replacer uses global UIWindow in current implementation.")
                    return nil
                }
            default:
                assertionFailure(
                    "Unsupported multi-view screen type. Probably this is not a multi-view type?"
                )
                return nil
            }
        case .none:
            assertionFailure("Graph State is empty and wasn't constructed in a first place.")
            return nil
        }
    }
}

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
            self?.render(navigationEvent: event)
        }
    )
    
    public init() {}

    public func render(hierarchy: NavigationHierarchy) -> UIViewController {
        let route = hierarchy.structure()
        graphManager.move(to: route)

        let hosting = hostingManager.renderInHostingController(route: route, embedding: navigator)

        switch route.type {
        case .screen:
            let rootNavigationController = UINavigationController(rootViewController: hosting)
            route.ownerHostingController = hosting
            route.rootNavigationRoute = route
            return rootNavigationController
        case .tabBar:
            return hosting
        }
    }

    private func render(navigationEvent: NavigationHierarchyNavigationEvent) {
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
            ).set(onDismiss: { [weak self, weak potentialCurrentRoute = nextPushableRoute] in
                guard let self = self else { return assertionFailure("Self reference deallocated") }
                guard let currentRoute = self.graphManager.currentHierarchyRoute else {
                    return assertionFailure("Graph state or route reference is nil.")
                }
                if potentialCurrentRoute == currentRoute {
                    let routeWrapped = self.graphManager.getPreviousHierarchyRoute(navType: .pushable, for: nil)
                    guard let targetRoute = routeWrapped else { return assertionFailure() }
                    self.graphManager.move(to: targetRoute)
                }
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
            
                navigationController.popToRootViewController(animated: true)

            } else if let key = key { // Find ViewController and pop to it if key is provided
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
                .set(onDismiss: { [weak self, weak potentialCurrentRoute = modalRoute] in
                    guard let self = self else { return assertionFailure("Self reference deallocated") }
                    guard let currentRoute = self.graphManager.currentHierarchyRoute else {
                        return assertionFailure("Graph state or route reference is nil.")
                    }
                    if potentialCurrentRoute == currentRoute {
                        let routeWrapped = self.graphManager.getPreviousHierarchyRoute(navType: .modal, for: nil)
                        guard let targetRoute = routeWrapped else { return assertionFailure() }
                        self.graphManager.move(to: targetRoute)
                    }
                })
            hosting.modalPresentationStyle = settings.isFullscreen ? .fullScreen : .automatic
            modalRoute.ownerHostingController = hosting

            /// Navigating to the route
            /// ======================================================================

            if !modalRoute.nextRoute().isEmpty {
                let navigation = UINavigationController(rootViewController: hosting)
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
                let navigation: UIViewController = UINavigationController(rootViewController: hosting)
                window.rootViewController = navigation
            } else {
                window.rootViewController = hosting
            }
            /// ======================================================================
        case .dismiss:
            /// Selecting controller which executes navigation
            /// ======================================================================
            guard let ownerHostingController = graphManager.getNavigationExecutingRoute(navType: .modal)?.ownerHostingController else {
                return assertionFailure("Missing owner hosting controller for current route.")
            }
            /// Finding the route
            /// ======================================================================
            guard let previousNavigationRoute = graphManager.getPreviousHierarchyRoute(navType: .modal, for: nil) else {
                return assertionFailure("Haven't found a parent route.")
            }
            /// Navigating to the route
            /// ======================================================================
            ownerHostingController.dismiss(animated: true) { [weak graphManager] in
                guard let graphManager = graphManager else { return assertionFailure() }
                graphManager.move(to: previousNavigationRoute)
            }
            /// ======================================================================
        }
    }
}

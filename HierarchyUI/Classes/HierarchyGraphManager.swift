//
//  HierarchyGraphManager.swift
//  HierarchyUI_Example
//
//  Created by Ihor Demchenko on 10.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import Foundation

internal final class HierarchyGraphManager {
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
            if let previousRoute = anchorRoute.previousRoute {
                scannedRoute = previousRoute
            } else if let parentRoute = anchorRoute.parentContainerRoute, parentRoute.type.hasChildViewRoutes {
                scannedRoute = parentRoute.previousRoute
            }
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
                // It means that we're moving to node which is wrapped in container(like TabBar).
                // Usually its the case for pop from Tab Bar to previous route.
                case .screen where nextRoute.parentContainerRoute != nil:
                    currentChildRoutes[currentHierarchy.currentlySelectedIndex] = WR(nextRoute)
                    self.currentGraphState = .routesTree(
                        rootRoute: currentRootRoute,
                        routes: currentChildRoutes
                    )
                case .screen:
                    self.currentGraphState = .singleRoute(
                        route: WR(nextRoute)
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

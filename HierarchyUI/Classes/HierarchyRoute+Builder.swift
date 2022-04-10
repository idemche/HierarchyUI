//
//  HierarchyRoute+Public.swift
//  HierarchyUI_Example
//
//  Created by Ihor Demchenko on 08.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import Foundation

public extension NavigationHierarchyRoute {
    func pushes(anotherRouteProvider: @escaping () -> NavigationHierarchyRoute) -> NavigationHierarchyRoute {
        assert(nextRoute().isEmpty)
        assert(
            !self.type.hasChildViewRoutes,
            """
                Do not attach navigation properties to view that has child views (e.g. TabBarView).
                Rather control navigation within child views.
            """
        )
        nextRoute = { [weak self] in
            assert(self != nil)
            let anotherRoute: NavigationHierarchyRoute = anotherRouteProvider()
            anotherRoute.previousRoute = self
            anotherRoute.modalParentRoute = self?.modalParentRoute
            anotherRoute.parentContainerRoute = self?.parentContainerRoute
            anotherRoute.rootNavigationRoute = self?.rootNavigationRoute ?? self
            return [anotherRoute.key: anotherRoute]
        }
        return self
    }

    func pushes(anotherRoutesProvider: @escaping () -> [NavigationHierarchyRoute]) -> NavigationHierarchyRoute {
        assert(nextRoute().isEmpty)
        assert(
            !self.type.hasChildViewRoutes,
            """
                Do not attach navigation properties to view that has child views (e.g. TabBarView).
                Rather control navigation within child views.
            """
        )
        nextRoute = { [weak self] in
            assert(self != nil)
            return anotherRoutesProvider().reduce([:]) { (accumulator: [AnyHashable: NavigationHierarchyRoute], route) in
                var accumulator = accumulator
                accumulator[route.key] = route
                route.previousRoute = self
                route.modalParentRoute = self?.modalParentRoute
                route.parentContainerRoute = self?.parentContainerRoute
                route.rootNavigationRoute = self?.rootNavigationRoute ?? self
                return accumulator
            }
        }
        return self
    }

    func modals(anotherModalProvider: @escaping () -> NavigationHierarchyRoute) -> NavigationHierarchyRoute {
        assert(modals().isEmpty)
        assert(
            !self.type.hasChildViewRoutes,
            """
                Do not attach navigation properties to view that has child views (e.g. TabBarView).
                Rather control navigation within child views.
            """
        )
        assert(modalParentRoute == nil, "You cannot present modally inside of the other modal screen.")
        modals = { [weak self] in
            assert(self != nil)
            let anotherRoute: NavigationHierarchyRoute = anotherModalProvider()
            anotherRoute.modalParentRoute = self
            return [anotherRoute.key: anotherRoute]
        }
        return self
    }
    
    func modals(anotherModalProvider: @escaping () -> [NavigationHierarchyRoute]) -> NavigationHierarchyRoute {
        assert(modals().isEmpty)
        assert(
            !self.type.hasChildViewRoutes,
            """
                Do not attach navigation properties to view that has child views (e.g. TabBarView).
                Rather control navigation within child views.
            """
        )
        assert(modalParentRoute == nil, "You cannot present modally inside of the other modal screen.")
        modals = { [weak self] in
            return anotherModalProvider().reduce([:]) { accumulator, route in
                var accumulator = accumulator
                accumulator[route.key] = route
                route.modalParentRoute = self?.parentContainerRoute ?? self
                return accumulator
            }
        }
        return self
    }

    func replaces(anotherReplacerProvider: @escaping () -> NavigationHierarchyRoute) -> NavigationHierarchyRoute {
        assert(replacers().isEmpty)
        assert(
            !self.type.hasChildViewRoutes,
            """
                Do not attach navigation properties to view that has child views (e.g. TabBarView).
                Rather control navigation within child views.
            """
        )
        replacers = {
            let anotherReplacer: NavigationHierarchyRoute = anotherReplacerProvider()
            return [anotherReplacer.key: anotherReplacer]
        }
        return self
    }

    func replaces(anotherReplacerProvider: @escaping () -> [NavigationHierarchyRoute]) -> NavigationHierarchyRoute {
        assert(replacers().isEmpty)
        assert(
            !self.type.hasChildViewRoutes,
            """
                Do not attach navigation properties to view that has child views (e.g. TabBarView).
                Rather control navigation within child views.
            """
        )
        replacers = {
            return anotherReplacerProvider().reduce([:]) { accumulator, route in
                var accumulator = accumulator
                accumulator[route.key] = route
                route.previousRoute = nil
                return accumulator
            }
        }
        return self
    }
}

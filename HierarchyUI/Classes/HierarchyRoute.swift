//
//  HierarchyRoute.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 04.04.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import SwiftUI

extension NavigationHierarchyRoute: Equatable {
    public static func == (lhs: NavigationHierarchyRoute, rhs: NavigationHierarchyRoute) -> Bool {
        return lhs.key == rhs.key
    }
}

public final class NavigationHierarchyRoute {

    /// Push stack navigation and management
    /// =======================================================
    internal var previousRoute: NavigationHierarchyRoute?
    internal var nextRoute: () -> [AnyHashable: NavigationHierarchyRoute] = { [:] }
    /// =======================================================

    /// Modals navigation and management
    /// =======================================================
    internal weak var parent: NavigationHierarchyRoute?
    internal var modals: () -> [AnyHashable: NavigationHierarchyRoute] = { [:] }
    /// =======================================================

    /// Replace navigation and management
    /// =======================================================
    internal var replacers: () -> [AnyHashable: NavigationHierarchyRoute] = { [:] }
    /// =======================================================

    /// Storable view provider properties
    /// =======================================================
    internal let key: AnyHashable
    internal let rootViewProvider: () -> AnyView
    /// =======================================================
    
    /// UIKit bridge
    /// =======================================================
    internal weak var parentHostingController: UIViewController?
    /// =======================================================

    internal init<V: View>(key: AnyHashable, root: @escaping () -> V) {
        self.key = key
        self.rootViewProvider = { AnyView(root()) }
    }

    public func pushes(anotherRouteProvider: @escaping () -> NavigationHierarchyRoute) -> NavigationHierarchyRoute {
        assert(nextRoute().isEmpty)
        nextRoute = { [weak self] in
            assert(self != nil)
            let anotherRoute: NavigationHierarchyRoute = anotherRouteProvider()
            anotherRoute.previousRoute = self
            anotherRoute.parent = self?.parent
            return [anotherRoute.key: anotherRoute]
        }
        return self
    }

    public func pushes(anotherRoutesProvider: @escaping () -> [NavigationHierarchyRoute]) -> NavigationHierarchyRoute {
        assert(nextRoute().isEmpty)
        nextRoute = { [weak self] in
            assert(self != nil)
            return anotherRoutesProvider().reduce([:]) { (accumulator: [AnyHashable: NavigationHierarchyRoute], route) in
                var accumulator = accumulator
                accumulator[route.key] = route
                route.previousRoute = self
                route.parent = self?.parent
                return accumulator
            }
        }
        return self
    }
    
    public func modals(anotherModalProvider: @escaping () -> NavigationHierarchyRoute) -> NavigationHierarchyRoute {
        assert(modals().isEmpty)
        assert(parent == nil, "You cannot present modally inside of the other modal screen.")
        modals = { [weak self] in
            assert(self != nil)
            let anotherRoute: NavigationHierarchyRoute = anotherModalProvider()
            anotherRoute.parent = self
            return [anotherRoute.key: anotherRoute]
        }
        return self
    }
    
    public func modals(anotherModalProvider: @escaping () -> [NavigationHierarchyRoute]) -> NavigationHierarchyRoute {
        assert(modals().isEmpty)
        assert(parent == nil, "You cannot present modally inside of the other modal screen.")
        modals = { [weak self] in
            return anotherModalProvider().reduce([:]) { accumulator, route in
                var accumulator = accumulator
                accumulator[route.key] = route
                route.previousRoute = self
                route.parent = self
                return accumulator
            }
        }
        return self
    }
    
    public func replaces(anotherReplacerProvider: @escaping () -> NavigationHierarchyRoute) -> NavigationHierarchyRoute {
        assert(replacers().isEmpty)
        replacers = {
            let anotherReplacer: NavigationHierarchyRoute = anotherReplacerProvider()
            return [anotherReplacer.key: anotherReplacer]
        }
        return self
    }

    public func replaces(anotherReplacerProvider: @escaping () -> [NavigationHierarchyRoute]) -> NavigationHierarchyRoute {
        assert(replacers().isEmpty)
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

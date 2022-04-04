//
//  NavigationHierarchy.swift
//  NavigationUI
//
//  Created by Ihor Demchenko on 03.04.2022.
//

import SwiftUI

public final class NavigationRoute {

    fileprivate var previousRoute: NavigationRoute?
    fileprivate var nextRoute: [AnyHashable: NavigationRoute] = [:]

    fileprivate weak var parent: NavigationRoute?
    fileprivate var modals: [AnyHashable: NavigationRoute] = [:]
    
    fileprivate var replacers: [AnyHashable: NavigationRoute] = [:]

    fileprivate let key: AnyHashable
    fileprivate let rootViewProvider: () -> AnyView
    
    fileprivate weak var parentHostingController: UIViewController?

    internal init<V: View>(key: AnyHashable, root: @escaping () -> V) {
        self.key = key
        self.rootViewProvider = { AnyView(root()) }
    }

    public func pushes(anotherRouteProvider: @escaping () -> NavigationRoute) -> NavigationRoute {
        assert(nextRoute.isEmpty)
        let anotherRoute: NavigationRoute = anotherRouteProvider()
        anotherRoute.previousRoute = self
        anotherRoute.parent = self.parent
        nextRoute = [anotherRoute.key: anotherRoute]
        return self
    }

    public func pushes(anotherRoutesProvider: @escaping () -> [NavigationRoute]) -> NavigationRoute {
        assert(nextRoute.isEmpty)
        for route in anotherRoutesProvider() {
            nextRoute[route.key] = route
            route.previousRoute = self
            route.parent = self.parent
        }
        return self
    }
    
    public func modals(anotherModalProvider: @escaping () -> NavigationRoute) -> NavigationRoute {
        assert(modals.isEmpty)
        assert(parent == nil, "You cannot present modally inside of the other modal screen.")
        let anotherRoute: NavigationRoute = anotherModalProvider()
        modals[anotherRoute.key] = anotherRoute
        recursivelyUpdateModalParents(with: self, to: anotherRoute)
        return self
    }
    
    public func modals(anotherModalProvider: @escaping () -> [NavigationRoute]) -> NavigationRoute {
        assert(modals.isEmpty)
        assert(parent == nil, "You cannot present modally inside of the other modal screen.")
        for route in anotherModalProvider() {
            modals[route.key] = route
            route.previousRoute = self
            recursivelyUpdateModalParents(with: self, to: route)
        }
        return self
    }
    
    public func replaces(anotherReplacerProvider: @escaping () -> NavigationRoute) -> NavigationRoute {
        assert(replacers.isEmpty)
        let anotherReplacer: NavigationRoute = anotherReplacerProvider()
        replacers = [anotherReplacer.key: anotherReplacer]
        return self
    }

    public func replaces(anotherReplacerProvider: @escaping () -> [NavigationRoute]) -> NavigationRoute {
        assert(replacers.isEmpty)
        for route in anotherReplacerProvider() {
            replacers[route.key] = route
        }
        return self
    }

    private func recursivelyUpdateModalParents(with parentRoute: NavigationRoute, to childRoot: NavigationRoute?) {
        if childRoot == nil { return }

        childRoot?.parent = parentRoute
        childRoot?.nextRoute.values.forEach { (route: NavigationRoute) in
            recursivelyUpdateModalParents(with: parentRoute, to: route)
        }
    }
}

public final class NavigationHierarchyRenderer {
    
    private var currentNavigationRoute: NavigationRoute?
    
    private lazy var navigator: Navigator = Navigator(onPush: { [weak self] key in
        guard let self = self else { return assertionFailure() }
        guard let currentNavigationRoute = self.currentNavigationRoute else { return assertionFailure() }

        let nextRouteByKey = key.flatMap { currentNavigationRoute.nextRoute[$0] }
        let nextRouteRandomized = currentNavigationRoute.nextRoute.first?.value
    
        if nextRouteByKey == nil, nextRouteRandomized != nil, currentNavigationRoute.nextRoute.keys.count > 1 {
            assertionFailure(
                """
                "Note that you're trying to invoke navigation.push() without specifying a key.
                That will lead to a random provided screen in navigation stack.
                Avoid as possible any potential undefined behaviour.
                """
            )
        }

        guard let nextRoute = nextRouteByKey ?? nextRouteRandomized else { return assertionFailure() }
        
        self.currentNavigationRoute = nextRoute

        let nextRootView = nextRoute.rootViewProvider().environmentObject(self.navigator)
        let hosting = EventNotifyingHostingController(key: nextRoute.key, rootView: nextRootView).set(onDismiss: { [weak self] in
            guard let self = self else { return assertionFailure() }
            self.currentNavigationRoute = currentNavigationRoute
        })
        
        nextRoute.parentHostingController = hosting
        currentNavigationRoute.parentHostingController?.navigationController?.pushViewController(hosting, animated: true)

    }, onModal: { [weak self] key in
        guard let self = self else { return assertionFailure() }
        guard let currentNavigationRoute = self.currentNavigationRoute else { return assertionFailure() }
        
        let modalRouteByKey = key.flatMap { currentNavigationRoute.modals[$0] }
        let modalRouteRandomized = currentNavigationRoute.modals.first?.value
        
        if modalRouteByKey == nil, modalRouteRandomized != nil, currentNavigationRoute.modals.keys.count > 1 {
            assertionFailure(
                """
                "Note that you're trying to invoke navigation.modal() without specifying a key.
                That will lead to a random modally provided screen.
                Avoid as possible any potential undefined behaviour.
                """
            )
        }
        
        guard let modalRoute = modalRouteByKey ?? modalRouteRandomized else { return assertionFailure() }
        
        let view = modalRoute.rootViewProvider().environmentObject(self.navigator)
        let hosting = EventNotifyingHostingController(key: modalRoute.key, rootView: view).set(onDismiss: { [weak self] in
            guard let self = self else { return assertionFailure() }
            self.currentNavigationRoute = currentNavigationRoute
        })
        
        self.currentNavigationRoute = modalRoute
        
        modalRoute.parentHostingController = hosting

        if !modalRoute.nextRoute.isEmpty {
            let navigation = UINavigationController(rootViewController: hosting)
            currentNavigationRoute.parentHostingController?.present(navigation, animated: true)
        } else {
            currentNavigationRoute.parentHostingController?.present(hosting, animated: true)
        }

    }, onPop: { [weak self] key in
        guard let self = self else { return assertionFailure() }
        guard let currentNavigationRoute = self.currentNavigationRoute else { return assertionFailure() }
        
        /// Find route
        var scannedRoute: NavigationRoute? = currentNavigationRoute.previousRoute
        while let key = key, scannedRoute?.key != key, scannedRoute != nil {
            scannedRoute = scannedRoute?.previousRoute
        }
        guard let previousRoute = scannedRoute else { return assertionFailure() }

        self.currentNavigationRoute = previousRoute
        
        if let key = key { /// Find ViewController and pop to it if key is provided
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
        } else { /// Pop to previous VC
            currentNavigationRoute
                .parentHostingController?
                .navigationController?
                .popViewController(animated: true)
        }

    }, onReplace: { [weak self] key in
        guard let self = self else { return assertionFailure() }
        guard let currentNavigationRoute = self.currentNavigationRoute else { return assertionFailure() }

        let nextReplacerByKey = key.flatMap { currentNavigationRoute.replacers[$0] }
        let nextReplacerRandomized = currentNavigationRoute.replacers.first?.value
        
        if nextReplacerByKey == nil, nextReplacerRandomized != nil, currentNavigationRoute.replacers.keys.count > 1 {
            assertionFailure(
                """
                "Note that you're trying to invoke navigation.replace() without specifying a key.
                That will lead to a random provided screen in navigation stack.
                Avoid as possible any potential undefined behaviour.
                """
            )
        }
        
        guard let nextReplacer = nextReplacerByKey ?? nextReplacerRandomized else { return assertionFailure() }
        
        let windowWrapped = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .windows
            .first
        
        guard let window = windowWrapped else { return assertionFailure() }
        
        nextReplacer.previousRoute = nil
        self.currentNavigationRoute = nextReplacer
        
        let view = nextReplacer.rootViewProvider().environmentObject(self.navigator)
        let hosting = EventNotifyingHostingController(key: nextReplacer.key, rootView: view)
        
        if !nextReplacer.nextRoute.isEmpty {
            let navigation = UINavigationController(rootViewController: hosting)
            window.rootViewController = navigation
        } else {
            window.rootViewController = hosting
        }
        
        nextReplacer.parentHostingController = hosting

    }, onDismiss: { [weak self] in
        guard let self = self else { return assertionFailure() }
        guard let currentNavigationRoute = self.currentNavigationRoute else { return assertionFailure() }
        guard let parent = currentNavigationRoute.parent else { return assertionFailure() }
        
        currentNavigationRoute.parentHostingController?.dismiss(animated: true) { [weak self] in
            guard let self = self else { return assertionFailure() }
            self.currentNavigationRoute = parent
        }
    })

    public func render(hierarchy: Hierarchy) -> some UIViewController {
        let currentRoute = hierarchy.structure()
        let rootView = currentRoute.rootViewProvider().environmentObject(navigator)
        let rootViewController = EventNotifyingHostingController(key: currentRoute.key, rootView: rootView)
        let rootNavigationController = UINavigationController(rootViewController: rootViewController)
        self.currentNavigationRoute = currentRoute
        currentRoute.parentHostingController = rootViewController
        return rootNavigationController
    }
}

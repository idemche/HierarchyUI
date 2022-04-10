//
//  TabBarHierarchy.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 08.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import UIKit
import SwiftUI

struct TabBarHierarchyTabProperties {
    let item: UITabBarItem
    let route: NavigationHierarchyRoute
}

public final class TabBarHierarchy {
    internal let key: AnyHashable
    internal var tabs: [TabBarHierarchyTabProperties] = []
    
    private let maxAvailableTabs: Int = 6

    internal var currentlySelectedIndex: Int = 0

    internal var currentTabRoute: NavigationHierarchyRoute {
        return self.tabs[currentlySelectedIndex].route
    }

    /// Creates an instance of TabBarHierarchy builder.
    /// - Parameters:
    ///   - key: Key which identifies constructed TabBar in navigation hierarchy.
    ///   - initialTabIndex: The index of the TabBar associated with the initially selected tab item.
    public init(
        key: AnyHashable,
        initialTabIndex: Int = .zero
    ) {
        self.key = key
        self.currentlySelectedIndex = initialTabIndex
    }

    /// Adds a tab to TabBar builder with corresponding TabBarItem parameters.
    /// - Parameters:
    ///   - title: TabBarItem title.
    ///   - imageName: TabBarItem imageName. Will be initialized as UIImage.
    ///   - selectedImageName: TabBarItem selectedImageName. Will be initialized as UIImage.
    ///   - routeProvider: Closure which provides a `Route` which is going to be embedded as tab.
    /// - Returns: a `Self` instance which is `TabBarHierarchy`.
    public func tab(
        title: String? = nil,
        imageName: String? = nil,
        selectedImageName: String? = nil,
        routeProvider: @escaping () -> NavigationHierarchyRoute
    ) -> Self {
        self.tabs.append(
            TabBarHierarchyTabProperties(
                item: .init(
                    title: title,
                    image: imageName.flatMap(UIImage.init),
                    selectedImage: selectedImageName.flatMap(UIImage.init)
                ),
                route: routeProvider()
            )
        )
        return self
    }

    /// Adds a tab to TabBar builder with corresponding TabBarItem parameters.
    /// - Parameters:
    ///   - tabBarSystemItem: Constants that represent the system tab bar items.
    ///   - routeProvider: Closure which provides a `Route` which is going to be embedded as tab.
    /// - Returns: a `Self` instance which is `TabBarHierarchy`.
    public func tab(
        tabBarSystemItem: UITabBarItem.SystemItem,
        routeProvider: @escaping () -> NavigationHierarchyRoute
    ) -> Self {
        self.tabs.append(
            TabBarHierarchyTabProperties(
                item: UITabBarItem(tabBarSystemItem: tabBarSystemItem, tag: .zero),
                route: routeProvider()
            )
        )
        return self
    }

    /// Creates a `HierarchyRoute` out of provided tabs.
    /// - Returns: constructed TabBar `HierarchyRoute.
    public func build() -> NavigationHierarchyRoute {
        assert(
            currentlySelectedIndex < tabs.endIndex,
            """
            Selected TabBar index is bigger than tabs quantity.
            TabBar selectedIndex will be reset to zero.
            """
        )
        assert(tabs.count < maxAvailableTabs, "Tabs count cannot exceed \(maxAvailableTabs) for now.")
        return NavigationHierarchyRoute(
            key: key,
            type: .tabBar(hierarchy: self)
        )
    }
}

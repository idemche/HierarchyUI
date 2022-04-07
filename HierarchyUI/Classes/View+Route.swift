//
//  View+Route.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 04.04.2022.
//

import SwiftUI

public extension View {
    public func route<Key: Hashable>(key: Key) -> NavigationHierarchyRoute {
        return NavigationHierarchyRoute(key: key, root: { AnyView(self) })
    }
}

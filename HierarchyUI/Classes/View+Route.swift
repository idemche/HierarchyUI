//
//  View+Route.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 04.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import SwiftUI

public extension View {
    func route<Key: Hashable>(key: Key) -> NavigationHierarchyRoute {
        return NavigationHierarchyRoute(key: key, type: .screen(provider: { AnyView(self) }))
    }
}

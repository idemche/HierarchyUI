//
//  View+Route.swift
//  NavigationUI
//
//  Created by Ihor Demchenko on 04.04.2022.
//

import SwiftUI

extension View {
    func route<Key: Hashable>(key: Key) -> NavigationRoute {
        return NavigationRoute(key: key, root: { AnyView(self) })
    }
}

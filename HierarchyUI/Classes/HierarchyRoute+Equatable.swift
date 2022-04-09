//
//  HierarchyRoute+Equatable.swift
//  HierarchyUI_Example
//
//  Created by Ihor Demchenko on 09.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import Foundation

extension NavigationHierarchyRoute: Equatable {
    public static func == (lhs: NavigationHierarchyRoute, rhs: NavigationHierarchyRoute) -> Bool {
        return lhs.key == rhs.key
    }
}

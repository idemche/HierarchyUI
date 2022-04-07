//
//  NavigationHierarchy.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 04.04.2022.
//

import Foundation

public protocol NavigationHierarchy {
    func structure() -> NavigationHierarchyRoute
}

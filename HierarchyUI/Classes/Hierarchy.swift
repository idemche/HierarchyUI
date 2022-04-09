//
//  NavigationHierarchy.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 04.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import Foundation

public protocol NavigationHierarchy {
    func structure() -> NavigationHierarchyRoute
}

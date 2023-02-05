//
//  HierarchyDecorator.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 04.02.2023.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import SwiftUI

public final class HierarchyDecorator: ObservableObject {
    private let onProvideNavigationController: () -> UINavigationController?

    init(onProvideNavigationController: @escaping () -> UINavigationController?) {
        self.onProvideNavigationController = onProvideNavigationController
    }

    public func decorate(navigationControllerProvider: (UINavigationController?) -> Void) {
        navigationControllerProvider(onProvideNavigationController())
    }
}

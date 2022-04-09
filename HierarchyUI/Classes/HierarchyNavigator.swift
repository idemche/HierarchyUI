//
//  HierarchyNavigator.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 04.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import SwiftUI

public final class HierarchyNavigator: ObservableObject {
    private let onNavigationEvent: (NavigationHierarchyNavigationEvent) -> Void
    
    init(onNavigationEvent: @escaping (NavigationHierarchyNavigationEvent) -> Void) {
        self.onNavigationEvent = onNavigationEvent
    }

    public func push(key: AnyHashable? = nil, settings: PushSettings = .default) {
        self.onNavigationEvent(.push(key: key, settings: settings))
    }
    
    public func modal(key: AnyHashable? = nil, settings: ModalSettings = .default) {
        self.onNavigationEvent(.modal(key: key, settings: settings))
    }
    
    public func pop(key: AnyHashable? = nil) {
        self.onNavigationEvent(.pop(key: key))
    }
    
    public func replace(key: AnyHashable? = nil) {
        self.onNavigationEvent(.replace(key: key))
    }
    
    public func dismiss() {
        self.onNavigationEvent(.dismiss)
    }
}

//
//  HierarchyNavigator.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 04.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import SwiftUI

public struct PushSettings {
    public var hidesBottomBarWhenPushed: Bool
    public static let `default`: PushSettings = .init(hidesBottomBarWhenPushed: false)
}

public struct ModalSettings {
    public var isFullscreen: Bool
    public static let `default`: ModalSettings = .init(isFullscreen: false)
}

enum NavigationHierarchyNavigationEvent {
    case push(key: AnyHashable?, settings: PushSettings = .default)
    case pop(key: AnyHashable?)
    case popToRoot
    case modal(key: AnyHashable?, settings: ModalSettings = .default)
    case replace(key: AnyHashable?)
    case dismiss
}

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
    
    public func popToRoot() {
        self.onNavigationEvent(.popToRoot)
    }
    
    public func replace(key: AnyHashable? = nil) {
        self.onNavigationEvent(.replace(key: key))
    }
    
    public func dismiss() {
        self.onNavigationEvent(.dismiss)
    }
}

//
//  HierarchyNavigator.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 04.04.2022.
//

import SwiftUI

public final class HierarchyNavigator: ObservableObject {
    private let onPush: (AnyHashable?) -> Void
    private let onModal: (AnyHashable?) -> Void
    private let onPop: (AnyHashable?) -> Void
    private let onReplace: (AnyHashable?) -> Void
    private let onDismiss: () -> Void
    
    init(
        onPush: @escaping (AnyHashable?) -> Void,
        onModal: @escaping (AnyHashable?) -> Void,
        onPop: @escaping (AnyHashable?) -> Void,
        onReplace: @escaping (AnyHashable?) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.onPush = onPush
        self.onModal = onModal
        self.onPop = onPop
        self.onReplace = onReplace
        self.onDismiss = onDismiss
    }

    public func push(key: AnyHashable? = nil) {
        onPush(key)
    }
    
    public func modal(key: AnyHashable? = nil) {
        onModal(key)
    }
    
    public func pop(key: AnyHashable? = nil) {
        onPop(key)
    }
    
    public func replace(key: AnyHashable? = nil) {
        onReplace(key)
    }
    
    public func dismiss() {
        onDismiss()
    }
}

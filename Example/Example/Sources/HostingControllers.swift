//
//  HostingControllers.swift
//  NavigationUI
//
//  Created by Ihor Demchenko on 04.04.2022.
//

import SwiftUI

final class EventNotifyingHostingController: KeyHoldableHostingController {
    
    private var isBeingDismissedState: Bool {
        return isBeingDismissed || navigationController?.isBeingDismissed == true
    }
    
    private var onDismiss: (() -> Void)?

    func set(onDismiss: @escaping () -> Void) -> Self {
        self.onDismiss = onDismiss
        return self
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isMovingFromParent || isBeingDismissedState {
            onDismiss?()
        }
    }
}


class KeyHoldableHostingController: UIHostingController<AnyView> {
    let key: AnyHashable
    init<V: View>(key: AnyHashable, rootView: V) {
        self.key = key
        super.init(rootView: AnyView(rootView))
    }
    
    @MainActor
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

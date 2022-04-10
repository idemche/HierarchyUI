//
//  EventNotifyingControllerProxy.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 08.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import UIKit

/// Describes ViewControllers which listen to their own Navigation Events (e.g. dismissal).
internal protocol NavigationEventNotifyingController where Self: UIViewController {
    
    var onPopEvent: (() -> Void)? { get }
    var onPopToRootEvent: (() -> Void)? { get }
    var onPopToViewControllerEvent: (() -> Void)? { get }
    
    var onDismissEvent: (() -> Void)? { get }
    
    func set(onPopEvent: @escaping () -> Void) -> Self
    func set(onPopToRootEvent: @escaping () -> Void) -> Self
    func set(onPopToViewControllerEvent: @escaping () -> Void) -> Self
    
    func set(onDismissEvent: @escaping () -> Void) -> Self
}

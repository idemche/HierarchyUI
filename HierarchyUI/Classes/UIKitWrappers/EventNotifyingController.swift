//
//  EventNotifyingController.swift
//  HierarchyUI_Example
//
//  Created by Ihor Demchenko on 08.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import Foundation
import UIKit

/// Describes ViewControllers which listen to their own Navigation Events (e.g. dismissal).
internal protocol NavigationEventNotifyingController where Self: UIViewController {
    func set(onDismiss: @escaping () -> Void) -> Self
}

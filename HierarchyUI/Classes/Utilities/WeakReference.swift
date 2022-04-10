//
//  WeakReference.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 09.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import Foundation

final class WeakReference<T: AnyObject> {
    weak var reference: T?
    
    init(_ reference: T?) {
        self.reference = reference
    }
}

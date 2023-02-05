//
//  NavigationControllerProxy.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 10.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import UIKit

extension UINavigationController {
    var asLocalNavigationControllerProxy: NavigationControllerProxy? {
        guard let self = self as? NavigationControllerProxy else {
            assertionFailure("NavigationControllerProxy was constructed with common UINavigationControllerProxy class.")
            return nil
        }
        return self
    }
}

final class NavigationControllerProxy: UINavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        presentationController?.delegate = self
        navigationBar.prefersLargeTitles = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func manuallyPopViewController(animated: Bool = true) {
        _ = super.popViewController(animated: animated)
    }
    
    func manuallyPopToRootViewController(animated: Bool = true) {
        _ = super.popToRootViewController(animated: animated)
    }
    
    func manuallyPopToViewController(by key: AnyHashable, animated: Bool = true) {
        let scannedViewController = viewControllers
            .first { (viewController: UIViewController) in
                if let viewController = viewController as? NavigationManagingHostingControllerProxy {
                    return viewController.associatedRouteReference.key == key
                }
                return false
            }

        guard let viewController = scannedViewController else {
            return assertionFailure(
                "Haven't found ViewController with corresponding key while popping to it."
            )
        }

        super.popToViewController(viewController, animated: true)
    }

    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if let eventNotifyingController = topViewController as? NavigationEventNotifyingController {
            eventNotifyingController.onPopToRootEvent?()
        }
        return super.popToRootViewController(animated: animated)
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        if let eventNotifyingController = topViewController as? NavigationEventNotifyingController {
            eventNotifyingController.onPopEvent?()
        }
        return super.popViewController(animated: animated)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if let eventNotifyingController = topViewController as? NavigationEventNotifyingController {
            eventNotifyingController.onPopToViewControllerEvent?()
        }
        return super.popToViewController(viewController, animated: animated)
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: true)
    }
}

extension NavigationControllerProxy: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        let dismissEventListeningControllerWrapped = viewControllers
            .compactMap { $0 as? NavigationEventNotifyingController }
            .first { $0.onDismissEvent != nil }
        guard let dismissEventListeningController = dismissEventListeningControllerWrapped else {
            return assertionFailure("No listening controller found for dismiss event.")
        }
        dismissEventListeningController.onDismissEvent?()
    }
}

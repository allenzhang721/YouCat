//
//  ThemeNavigationTransition.swift
//  YouCat
//
//  Created by Emiaostein on 2019/7/6.
//  Copyright © 2019 Curios. All rights reserved.
//

import UIKit

class ThemeNavigationTransition: NSObject, UINavigationControllerDelegate {
    
    var startPresentY: CGFloat?
    var startPresentMaskFrame: CGRect?
    var startPresentHandler:(()->())?
    var finalPresentHandler:(()->())?
    var presentDidEndHanlder:(()->())?
    var startDismissHandler:(()->())?
    var finalDismissHandler:(()->())?
    var dismissDidEndHanlder:(()->())?
    var finalDismissY: CGFloat?
    var finalDismissMaskFrame: CGRect?

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        print("will show =", viewController)
        
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        print("did show =", viewController)
        
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let presenting = operation == .push
//        print("presenting =", presenting, "maskFrame =", presenting ?)
        let animator = ThemeTransitionAnimator(presenting: presenting)
        if (presenting) {
            animator.startPresentHandler = startPresentHandler
            animator.finalPresentHandler = finalPresentHandler
            animator.startPresentY = startPresentY
            animator.startPresentMaskFrame = startPresentMaskFrame
            animator.finalDismissMaskFrame = finalDismissMaskFrame
            animator.presentDidEndHanlder = presentDidEndHanlder
        } else {
//            return nil;
            animator.startDismissHandler = startDismissHandler
            animator.finalDismissHandler = finalDismissHandler
            animator.finalDismissY = finalDismissY
            animator.finalDismissMaskFrame = finalDismissMaskFrame
            animator.dismissDidEndHanlder = dismissDidEndHanlder
        }
        
        
        return animator
        
    }
}

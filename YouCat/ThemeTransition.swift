//
//  ThemeTransition.swift
//  YouCat
//
//  Created by Emiaostein on 2019/6/24.
//  Copyright © 2019 Curios. All rights reserved.
//

// https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/CustomizingtheTransitionAnimations.html

import UIKit

class YCThemeTransition: NSObject, UIViewControllerTransitioningDelegate {
    
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
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let animator = ThemeTransitionAnimator(presenting: true)
        animator.startPresentHandler = startPresentHandler
        animator.finalPresentHandler = finalPresentHandler
        animator.startPresentY = startPresentY
        animator.startPresentMaskFrame = startPresentMaskFrame
        animator.presentDidEndHanlder = presentDidEndHanlder
        
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let animator = ThemeTransitionAnimator(presenting: false)
        animator.startDismissHandler = startDismissHandler
        animator.finalDismissHandler = finalDismissHandler
        animator.finalDismissY = finalDismissY
        animator.finalDismissMaskFrame = finalDismissMaskFrame
        animator.dismissDidEndHanlder = dismissDidEndHanlder
        
        return animator
    }
}

class ThemeTransitionAnimator:NSObject, UIViewControllerAnimatedTransitioning {
    
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
    
    let presenting: Bool
    init(presenting: Bool) {
        self.presenting = presenting
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.7;
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch presenting {
        case true:
            present(context: transitionContext)
        default:
            dismiss(context: transitionContext)
        }
    }
    
    private func present(context: UIViewControllerContextTransitioning) {
        // Get the set of relevant objects.
        let containerView = context.containerView
        let toVC = context.viewController(forKey: .to)!
        let fromVC = context.viewController(forKey: .from)!
        let toView = context.view(forKey: .to)!
        
//        let tabbarView = fromVC.parent?.tabBarController?.tabBar.snapshotView(afterScreenUpdates: true)!
        
        // Set up some variables for the animation.
        let containerFrame = containerView.frame
        var toViewStartFrame = context.initialFrame(for: toVC)
        let toViewFinalFrame = context.finalFrame(for: toVC)
        
        // Set up the animation parameters.
            // Modify the frame of the presented view so that it starts
            // offscreen at the lower-right corner of the container.
//            toViewStartFrame.origin.x = containerFrame.size.width;
//            toViewStartFrame.origin.y = containerFrame.size.height;
        toViewStartFrame.origin.y = startPresentY ?? 60
        toViewStartFrame.size = containerFrame.size
        
        
        // Always add the "to" view to the container.
        // And it doesn't hurt to set its start frame.
        containerView.addSubview(toView);
        toView.frame = toViewStartFrame;
        
//        containerView.addSubview(tabbarView!)
        
        if let st = startPresentMaskFrame {
//            let wGap = YCScreen.bounds.width * 0.06
            let maskview = UIView(frame: st)
            maskview.backgroundColor = .blue
            maskview.layer.cornerRadius = 14
            toView.mask = maskview
        }
        
        startPresentHandler?()
        
        
        
        // Animate using the animator's own duration value.
        let duration = self.transitionDuration(using: context)
        
//        UIView.animate(withDuration: duration, animations: {
//            toView.frame = toViewFinalFrame
//            toView.mask?.frame = toView.bounds
//            toView.mask?.layer.cornerRadius = 0
//            self.finalPresentHandler?()
//        }) { (finished) in
//            context.completeTransition(true)
//        }
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveEaseOut], animations: {
            toView.frame = toViewFinalFrame
            toView.mask?.frame = toView.bounds
            toView.mask?.layer.cornerRadius = 0
            fromVC.tabBarController?.tabBar.frame.origin.y = YCScreen.bounds.height
//            fromVC.tabBarController?.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
            
            self.finalPresentHandler?()
        }) { (finished) in
            self.presentDidEndHanlder?()
            context.completeTransition(true)
            fromVC.tabBarController?.tabBar.alpha = 0
        }
        
    }
    
    private func dismiss(context: UIViewControllerContextTransitioning) {
        // Get the set of relevant objects.
        let containerView = context.containerView
        let fromVC = context.viewController(forKey: .from)! as! YCThemeDetailViewController
        let fromView = context.view(forKey: .from)!
        let toView = context.view(forKey: .to)!

        // Set up some variables for the animation.
        let containerFrame = containerView.frame
        let fromViewStartFrame = context.initialFrame(for: fromVC)
        var fromViewFinalFrame = context.finalFrame(for: fromVC)

            // Modify the frame of the dismissed view so it ends in
            // the lower-right corner of the container view.
        fromViewFinalFrame = CGRect(x: containerFrame.size.width,
                                    y: containerFrame.size.height,
                                    width: fromView.frame.size.width,
                                    height: fromView.frame.size.height);


        // Always add the "to" view to the container.
        // And it doesn't hurt to set its start frame.
//        containerView.addSubview(toView);
        fromView.frame = fromViewStartFrame;
        startDismissHandler?()

        // Animate using the animator's own duration value.
        let duration = self.transitionDuration(using: context)
//        let wGap = YCScreen.bounds.width * 0.06
        let finalFrame = finalDismissMaskFrame!
        let finalFrameY = finalDismissY ?? fromViewFinalFrame.minY
//        UIView.animate(withDuration: duration, animations: {
//
//            fromView.frame.origin.y = finalFrameY
//            if let mask = fromView.mask {
//                mask.frame = finalFrame
//                mask.layer.cornerRadius = 14
//            }
//            self.finalDismissHandler?()
//
//        }) { (finished) in
//            let success = context.transitionWasCancelled
////            if (presenting && !success) || (!presenting && success) {
//                fromView.removeFromSuperview()
////            }
//
//            context.completeTransition(true)
//        }
        containerView.insertSubview(toView, at: 0)
        
        let v = UIView(frame: fromViewStartFrame)
        v.backgroundColor = UIColor.white
        v.layer.cornerRadius = 14
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowColor = YCStyleColor.black.cgColor
        v.layer.shadowOpacity = 0.1
        v.layer.shadowRadius = 8
        
        let v1 = UIView(frame: fromViewStartFrame)
        v1.backgroundColor = UIColor.white
        v1.layer.cornerRadius = 14
        v1.layer.shadowOffset = CGSize(width: 0, height: 15)
        v1.layer.shadowColor = YCStyleColor.black.cgColor
        v1.layer.shadowOpacity = 0.2
        v1.layer.shadowRadius = 8
        
        containerView.insertSubview(v1, aboveSubview: toView)
        containerView.insertSubview(v, aboveSubview: v1)
        
//        let topview = fromVC.topView
//        topview.removeFromSuperview()
        
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: {
            fromView.frame.origin.y = finalFrameY
            if let mask = fromView.mask {
                mask.frame = finalFrame
                mask.layer.cornerRadius = 14
                
            }
            v.frame.origin.y = finalFrameY + finalFrame.origin.y
            v.frame.origin.x = finalFrame.origin.x
            v.frame.size = finalFrame.size
            
            v1.frame = v.frame.insetBy(dx: v.frame.width * 0.05, dy: v.frame.width * 0.05)
            
//            fromVC.tabBarController?.tabBar.transform = .identity
            if let tabBar = fromVC.tabBarController?.tabBar{
                tabBar.frame.origin.y = YCScreen.bounds.height - tabBar.frame.height
                tabBar.alpha = 1
            }
            self.finalDismissHandler?()
        }) { (finished) in
            v1.removeFromSuperview()
            v.removeFromSuperview()
            self.dismissDidEndHanlder?()
            
            context.completeTransition(true)
        }
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        print(#function)
    }
}

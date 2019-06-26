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
    var startDismissHandler:(()->())?
    var finalDismissHandler:(()->())?
    var finalDismissY: CGFloat?
    var finalDismissMaskFrame: CGRect?
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let animator = ThemeTransitionAnimator(presenting: true)
        animator.startPresentHandler = startPresentHandler
        animator.finalPresentHandler = finalPresentHandler
        animator.startPresentY = startPresentY
        animator.startPresentMaskFrame = startPresentMaskFrame
        
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let animator = ThemeTransitionAnimator(presenting: false)
        animator.startDismissHandler = startDismissHandler
        animator.finalDismissHandler = finalDismissHandler
        animator.finalDismissY = finalDismissY
        animator.finalDismissMaskFrame = finalDismissMaskFrame
        
        return animator
    }
    
}

class ThemeTransitionAnimator:NSObject, UIViewControllerAnimatedTransitioning {
    
    var startPresentY: CGFloat?
    var startPresentMaskFrame: CGRect?
    var startPresentHandler:(()->())?
    var finalPresentHandler:(()->())?
    var startDismissHandler:(()->())?
    var finalDismissHandler:(()->())?
    var finalDismissY: CGFloat?
    var finalDismissMaskFrame: CGRect?
    
    let presenting: Bool
    init(presenting: Bool) {
        self.presenting = presenting
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3;
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
        let toView = context.view(forKey: .to)!
        
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
        UIView.animate(withDuration: duration, animations: {
            toView.frame = toViewFinalFrame
            toView.mask?.frame = toView.bounds
            toView.mask?.layer.cornerRadius = 0
            self.finalPresentHandler?()
        }) { (finished) in
            context.completeTransition(true)
        }
    }
    
    private func dismiss(context: UIViewControllerContextTransitioning) {
        // Get the set of relevant objects.
        let containerView = context.containerView
        let fromVC = context.viewController(forKey: .from)!
        let fromView = context.view(forKey: .from)!

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
        let wGap = YCScreen.bounds.width * 0.06
        let finalFrame = finalDismissMaskFrame!
        let finalFrameY = finalDismissY ?? fromViewFinalFrame.minY
        UIView.animate(withDuration: duration, animations: {

            fromView.frame.origin.y = finalFrameY
            if let mask = fromView.mask {
                mask.frame = finalFrame
                mask.layer.cornerRadius = 14
            }
            self.finalDismissHandler?()

        }) { (finished) in
            let success = context.transitionWasCancelled
//            if (presenting && !success) || (!presenting && success) {
                fromView.removeFromSuperview()
//            }

            context.completeTransition(true)
        }
    }
}

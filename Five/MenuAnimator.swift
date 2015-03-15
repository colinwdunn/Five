//
//  MenuAnimator.swift
//  Five
//
//  Created by Colin Dunn on 1/17/15.
//  Copyright (c) 2015 Colin Dunn. All rights reserved.
//

import UIKit

class MenuAnimator: NSObject {
    var isPresenting = false
}

extension MenuAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()
        var controller:UIViewController
        var transform:CGAffineTransform
        
        if isPresenting {
            controller = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            controller.view.transform = CGAffineTransformMakeTranslation(0, 225)
            transform = CGAffineTransformIdentity
        } else {
            controller = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
            transform = CGAffineTransformMakeTranslation(0, 225)
        }
        
        container.addSubview(controller.view)
        
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 15, options: nil, animations: { () -> Void in
            controller.view.transform = transform
            }) { (finished) -> Void in
                if transitionContext.transitionWasCancelled() {
                    transitionContext.completeTransition(false)
                } else {
                    transitionContext.completeTransition(finished)
                }
        }
    }
}

extension MenuAnimator: UIViewControllerTransitioningDelegate {
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        return MenuPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
}
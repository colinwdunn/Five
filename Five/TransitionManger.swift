//
//  TransitionManger.swift
//  CustomTransition
//
//  Created by Colin Dunn on 3/14/15.
//  Copyright (c) 2015 Colin Dunn. All rights reserved.
//

import UIKit

class TransitionManger: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIViewControllerInteractiveTransitioning {
    
    var isPresenting = false
    var interactiveTransition: UIPercentDrivenInteractiveTransition!
    var presentingController: UIViewController! {
        didSet {
            self.panGesture = UIPanGestureRecognizer(target: self, action: "dismissGesture:")
            self.presentingController.view.addGestureRecognizer(self.panGesture)
        }
    }
    
    let dimmingView = UIView()
    
    private var isInteractive = false
    private var pinchGesture = UIPinchGestureRecognizer()
    private var panGesture = UIPanGestureRecognizer()
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        var height = toViewController?.view.frame.height
        dimmingView.frame = (toViewController?.view.frame)!
        dimmingView.backgroundColor = textColor
        
        if isPresenting {
            containerView.addSubview(dimmingView)
            containerView.addSubview(toViewController!.view)
            toViewController?.view.frame.origin.y = height!
            dimmingView.alpha = 0
            
            UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 8, options: nil, animations: { () -> Void in
                toViewController?.view.frame.origin.y = 0
                self.dimmingView.alpha = 0.5
            }, completion: { (Bool) -> Void in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 8, options: nil, animations: { () -> Void in
                self.dimmingView.alpha = 0
                fromViewController?.view.frame.origin.y = height!
            }, completion: { (Bool) -> Void in
                transitionContext.completeTransition(true)
                fromViewController?.view.removeFromSuperview()
            })
        }
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.3
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        interactiveTransition = UIPercentDrivenInteractiveTransition()
        return isInteractive ? self : nil
    }
    
    func dismissGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(sender.view!)
        let delta = translation.y / CGRectGetHeight(sender.view!.bounds) * 0.25
        
        switch (sender.state) {
        case UIGestureRecognizerState.Began:
            isInteractive = true
            presentingController.dismissViewControllerAnimated(true, completion: nil)
            break
            
        case UIGestureRecognizerState.Changed:
            updateInteractiveTransition(delta)
            break
            
        default:
            isInteractive = false
            finishInteractiveTransition()
        }
    }
}

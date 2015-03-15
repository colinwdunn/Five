//
//  MenuPresentationController.swift
//  Five
//
//  Created by Colin Dunn on 1/17/15.
//  Copyright (c) 2015 Colin Dunn. All rights reserved.
//

import UIKit

class MenuPresentationController: UIPresentationController {
    
    lazy var dimmingView:UIView = {
        let view = UIView(frame: self.containerView!.bounds)
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        view.alpha = 0.0
        return view
        }()
    
    override func presentationTransitionWillBegin() {
        // Add the dimming view and the presented view to the heirarchy
        dimmingView.frame = containerView.bounds
        containerView.addSubview(dimmingView)
        containerView.addSubview(presentedView())
        
        // Fade in the dimming view alongside the transition
        let transitionCoordinator = presentingViewController.transitionCoordinator()
        transitionCoordinator!.animateAlongsideTransition({(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.dimmingView.alpha  = 1.0
            }, completion:nil)
    }
    
    override func presentationTransitionDidEnd(completed: Bool) {
        if !completed {
            self.dimmingView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        let transitionCoordinator = self.presentingViewController.transitionCoordinator()
        transitionCoordinator!.animateAlongsideTransition({(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.dimmingView.alpha  = 0.0
            }, completion:nil)
    }
    
    override func dismissalTransitionDidEnd(completed: Bool) {
        if completed {
            self.dimmingView.removeFromSuperview()
        }
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        let height = CGRectGetHeight(containerView.bounds)
        return CGRect(x: 0.0, y: height, width: CGRectGetWidth(self.containerView.bounds), height: CGRectGetHeight(self.containerView.bounds)-height)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator transitionCoordinator: UIViewControllerTransitionCoordinator) {
        self.viewWillTransitionToSize(size, withTransitionCoordinator: transitionCoordinator)
        
        transitionCoordinator.animateAlongsideTransition({(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.dimmingView.frame = self.containerView.bounds
            }, completion:nil)
    }
    
}

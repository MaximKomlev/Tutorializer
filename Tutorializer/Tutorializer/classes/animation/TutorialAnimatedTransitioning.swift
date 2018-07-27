//
//  TutorialAnimatedTransitioning.swift
//  Tutorializer
//
//  Created by Maxim Komlev on 7/14/18.
//  Copyright © 2018 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

class TutorialAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: Fields
    
    var _direction: TutorialTransitioningDirection = .right
    var _transition: TutorialSwipeInteractiveTransition?
    
    // MARK: Initializers/Deinitializer
    
    required init(direction: TutorialTransitioningDirection, transition: TutorialSwipeInteractiveTransition? = nil) {
        super.init()
        
        _direction = direction
        _transition = transition
    }
    
    // MARK: Properties
    
    var transitionController: TutorialSwipeInteractiveTransition? {
        get {
            return _transition
        }
    }
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return tutorialAnimatedTransitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }
        
        let originFrame = fromVC.view.frame
        if (self._direction == .right) {
            toVC.view.frame = originFrame.offsetBy(dx: originFrame.width, dy: 0)
        } else if (self._direction == .left) {
            toVC.view.frame = originFrame.offsetBy(dx: -originFrame.width, dy: 0)
        }
        
        let containerView = transitionContext.containerView
        
        let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false)
        if let snapshot = snapshot {
            containerView.addSubview(snapshot)
        }
        
        containerView.addSubview(toVC.view)
        fromVC.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
            if (self._direction == .right) {
                toVC.view.frame = originFrame.offsetBy(dx: 0, dy: 0)
                snapshot?.frame = originFrame.offsetBy(dx: -originFrame.width, dy: 0)
            } else if (self._direction == .left) {
                toVC.view.frame = originFrame.offsetBy(dx: 0, dy: 0)
                snapshot?.frame = originFrame.offsetBy(dx: originFrame.width, dy: 0)
            }
        }) { (success) in
            fromVC.view.isHidden = false
            snapshot?.removeFromSuperview()
            if transitionContext.transitionWasCancelled {
                toVC.view.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
    }
}

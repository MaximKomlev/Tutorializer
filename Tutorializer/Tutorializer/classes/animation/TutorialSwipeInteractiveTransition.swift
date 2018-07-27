//
//  TutorialSwipeInteractiveTransition.swift
//  Tutorializer
//
//  Created by Maxim Komlev on 7/14/18.
//  Copyright © 2018 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

class TutorialSwipeInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    // MARK: Fields
    
    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController!
    
    // MARK: Initializers/Deinitializer
    
    init(viewController: UIViewController, swipeEdge: UIRectEdge) {
        super.init()
        self.viewController = viewController
        initializeGestureRecognizer(in: viewController.view, swipeEdge: swipeEdge)
    }
    
    // MARK: Properties
    
    var interactionInProgress: Bool = false
    
    // MARK: Helpers
    
    private func initializeGestureRecognizer(in view: UIView, swipeEdge: UIRectEdge) {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        gesture.edges = swipeEdge
        view.addGestureRecognizer(gesture)
    }
    
    // MARK: Handlers
    
    @objc func handleGesture(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        var progress = (translation.x / 200)
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        
        switch gestureRecognizer.state {
        case .began:
            interactionInProgress = true
            viewController.dismiss(animated: true, completion: nil)
        case .changed:
            shouldCompleteTransition = progress > 0.5
            update(progress)
        case .cancelled:
            interactionInProgress = false
            cancel()
        case .ended:
            interactionInProgress = false
            if shouldCompleteTransition {
                finish()
            } else {
                cancel()
            }
        default:
            break
        }
    }
}

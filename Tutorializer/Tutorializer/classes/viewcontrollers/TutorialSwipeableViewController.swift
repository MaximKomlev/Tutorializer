//
//  TutorialSwipeableViewController.swift
//  Tutorializer
//
//  Created by Maxim Komlev on 7/20/18.
//  Copyright © 2018 Maxim Komlev. All rights reserved.
//

import Foundation

open class TutorialSwipeableViewController: TutorialViewController {
    
    // MARK: Fields
    
    var _transition: TutorialSwipeInteractiveTransition!

    // MARK: Properties
    
    var transitionController: TutorialSwipeInteractiveTransition {
        get {
            return _transition
        }
    }

    // MARK: Helpers
    
    open override func initializeUI() {
        super.initializeUI()
        
        _transition = TutorialSwipeInteractiveTransition(viewController: self, swipeEdge: .left)
    }
    
}

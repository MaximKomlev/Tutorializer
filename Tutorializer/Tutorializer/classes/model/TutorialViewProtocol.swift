//
//  DescribableView.swift
//  Tutorializer
//
//  Created by Maxim Komlev on 7/14/18.
//  Copyright © 2018 Maxim Komlev. All rights reserved.
//

import Foundation

@objc public protocol TutorialDescribableViewDelegate: NSObjectProtocol {
    var tutorialDelegate: TutorialViewChangingDelegate? { get set }

    func getDescribableEntities() -> Dictionary<String, UIView>
    func convertFrame(to view: UIView?) -> CGRect
    func shapePath(for frame: CGRect) -> CGPath
}

@objc public protocol TutorialViewTransitionDelegate: NSObjectProtocol {
    func transitionComplete()
}

@objc public protocol TutorialViewChangingDelegate: NSObjectProtocol {
    @objc func layoutView()
}

@objc public protocol TutorialViewDataDelegate: NSObjectProtocol {
    @objc func fetchDescribableElement(for tutorialView: TutorialViewProtocol?, complete: @escaping (_ view: UIView?) -> ())
}

@objc public protocol TutorialViewProtocol: TutorialViewTransitionDelegate, TutorialViewChangingDelegate {
    var tutorialViewId: String? { get }

    var tutorialDelegate: TutorialViewDataDelegate? { get set }
    var tutorialView: UIView { get }
    
    var blurAlpha: CGFloat { get set }
    
    func initializeTutorialDescriptions(_ descriptions: Dictionary<String, DescribableElementInfo>)
    func validate(forAttributes attr: Dictionary<String, Any>) -> Bool
}

//
//  TutorialViewController.swift
//  Tutorializer
//
//  Created by Maxim Komlev on 7/16/18.
//  Copyright © 2018 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

open class TutorialViewController: UIViewController, TutorialViewProtocol {
    
    // MARK: Fields
    
    weak var _describableView: UIView?
    var _describableViewSnapshot: UIImageView?

    var _describableViewEntities: Array<(key: String, value: Weak<UIView>)> = []
    
    var _labels: Dictionary<String, UILabel> = [:]
    var _lines: Dictionary<String, CAShapeLayer> = [:]
    
    // config
    var _tutorialDescriptions: Dictionary<String, DescribableElementInfo> = [:]
    
    public lazy var _blurView = TutorialDarkBlurView(frame: CGRect.zero)
    
    // MARK: Initializer/Deinitializer
    
    public required init() {
        super.init(nibName: nil, bundle: nil)
        
        initializeUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.tutorialDelegate = nil
        
        _blurView.removeFromSuperview()
        self.view.removeFromSuperview()
        
        _describableView = nil
        _describableViewSnapshot = nil

        _describableViewEntities.removeAll()
        _tutorialDescriptions.removeAll()
        _labels.removeAll()
        _lines.removeAll()
    }
    
    // MARK: Controller life cycle
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        _blurView.frame = view.bounds
        _blurView.setNeedsLayout()
    }
    
    // MARK: TutorialViewProtocol

    // MARK: Properties

    public weak var tutorialDelegate: TutorialViewPresenterDelegate? = nil

    open var animateAppearance: Bool = true
    
    open var blurAlpha: CGFloat {
        get {
            return _blurView.blurAlpha
        } set (v) {
            _blurView.blurAlpha = v
        }
    }

    open var tutorialView: UIView {
        get {
            return view
        }
    }
    
    // MARK: Methods
    
    open func layoutView() {
        if let v = _describableView {
            if let snapshot = _describableViewSnapshot,
                let rect = v.superview?.convert(v.frame, to: self.view),
                rect.size != snapshot.frame.size {
                snapshot.image = SnapshotView(view: v)
                snapshot.frame = rect
            }
            
            layoutDescriptions(v)
            layoutLines()
        }
    }

    open func initializeTutorialDescriptions(_ descriptions: Dictionary<String, DescribableElementInfo>) {
        _tutorialDescriptions = descriptions
    }

    open func validate(forAttributes attr: Dictionary<String, Any>) -> Bool {
        fatalError("validate(:) has not been implemented")
    }
    
    open func transitionComplete() {
        fatalError("transitionComplete(:) has not been implemented")
    }
    
    // MARK: Helpers
        
    open func initializeUI() {
        self.view.backgroundColor = UIColor.clear
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(_blurView)
    }

    open func initializeDescribableView() {
        if (self.tutorialDelegate != nil) {
            self.tutorialDelegate?.fetchDescribableElement?(complete: { [weak self] (v) in
                if let v = v, self != nil {
                    (v as? TutorialDescribableViewDelegate)?.tutorialDelegate = self
                    self?._describableView = v
                    if let rect = v.superview?.convert(v.frame, to: self!.view) {
                        let snapshot = UIImageView(image: SnapshotView(view: v))
                        snapshot.alpha = 0
                        self?._describableViewSnapshot = snapshot
                        self?._blurView.addSubview(snapshot)
                        snapshot.frame = rect
                        
                        // sort tutorialized sub elements by x
                        self?._describableViewEntities = self!.sortElementsByCoordinates(v)
                        
                        self?.updateDescriptionsOfElements(v)
                        
                        self?.layoutDescriptions(v)
                        
                        self?.drawLines()
                        
                        self?.animateSubviews(views: [snapshot])
                    }
                }
            })
        }
    }

    func updateDescriptionsOfElements(_ forView: UIView) {
        for (key, _) in _describableViewEntities {
            let label = UILabel()
            label.textColor = UIColor.white
            label.font = _tutorialDescriptions[key]?.descriptionFont ?? UIFont.boldSystemFont(ofSize: font_size_label14)
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 0
            label.textAlignment = .left
            label.text = _tutorialDescriptions[key]?.descriptionText
            _labels[key] = label
            _blurView.addSubview(label)
        }
    }
    
    func sortElementsByCoordinates(_ forView: UIView) -> [(key: String, value: Weak<UIView>)] {
        if let elements = (forView as? TutorialDescribableViewDelegate)?.getDescribableEntities() {
            let sortedElements = elements.sorted(by: { (el1, el2) -> Bool in
                return el1.value.frame.origin.x < el2.value.frame.origin.x
            })
            var weakSortedElements: Array<(key: String, value: Weak<UIView>)> = []
            for v in sortedElements {
                weakSortedElements.append((key: v.key, value: Weak(object: v.value)))
            }
            return weakSortedElements
        }
        return []
    }
    
    func layoutDescriptions(_ forView: UIView) {
        if let rect = forView.superview?.convert(forView.frame, to: self.view) {
            let screenMiddle = self.view.frame.height / 2
            let posElement = rect.origin.y
            if (_describableViewEntities.count > 0) {
                if (posElement / screenMiddle < 0.5) {
                    let aggreagtedLabels = aggregateDescriptions(by: .any)
                    layoutBottomDescriptions(for: aggreagtedLabels)
                } else if (posElement / screenMiddle > 5) {
                    let aggreagtedLabels = aggregateDescriptions(by: .any)
                    layoutTopDescriptions(for: aggreagtedLabels)
                } else {
                    let aggreagtedTopLabels = aggregateDescriptions(by: .top)
                    layoutTopDescriptions(for: aggreagtedTopLabels)
                    let aggreagtedBottomLabels = aggregateDescriptions(by: .bottom)
                    layoutBottomDescriptions(for: aggreagtedBottomLabels)
                }
            }
        }
    }
    
    func aggregateDescriptions(by layout: DescribableElementLayout) -> [(key: String, index: Int, label: UILabel, directionLeft: Bool)] {
        
        var leftViews: [(key: String, index: Int, label: UILabel, directionLeft: Bool)] = [] // sorted by x descriptions with z-index
        var range: CGFloat = 0
        
        for v in _describableViewEntities {
            if (_tutorialDescriptions[v.key]?.descriptionPosition == layout || layout == .any) {
                if let label = _labels[v.key] {
                    let tutorialDescriprionWidth = _tutorialDescriptions[v.key]?.descriptionWidth ?? tutorialDescriprionDefaultWidth
                    // calculate size of description
                    let descriptionSize = sizeConstrained(toWidth: tutorialDescriprionWidth, label: label)
                    if (descriptionSize != CGSize.zero) {
                        // calculate x coordinate for tutorialized sub element
                        if let entity = v.value.object, let rect = entity.superview?.convert(entity.frame, to: self.view) {
                            var x = rect.origin.x + 2 * leftRightMargin
                            var directionLeft = true
                            if (x + descriptionSize.width > self.view.frame.width - leftRightMargin) {
                                // for descriptions which have a reversed x we don't need z index
                                x = x - descriptionSize.width - leftRightMargin
                                label.frame = CGRect(origin: CGPoint(x: x, y: 0), size: descriptionSize)
                                directionLeft = false
                            } else {
                                label.frame = CGRect(origin: CGPoint(x: x, y: 0), size: descriptionSize)
                            }
                            
                            // calculate z-index
                            if (leftViews.count == 0) {
                                leftViews.append((key: v.key, index: 0, label: label, directionLeft: directionLeft))
                                range = label.frame.origin.x + label.frame.width
                            } else {
                                let prev = leftViews[leftViews.count - 1]
                                let nextX = label.frame.origin.x
                                if (range + 3 * leftRightMargin >= nextX) {
                                    leftViews.append((key: v.key, index: prev.index + 1, label: label, directionLeft: directionLeft))
                                } else {
                                    leftViews.append((key: v.key, index: 0, label: label, directionLeft: directionLeft))
                                    range = label.frame.origin.x + label.frame.width
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return leftViews
    }
    
    func layoutTopDescriptions(for left: [(key: String, index: Int, label: UILabel, directionLeft: Bool)]) {
        var leftViews = left
        if let snapshot = _describableViewSnapshot {
            var y = snapshot.frame.origin.y - topBottomMargin
            
            var rightIdx = -1
            
            var idx = leftViews.count - 1
            while(idx >= 0) {
                let v = leftViews[idx]
                if (v.directionLeft) {
                    y = y - v.label.frame.height
                    v.label.frame.origin.y = y
                    y -= v.label.frame.height - topBottomMargin
                    if (v.index == 0) {
                        y = snapshot.frame.origin.y - topBottomMargin
                    }
                } else {
                    rightIdx = idx
                }
                idx -= 1
            }
            
            if (rightIdx > -1) {
                let leftIdx = rightIdx - leftViews[rightIdx].index
                y = snapshot.frame.origin.y - topBottomMargin
                if (leftIdx >= 0 && leftIdx != rightIdx) {
                    y = leftViews[leftIdx].label.frame.origin.y - topBottomMargin
                }
                
                idx = rightIdx
                while(idx < leftViews.count) {
                    let v = leftViews[idx]
                    if (v.index == 0 && idx > rightIdx) { // reset
                        y = snapshot.frame.origin.y - topBottomMargin
                    }
                    y = y - v.label.frame.height
                    v.label.frame.origin.y = y
                    y -= v.label.frame.height - topBottomMargin
                    idx += 1
                }
            }
        }
    }
    
    func layoutBottomDescriptions(for left: [(key: String, index: Int, label: UILabel, directionLeft: Bool)]) {
        var leftViews = left
        
        if let snapshot = _describableViewSnapshot {
            var y = snapshot.frame.origin.y + snapshot.frame.height + topBottomMargin
            
            var rightIdx = -1
            
            var idx = leftViews.count - 1
            while(idx >= 0) {
                let v = leftViews[idx]
                if (v.directionLeft) {
                    v.label.frame.origin.y = y
                    y += v.label.frame.height + topBottomMargin
                    if (v.index == 0) {
                        y = snapshot.frame.origin.y + snapshot.frame.height + topBottomMargin
                    }
                } else {
                    rightIdx = idx
                }
                idx -= 1
            }
            
            if (rightIdx > -1) {
                let leftIdx = rightIdx - leftViews[rightIdx].index
                y = snapshot.frame.origin.y + snapshot.frame.height + topBottomMargin
                if (leftIdx >= 0 && leftIdx != rightIdx) {
                    y = leftViews[leftIdx].label.frame.origin.y + leftViews[leftIdx].label.frame.height + topBottomMargin
                }
                
                idx = rightIdx
                while(idx < leftViews.count) {
                    let v = leftViews[idx]
                    if (v.index == 0 && idx > rightIdx) { // reset
                        y = snapshot.frame.origin.y + snapshot.frame.height + topBottomMargin
                    }
                    v.label.frame.origin.y = y
                    y += v.label.frame.height + topBottomMargin
                    idx += 1
                }
            }
        }
    }
    
    func layoutLines() {
        for (key, value) in _describableViewEntities {
            if let labelRect = _labels[key]?.frame, labelRect.size != CGSize.zero {
                let targetViewRect = value.object?.superview?.convert((value.object?.frame)!, to: self.view)
                let containerViewRect = _describableViewSnapshot?.frame
                layoutLine(key: key, labelRect, targetViewRect!, containerViewRect!)
            }
        }
    }
    
    func drawLines() {
        for (key, value) in _describableViewEntities {
            if let labelRect = _labels[key]?.frame, labelRect.size != CGSize.zero {
                let targetViewRect = value.object?.superview?.convert((value.object?.frame)!, to: self.view)
                let containerViewRect = _describableViewSnapshot?.frame
                drawLine(key: key, labelRect, targetViewRect!, containerViewRect!)
            }
        }
    }
    
    func drawLine(key: String, _ labelRect: CGRect, _ targetViewRect: CGRect, _ containerViewRect: CGRect) {
        let layer = CAShapeLayer()
        layer.opacity = 1
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 1.0
        _lines[key] = layer
        self.view.layer.addSublayer(layer)
        layoutLine(key: key, labelRect, targetViewRect, containerViewRect)
    }
    
    func layoutLine(key: String, _ labelRect: CGRect, _ targetViewRect: CGRect, _ containerViewRect: CGRect) {
        let layer = _lines[key]
        
        let directionToTop = CGFloat((containerViewRect.origin.y > labelRect.origin.y) ? -1 : 1)
        let directionToRight = CGFloat((targetViewRect.origin.x > labelRect.origin.x) ? -1 : 1)
        
        let path = UIBezierPath()
        var x = targetViewRect.origin.x + (directionToRight == 1 ? leftRightMargin : targetViewRect.width - leftRightMargin)
        var y = containerViewRect.origin.y + (directionToTop == -1 ? directionToTop * lineMarging : containerViewRect.height + directionToTop * lineMarging)
        
        path.move(to: CGPoint(x: x, y: y))
        
        y = labelRect.origin.y + (directionToTop == 1 ? directionToTop * (labelRect.height / 2) : -directionToTop * (labelRect.height / 2))
        path.addLine(to: CGPoint(x: x, y: y))
        
        if (targetViewRect.width - leftRightMargin > lineMarging + leftRightMargin) {
            x = labelRect.origin.x + (directionToRight == 1 ? (-4 + -directionToRight * lineMarging) : labelRect.width - 4 - directionToRight * lineMarging)
            path.addLine(to: CGPoint(x: x, y: y))
        path.addArc(withCenter: CGPoint(x: directionToRight == 1 ? x + 2 : x - 2, y: y), radius: 2, startAngle: directionToRight == 1 ? degreesToRadians(180) : degreesToRadians(360), endAngle: directionToRight == 1 ? degreesToRadians(-180) : degreesToRadians(-360), clockwise: false)
        } else {
            path.addArc(withCenter: CGPoint(x: x, y: y + 2), radius: 2, startAngle: degreesToRadians(270), endAngle: degreesToRadians(-270), clockwise: false)
        }
        
        layer?.path = path.cgPath
        layer?.setNeedsDisplay()
    }
    
    open func animateSubviews(views: [UIView]) {
        if (animateAppearance) {
            UIView.animate(withDuration: animationDuration02, delay: 0, options: [.allowAnimatedContent, .curveEaseInOut], animations: {
                for v in views {
                    v.alpha = 1
                }
            }) { (success) in
            }
        } else {
            for v in views {
                v.alpha = 1
            }
        }
    }
}

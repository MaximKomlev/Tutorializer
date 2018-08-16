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
    
    weak var _describableView: (UIView & TutorialDescribableViewDelegate)?
    
    var _describableViewEntities = Array<(key: String, value: Weak<UIView>)>()
    
    var _labels = Dictionary<String, UILabel>()
    var _lines = Dictionary<String, CAShapeLayer>()
    
    // config
    var _tutorialDescriptions = Dictionary<String, DescribableElementInfo>()
    
    public lazy var _blurView = TutorialDarkBlurView(frame: CGRect.zero)
    
    // MARK: Initializers/Deinitializer
    
    public required init() {
        super.init(nibName: nil, bundle: nil)
        
        initializeUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        animateAppearance = false
        tutorialDelegate = nil
        
        _blurView.removeFromSuperview()
        view.removeFromSuperview()
        
        _describableView = nil
        
        _describableViewEntities.removeAll()
        _tutorialDescriptions.removeAll()
        deInitializeDescribableView()
    }
    
    // MARK: Controller life cycle
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        _blurView.frame = view.bounds
        _blurView.layoutIfNeeded()
    }
    
    // MARK: Properties
    
    public var isInitializedDescribableView: Bool {
        get {
            return _labels.count > 0
        }
    }
    
    // MARK: TutorialViewProtocol
    
    // MARK: Properties
    
    public var tutorialViewId: String? = nil
    
    public weak var tutorialDelegate: TutorialViewDataDelegate? = nil
    
    public var animateAppearance: Bool = true
    
    public var blurAlpha: CGFloat {
        get {
            return _blurView.blurAlpha
        } set (v) {
            _blurView.blurAlpha = v
        }
    }
    
    public var tutorialView: UIView {
        get {
            return view
        }
    }
    
    // MARK: Methods
        
    open func initializeTutorialDescriptions(_ descriptions: Dictionary<String, DescribableElementInfo>) {
        _tutorialDescriptions = descriptions
    }
    
    open func transitionComplete() {
    }

    open func layoutViews() {
        if let v = _describableView {
            let rect = v.convertFrame(to: self.view)
            if (rect != CGRect.zero) {
                _blurView.setTransparentSpot(for: v.shapePath(for: rect))
            }
            
            layoutDescriptions(for: v)
            layoutLines()
        }
    }

    open func initializeDescribableView() {
        if (self.tutorialDelegate != nil) {
            self.tutorialDelegate?.fetchDescribableElement(for: self, complete: { [weak self] (v) in
                if let describableView = v as? UIView & TutorialDescribableViewDelegate, self != nil {
                    describableView.tutorialDelegate = self
                    self?._describableView = describableView
                    let rect = describableView.convertFrame(to: self!.view)
                    if (rect != CGRect.zero) {
                        self?._blurView.setTransparentSpot(for: describableView.shapePath(for: rect))
                        
                        // sort tutorialized sub elements by x
                        self?._describableViewEntities = self!.sortElementsByCoordinates(describableView)
                        
                        self?.initializeLabelsDescriptions(describableView)
                        
                        self?.layoutDescriptions(for: describableView)
                        
                        self?.initializeLines()
                        
                        self?.animateAppearanceSubviewsAndLayers(show: true, views: Array(self!._labels.values), layers: Array(self!._lines.values), complete: {})
                    }
                }
            })
        }
    }

    open func deInitializeDescribableView() {
        animateAppearanceSubviewsAndLayers(show: false, views: Array(_labels.values), layers: Array(_lines.values)) {
            for (_, value) in self._labels {
                value.removeFromSuperview()
            }
            for (_, value) in self._lines {
                value.removeFromSuperlayer()
            }
            self._labels.removeAll()
            self._lines.removeAll()
        }
        
        _blurView.resetTransparentSpot()
    }
    
    // MARK: Helpers
    
    open func initializeUI() {
        self.view.backgroundColor = UIColor.clear
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(_blurView)
    }
    
    func initializeLabelsDescriptions(_ forView: UIView) {
        for (key, _) in _describableViewEntities {
            if let desc = _tutorialDescriptions[key],
                let text = desc.descriptionText {
                let label = UILabel()
                label.textColor = UIColor.white
                label.font = UIFont.boldSystemFont(ofSize: font_size_label14)
                label.lineBreakMode = .byWordWrapping
                label.numberOfLines = 0
                label.textAlignment = .left
                label.attributedText = text
                label.alpha = 0
                _labels[key] = label
                _blurView.addSubview(label)
            }
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
    
    func layoutDescriptions(for view: UIView & TutorialDescribableViewDelegate) {
        let rect = view.convertFrame(to: self.view)
        if (rect != CGRect.zero) {
            if (_describableViewEntities.count > 0) {
                let isNeedReArrangeTopLabels = layoutTopDescriptions(for: arrangeDescriptions(by: .top))
                let isNeedReArrangeBottomLabels = layoutBottomDescriptions(for: arrangeDescriptions(by: .bottom))
                if (!isNeedReArrangeTopLabels && isNeedReArrangeBottomLabels) {
                    layoutTopDescriptions(for: arrangeDescriptions(by: .top))
                }
            }
        }
    }
    
    func arrangeDescriptions(by layout: DescribableElementLayout) -> [(key: String, index: Int, label: UILabel, directionLeft: Bool)] {
        
        var leftViews: [(key: String, index: Int, label: UILabel, directionLeft: Bool)] = [] // sorted by x descriptions with z-index
        var range: CGFloat = 0
        
        for v in _describableViewEntities {
            if (_tutorialDescriptions[v.key]?.descriptionPosition == layout ||
                _tutorialDescriptions[v.key]?.descriptionPosition == .any) {
                if let label = _labels[v.key] {
                    let tutorialDescriprionWidth = _tutorialDescriptions[v.key]?.descriptionWidth ?? tutorialDescriprionDefaultWidth
                    // calculate size of description
                    if let aText = label.attributedText {
                        let descriptionSize = sizeConstrained(toWidth: tutorialDescriprionWidth, forAttributedString: aText)
                        if (descriptionSize != CGSize.zero) {
                            // calculate x coordinate for tutorialized sub element
                            if let entity = v.value.object,
                                let coordinateSpace = self.view?.window?.screen.coordinateSpace,
                                let rect = entity.superview?.convert(entity.frame, to: coordinateSpace) {
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
        }
        
        return leftViews
    }
    
    @discardableResult func layoutTopDescriptions(for configs: [(key: String, index: Int, label: UILabel, directionLeft: Bool)]) -> Bool {
        var isNeedReAggregate = false
        if let v = _describableView {
            let rect = v.convertFrame(to: self.view)
            if (rect != CGRect.zero) {
                var y = rect.origin.y - topBottomMargin
                
                var rightIdx = -1
                
                var idx = configs.count - 1
                while(idx >= 0) {
                    let config = configs[idx]
                    if (config.directionLeft) {
                        y = y - config.label.frame.height
                        config.label.frame.origin.y = y
                        if (!isDescriptionFitTopEdge(descriptionKey: config.key, labelFrame: config.label.frame)) {
                            isNeedReAggregate = true
                        }
                        y -= config.label.frame.height - topBottomMargin
                        if (config.index == 0) {
                            y = rect.origin.y - topBottomMargin
                        }
                    } else {
                        rightIdx = idx
                    }
                    idx -= 1
                }
                
                if (rightIdx > -1) {
                    let leftIdx = rightIdx - configs[rightIdx].index
                    y = rect.origin.y - topBottomMargin
                    if (leftIdx >= 0 && leftIdx != rightIdx) {
                        y = configs[leftIdx].label.frame.origin.y - topBottomMargin
                    }
                    
                    idx = rightIdx
                    while(idx < configs.count) {
                        let config = configs[idx]
                        if (config.index == 0 && idx > rightIdx) { // reset
                            y = rect.origin.y - topBottomMargin
                        }
                        y = y - config.label.frame.height
                        config.label.frame.origin.y = y
                        if (!isDescriptionFitTopEdge(descriptionKey: config.key, labelFrame: config.label.frame)) {
                            isNeedReAggregate = true
                        }
                        y -= config.label.frame.height - topBottomMargin
                        idx += 1
                    }
                }
            }
        }
        return isNeedReAggregate
    }
    
    @discardableResult func layoutBottomDescriptions(for configs: [(key: String, index: Int, label: UILabel, directionLeft: Bool)]) -> Bool {
        var isNeedReAggregate = false
        if let v = _describableView {
            let rect = v.convertFrame(to: self.view)
            if (rect != CGRect.zero) {
                var y = rect.origin.y + rect.height + topBottomMargin
                
                var rightIdx = -1
                
                var idx = configs.count - 1
                while(idx >= 0) {
                    let config = configs[idx]
                    if (config.directionLeft) {
                        config.label.frame.origin.y = y
                        if (!isDescriptionFitBottomEdge(descriptionKey: config.key, labelFrame: config.label.frame)) {
                            isNeedReAggregate = true
                        }
                        y += config.label.frame.height + topBottomMargin
                        if (config.index == 0) {
                            y = rect.origin.y + rect.height + topBottomMargin
                        }
                    } else {
                        rightIdx = idx
                    }
                    idx -= 1
                }
                
                if (rightIdx > -1) {
                    let leftIdx = rightIdx - configs[rightIdx].index
                    y = rect.origin.y + rect.height + topBottomMargin
                    if (leftIdx >= 0 && leftIdx != rightIdx) {
                        y = configs[leftIdx].label.frame.origin.y + configs[leftIdx].label.frame.height + topBottomMargin
                    }
                    
                    idx = rightIdx
                    while(idx < configs.count) {
                        let config = configs[idx]
                        if (config.index == 0 && idx > rightIdx) { // reset
                            y = rect.origin.y + rect.height + topBottomMargin
                        }
                        config.label.frame.origin.y = y
                        if (!isDescriptionFitBottomEdge(descriptionKey: config.key, labelFrame: config.label.frame)) {
                            isNeedReAggregate = true
                        }
                        y += config.label.frame.height + topBottomMargin
                        idx += 1
                    }
                }
            }
        }
        return isNeedReAggregate
    }
    
    func isDescriptionFitTopEdge(descriptionKey: String, labelFrame: CGRect) -> Bool {
        // checking if label can fit allowed view boundaries
        let topEdge = allowedFrame().origin.y
        if (labelFrame.origin.y >= topEdge) {
            return true
        }
        _tutorialDescriptions[descriptionKey]?.descriptionPosition = .bottom
        return false
    }
    
    func isDescriptionFitBottomEdge(descriptionKey: String, labelFrame: CGRect) -> Bool {
        // checking if label can fit allowed view boundaries
        let bottomEdge = allowedFrame().height
        if (labelFrame.origin.y + labelFrame.height <= bottomEdge) {
            return true
        }
        _tutorialDescriptions[descriptionKey]?.descriptionPosition = .top
        return false
    }
    
    func layoutLines() {
        for (key, value) in _describableViewEntities {
            if let v = _describableView, let labelRect = _labels[key]?.frame, labelRect.size != CGSize.zero,
                let targetView = value.object,
                let coordinateSpace = self.view?.window?.screen.coordinateSpace,
                let targetViewRect = targetView.superview?.convert(targetView.frame, to: coordinateSpace) {
                let containerViewRect = v.convertFrame(to: self.view)
                if (containerViewRect != CGRect.zero) {
                    layoutLine(key: key, labelRect, targetViewRect, containerViewRect)
                }
            }
        }
    }
    
    func initializeLines() {
        for (key, value) in _describableViewEntities {
            if let v = _describableView, let labelRect = _labels[key]?.frame, labelRect.size != CGSize.zero,
                let targetView = value.object,
                let coordinateSpace = self.view?.window?.screen.coordinateSpace,
                let targetViewRect = targetView.superview?.convert(targetView.frame, to: coordinateSpace) {
                let containerViewRect = v.convertFrame(to: self.view)
                if (containerViewRect != CGRect.zero) {
                    initializeLine(key: key, labelRect, targetViewRect, containerViewRect)
                }
            }
        }
    }
    
    func initializeLine(key: String, _ labelRect: CGRect, _ targetViewRect: CGRect, _ containerViewRect: CGRect) {
        let layer = CAShapeLayer()
        layer.isHidden = true
        layer.fillColor = UIColor.white.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 1.0
        _lines[key] = layer
        _blurView.layer.addSublayer(layer)
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
        path.close()
        
        path.move(to: CGPoint(x: x, y: y))
        
        if (targetViewRect.width - leftRightMargin > lineMarging + leftRightMargin) {
            x = labelRect.origin.x + (directionToRight == 1 ? (-4 + -directionToRight * lineMarging) : labelRect.width - 4 - directionToRight * lineMarging)
            path.addLine(to: CGPoint(x: x, y: y))
            path.addArc(withCenter: CGPoint(x: directionToRight == 1 ? x + 2 : x - 2, y: y), radius: 2, startAngle: directionToRight == 1 ? degreesToRadians(180) : degreesToRadians(360), endAngle: directionToRight == 1 ? degreesToRadians(-180) : degreesToRadians(-360), clockwise: false)
        } else {
            path.addArc(withCenter: CGPoint(x: x, y: y + 2), radius: 2, startAngle: degreesToRadians(270), endAngle: degreesToRadians(-270), clockwise: false)
        }
        
        layer?.path = path.cgPath
        path.stroke()
        path.close()
        layer?.setNeedsDisplay()
    }
    
    func allowedFrame() -> CGRect {
        var topSafeOffset: CGFloat = 5
        var bottomSafeOffset: CGFloat = 5
        if #available(iOS 11.0, *) {
            topSafeOffset += view.safeAreaInsets.top
            bottomSafeOffset += view.safeAreaInsets.bottom
        }
        return CGRect(x: _blurView.bounds.origin.x, y: topSafeOffset, width: _blurView.bounds.width, height: _blurView.bounds.height - bottomSafeOffset)
    }
    
    open func animateAppearanceSubviewsAndLayers(show: Bool, views: [UIView], layers: [CALayer], complete: @escaping () -> ()) {
        if (animateAppearance) {
            UIView.animate(withDuration: animationDuration02, delay: 0, options: [.allowAnimatedContent, .curveEaseInOut], animations: {
                for v in views {
                    v.alpha = show ? 1 : 0
                }
                for v in layers {
                    v.isHidden = !show
                }
            }) { (success) in
                complete()
            }
        } else {
            for v in views {
                v.alpha = show ? 1 : 0
            }
            for v in layers {
                v.isHidden = !show
            }
            complete()
        }
    }
}




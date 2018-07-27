//
//  BlurEffectView.swift
//  Tutorializer
//
//  Created by Maxim Komlev on 7/16/18.
//  Copyright © 2018 Maxim Komlev. All rights reserved.
//

import Foundation

open class TutorialBlurView: UIView {
    
    // MARK: Fields
    
    lazy var _blurEffectView: UIVisualEffectView = {
        return  UIVisualEffectView(effect: blurEffect())
    }()
    lazy var _vibrancyEffectView: UIVisualEffectView = {
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect())
        return UIVisualEffectView(effect: vibrancyEffect)
    }()
    
    // MARK: Initializer/Deinitializer
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        self.clipsToBounds = true
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        _blurEffectView.alpha = 1
        _blurEffectView.frame = frame
        _blurEffectView.contentView.addSubview(_vibrancyEffectView)
        addSubview(_blurEffectView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
    }
    
    // MARK: Properties
    
    open var blurAlpha: CGFloat {
        get {
            return _blurEffectView.alpha
        } set (v) {
            _blurEffectView.alpha = v
            setNeedsLayout()
        }
    }

    open override var frame: CGRect {
        get {
            return super.frame
        } set (v) {
            super.frame = v
            _blurEffectView.frame = super.bounds
            _vibrancyEffectView.frame = super.bounds
            setNeedsLayout()
        }
    }
    
    // MARK: Methods
    
    func setTransparentSpot(for shape: CGPath) {
        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 0)
        path.append(UIBezierPath(cgPath: shape))
        
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path.cgPath
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        self.layer.mask = maskLayer
        self.clipsToBounds = true
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    // MARK: Helpers
    
    func blurEffect() -> UIBlurEffect {
        return UIBlurEffect(style: .light)
    }

}

open class TutorialDarkBlurView: TutorialBlurView {
    
    // MARK: Helpers
    
    open override func blurEffect() -> UIBlurEffect {
        return UIBlurEffect(style: .dark)
    }

}


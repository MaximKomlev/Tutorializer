//
//  TutorialNavigationController.swift
//  Tutorializer
//
//  Created by Maxim Komlev on 7/21/18.
//  Copyright © 2018 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

public protocol TutorialNavigationControllerDelegate: TutorialViewDataDelegate {
    func getDoneButtonLocation(_ button: UIButton) -> CGPoint?
    func doneButtonClicked(_ tutorialNavigationController: TutorialNavigationController)
}

open class TutorialNavigationController: UIViewController, TutorialViewDataDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
 
    // MARK: Fields

    var _pageController: UIPageViewController!

    var _screens = [UIViewController & TutorialViewProtocol]()

    var _pager: UIPageControl!
    var _buttonDone: UIButton!

    // MARK: Initializer/Deinitializer
    
    public required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Controller life cycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeUI()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let index = currentViewControllerIndex()
        if (index > -1) {
            _screens[index].transitionComplete()
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var xSafeOffset: CGFloat = leftRightMargin
        var ySafeOffset: CGFloat = 5
        if #available(iOS 11.0, *) {
            xSafeOffset += view.safeAreaInsets.left
            ySafeOffset += view.safeAreaInsets.top
        }

        if let doneButtonLocation = tutorialDelegate?.getDoneButtonLocation(_buttonDone) {
            xSafeOffset = doneButtonLocation.x
            ySafeOffset = doneButtonLocation.y
        }

        if let buttonTitle = doneButtonAttributedText, buttonTitle.length > 0 {
            let buttonTextSZ = buttonTitle.size()
            var buttonWidth = buttonTextSZ.width
            if (buttonWidth > (view.frame.width - xSafeOffset) / 2) {
                buttonWidth = (view.frame.width - xSafeOffset) / 2
            }
            let buttonHeight = buttonTextSZ.height
            _buttonDone.frame = CGRect(x: xSafeOffset, y: ySafeOffset, width: buttonWidth, height: buttonHeight)
        }
        
        if (!isPagerHidden) {
            let pgSize = _pager.size(forNumberOfPages: _screens.count)
            let x = (view.frame.width - pgSize.width) / 2
            var y = view.frame.height - pgSize.height - topBottomMargin
            if #available(iOS 11.0, *) {
                y -= view.safeAreaInsets.bottom
            }
            _pager.frame = CGRect(x: x, y: y, width: pgSize.width, height: pgSize.height)
        }
    }
        
    // MARK: Properties
    
    public weak var tutorialDelegate: TutorialNavigationControllerDelegate? = nil

    var doneButtonAttributedText: NSAttributedString? {
        get {
            return _buttonDone.attributedTitle(for: .normal)
        } set (v) {
            if (_buttonDone.attributedTitle(for: .normal) != v) {
                _buttonDone.setAttributedTitle(v, for: .normal)
                self.view.setNeedsLayout()
            }
        }
    }

    var isDoneButtonEnabled: Bool {
        get {
            return _buttonDone.isEnabled
        } set (v) {
            _buttonDone.isEnabled = v
        }
    }
    
    var isPagerHidden: Bool {
        get {
            return _pager.isHidden
        } set (v) {
            _pager.isHidden = v
        }
    }

    // MARK: Public methods
    
    open func addTutorialViewController(tutorialController: UIViewController & TutorialViewProtocol) {
        tutorialController.tutorialDelegate = self
        _screens.append(tutorialController)
    }
    
    // MARK: TutorialViewDataDelegate
    
    open func fetchDescribableElement(for tutorialView: TutorialViewProtocol?, complete: @escaping (_ view: UIView?) -> ()) {
        tutorialDelegate?.fetchDescribableElement(for: tutorialView, complete: complete)
    }

    // MARK: UIPageViewControllerDataSource

    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let viewControllerIndex = _screens.index(where: { (vc2) -> Bool in
            if let vc1 = viewController as? (UIViewController & TutorialViewProtocol),
                vc1 == vc2 {
                return true
            }
            return false
            }) {
            let previousIndex = viewControllerIndex - 1
            
            if (previousIndex >= 0 && previousIndex < _screens.count) {
                return _screens[previousIndex]
            }
        }
        return nil
    }
    
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let viewControllerIndex = _screens.index(where: { (vc2) -> Bool in
            if let vc1 = viewController as? (UIViewController & TutorialViewProtocol),
                vc1 == vc2 {
                return true
            }
            return false
        }) {
            let nextIndex = viewControllerIndex + 1

            if (nextIndex >= 0 && nextIndex < _screens.count) {
                return _screens[nextIndex]
            }
        }
        return nil
    }
    
    // MARK: UIPageViewControllerDelegate
    
    open func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        for vc in pendingViewControllers {
            if let tvc = vc as? (UIViewController & TutorialViewProtocol) {
                tvc.inValidate()
            }
        }
    }
    
    open func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let index = currentViewControllerIndex()
        if (index > -1) {
            _screens[index].transitionComplete()
            _pager.currentPage = index
        }
    }
        
    // MARK: Helpers
    
    open func initializeUI() {
        _pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        _pageController.delegate = self
        _pageController.dataSource = self
        
        addChildViewController(_pageController)
        view.addSubview(_pageController.view)
        _pageController.didMove(toParentViewController: self)

        if (_screens.count > 0) {
            _pageController.setViewControllers([_screens[0]], direction: .forward, animated: false, completion: nil)
        }

        _buttonDone = UIButton(type: .roundedRect)
        _buttonDone.titleLabel?.font = UIFont.systemFont(ofSize: font_size_button16)
        _buttonDone.titleLabel?.lineBreakMode = .byTruncatingTail
        _buttonDone.titleLabel?.numberOfLines = 1
        _buttonDone.contentVerticalAlignment = .center
        _buttonDone.contentHorizontalAlignment = .center
        _buttonDone.backgroundColor = UIColor.clear
        _buttonDone.setTitleColor(.white, for: .normal)
        _buttonDone.setTitleColor(.white, for: [.highlighted, .focused, .selected])
        _buttonDone.setTitleColor(UIColor.lightText, for: [.disabled])
        _buttonDone.addTarget(self, action: #selector(doneButtonHandler), for: .touchUpInside)
        _buttonDone.showsTouchWhenHighlighted = true
        self.view.addSubview(_buttonDone)
        let bTitle = NSMutableAttributedString(string: "Done")
        bTitle.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: font_size_button16), range: NSMakeRange(0, bTitle.length))
        bTitle.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSMakeRange(0, bTitle.length))
        doneButtonAttributedText = bTitle
        
        _pager = UIPageControl()
        _pager.numberOfPages = _screens.count
        _pager.currentPage = 0
        _pager.pageIndicatorTintColor = UIColor.lightGray
        _pager.currentPageIndicatorTintColor = .white
        _pager.isHidden = _screens.count == 0 || _screens.count == 1
        self.view.addSubview(_pager)
    }
    
    func currentViewControllerIndex() -> Int {
        if let tvc = _pageController.viewControllers?.first as? (UIViewController & TutorialViewProtocol) {
            if let id = tvc.tutorialViewId {
                if let index = _screens.index(where: { (vc) -> Bool in
                    return vc.tutorialViewId == id
                }) {
                    return index
                }
            }
        }
        return -1
    }
    
    // MARK: Events handlers
    
    @objc func doneButtonHandler(sender: AnyObject) {
        tutorialDelegate?.doneButtonClicked(self)
    }

}

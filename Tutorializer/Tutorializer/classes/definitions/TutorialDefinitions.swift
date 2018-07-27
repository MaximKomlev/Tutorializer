//
//  TutorialDefinitions.swift
//  Tutorializer
//
//  Created by Maxim Komlev on 7/14/18.
//  Copyright © 2018 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

struct Edge : OptionSet {
    let rawValue: Int
    
    static let none   = Edge(rawValue: 0)
    static let left   = Edge(rawValue: 1 << 0)
    static let right  = Edge(rawValue: 1 << 1)
    static let bottom = Edge(rawValue: 1 << 2)
    static let top    = Edge(rawValue: 1 << 3)
    
    static let all = Edge(rawValue: (1 << 0 | 1 << 1 | 1 << 2 | 1 << 3))
}

public enum Direction {
    case up, down, left, right, none
}

func degreesToRadians(_ degrees: CGFloat) -> CGFloat {
    return degrees  * CGFloat(Double.pi) / 180
}

func directionToRadians(_ direction: Direction) -> CGFloat {
    switch direction {
    case .up:
        return degreesToRadians(-90)
    case .down:
        return degreesToRadians(90)
    case .left:
        return degreesToRadians(180)
    case .right:
        return degreesToRadians(0)
    case .none:
        return 0
    }
}

// MARK: Sys env.

struct ScreenSize {
    static let width         = UIScreen.main.bounds.size.width
    static let height        = UIScreen.main.bounds.size.height
    static let maxOfHeightWidth    = max(ScreenSize.width, ScreenSize.height)
    static let minOfHeightWidth    = min(ScreenSize.width, ScreenSize.height)
}

struct DeviceType {
    static let IS_IPHONE            = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxOfHeightWidth < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxOfHeightWidth == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxOfHeightWidth == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxOfHeightWidth == 736.0
    static let IS_IPHONE_7          = IS_IPHONE_6
    static let IS_IPHONE_7P         = IS_IPHONE_6P
    static let IS_IPHONE_X          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxOfHeightWidth == 812.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.maxOfHeightWidth == 1024.0
    static let IS_IPAD_PRO_9_7      = IS_IPAD
    static let IS_IPAD_PRO_12_9     = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.maxOfHeightWidth == 1366.0
    static let IS_TV                = UIDevice.current.userInterfaceIdiom == .tv
    static let IS_CAR_PLAY          = UIDevice.current.userInterfaceIdiom == .carPlay
    
    static func isIPad() -> Bool {
        return DeviceType.IS_IPAD || DeviceType.IS_IPAD_PRO_12_9 || DeviceType.IS_IPAD_PRO_9_7
    }
    
    static func isIPhone() -> Bool {
        return !isTv() && !isIPad()
    }
    
    static func isTv() -> Bool {
        return DeviceType.IS_TV
    }
    
}

public enum TutorialTransitioningDirection {
    case up, down, left, right, none
}


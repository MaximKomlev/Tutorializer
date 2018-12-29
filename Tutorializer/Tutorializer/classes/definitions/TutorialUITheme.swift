//
//  TutorialUITheme.swift
//  Tutorializer
//
//  Created by Maxim Komlev on 7/14/18.
//  Copyright © 2018 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

// MARK: Default durations

let animationDuration08: Double = 0.8
let animationDuration06: Double = 0.6
let animationDuration05: Double = 0.5
let animationDuration04: Double = 0.4
let animationDuration03: Double = 0.3
let animationDuration02: Double = 0.2
let animationDuration01: Double = 0.1

// MARK: Colors
/*
 /* RGB */ test
 $color1: rgba(0, 129, 175, 1);
 $color2: rgba(45, 199, 255, 1);
 $color3: rgba(33, 118, 255, 1);
 $color4: rgba(49, 57, 60, 1);
 $color5: rgba(208, 225, 232, 1);
 
 /* RGB */ current
 $color1: rgba(60, 55, 68, 1);
 $color2: rgba(53, 56, 173, 1);
 $color3: rgba(220, 232, 247, 1);
 $color4: rgba(237, 244, 249, 1);
 $color5: rgba(220, 228, 242, 1);
 */

let sysBackgroundColor: UIColor = UIColor(red: 247 / 255, green: 247 / 255, blue: 247 / 255, alpha: 1)
let sysBorderColor: UIColor = UIColor(red: 224 / 255, green: 224 / 255, blue: 224 / 255, alpha: 1)

let sysLabelColor = UIColor(red: 100 / 255, green: 100 / 255, blue: 100 / 255, alpha: 1)
let sysLabelLightColor = UIColor(red: 200 / 255, green: 200 / 255, blue: 200 / 255, alpha: 1)
let sysDescColor = UIColor(red: 153 / 255, green: 153 / 255, blue: 153 / 255, alpha: 1)
let sysTintColor = UIColor(red: 0.204, green: 0.624, blue: 0.847, alpha: 1)

let sysDisabledColor = UIColor(red: 123 / 255, green: 123 / 255, blue: 123 / 255, alpha: 0.48)

let sysRed = UIColor(red: 255 / 255, green: 59 / 255, blue: 48 / 255, alpha: 1)
let sysOrange = UIColor(red: 255 / 255, green: 149 / 255, blue: 0 / 255, alpha: 1)
let sysYellow = UIColor(red: 255 / 255, green: 204 / 255, blue: 0 / 255, alpha: 1)
let sysGreen = UIColor(red: 76 / 255, green: 217 / 255, blue: 100 / 255, alpha: 1)
let sysTealBlue = UIColor(red: 90/255, green: 200 / 255, blue: 250 / 255, alpha: 1)
let sysBlue = UIColor(red: 0 / 255, green: 122 / 255, blue: 255 / 255, alpha: 1)
let sysPurple = UIColor(red: 88 / 255, green: 86 / 255, blue: 214 / 255, alpha: 1)
let sysPink = UIColor(red: 255 / 255, green: 45 / 255, blue: 85 / 255, alpha: 1)
let sysGrey = UIColor(red: 100 / 255, green: 100 / 255, blue: 100 / 255, alpha: 1)
let sysLightGrey = UIColor(red: 153 / 255, green: 153 / 255, blue: 153 / 255, alpha: 1)
//let customDarkBlue = UIColor(red: 23 / 255, green: 25 / 255, blue: 145 / 255, alpha: 1)
let sysDarkGreen = UIColor(red: 0 / 255, green: 135 / 255, blue: 31 / 255, alpha: 1)
let customDarkBlue = UIColor(red: 53 / 255, green: 56 / 255, blue: 173 / 255, alpha: 1)

let facebookDefaultBlue = UIColor(red: 59 / 255, green: 89 / 255, blue: 152 / 255, alpha: 1)
let twitterDefaultBlue = UIColor(red: 0 / 255, green: 172 / 255, blue: 237 / 255, alpha: 1)
let vkontakteDefaultBlue = UIColor(red: 76 / 255, green: 117 / 255, blue: 163 / 255, alpha: 1)

let remoteWidgetBackground = UIColor(red: 244 / 255, green: 250 / 255, blue: 255 / 255, alpha: 1)
let localWidgetBackground = UIColor(red: 245 / 255, green: 255 / 255, blue: 244 / 255, alpha: 1)
let addWidgetBackground = sysBackgroundColor
let cellBorderColor = UIColor(red: 220 / 255, green: 228 / 255, blue: 242 / 255, alpha: 1)
let tabBarBackgroundColor = UIColor(red: 220 / 255, green: 232 / 255, blue: 247 / 255, alpha: 1)
//let videoWidgetBackgroundColor = UIColor(red: 49 / 255, green: 57 / 255, blue: 60 / 255, alpha: 1)
let videoWidgetBackgroundColor = UIColor(red: 60 / 255, green: 55 / 255, blue: 68 / 255, alpha: 1)

let backgroundColorStart = UIColor.white.cgColor
let backgroundColorMiddle = UIColor(red: 220 / 255, green: 228 / 255, blue: 242 / 255, alpha: 1.0).cgColor
let backgroundColorEnd = UIColor(red: 237 / 255, green: 244 / 255, blue: 249 / 255, alpha: 1.0).cgColor

public func backgroundGradient() -> CAGradientLayer {
    let gradientLayer = CAGradientLayer()
    
    gradientLayer.colors = [backgroundColorStart, backgroundColorMiddle, backgroundColorEnd]
    gradientLayer.locations = [0.0, 0.9, 1]
    gradientLayer.startPoint = CGPoint(x: 1, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0, y: 1)
    
    return gradientLayer
}

// MARK: Boundaries

public let tutorialAnimatedTransitionDuration = 0.325
public let tutorialDescriprionDefaultWidth: CGFloat = 100
public let tutorialDescriprionFont = UIFont.boldSystemFont(ofSize: font_size_label14)

let leftRightMargin: CGFloat = 15
let topBottomMargin: CGFloat = 15
let commonInsets: CGFloat = 5
let lineMarging: CGFloat = 5
let cornerRadius: CGFloat = 2
let cellCornerRadius: CGFloat = 5
let progressHeight: CGFloat = 2

var default_cell_height: CGFloat {
    get {
        if (DeviceType.IS_IPHONE_4_OR_LESS) {
            return 54
        }
        return 62
    }
}

var default_button_height: CGFloat {
    get {
        if (DeviceType.IS_IPHONE_4_OR_LESS) {
            return 36
        }
        return 44
    }
}

var default_textedit_height: CGFloat {
    get {
        if (DeviceType.IS_IPHONE_4_OR_LESS) {
            return 32
        }
        return 44
    }
}

// MARK: Font size

var font_size_button14: CGFloat {
    get {
        if (DeviceType.IS_IPHONE_4_OR_LESS) {
            return 12
        }
        return 14
    }
}

var font_size_button16: CGFloat {
    get {
        if (DeviceType.IS_IPHONE_4_OR_LESS) {
            return 14
        }
        return 16
    }
}

var font_size_label28: CGFloat {
    get {
        if (DeviceType.IS_IPHONE_4_OR_LESS) {
            return 24
        }
        return 28
    }
}

var font_size_label24: CGFloat {
    get {
        if (DeviceType.IS_IPHONE_4_OR_LESS) {
            return 22
        }
        return 24
    }
}

var font_size_label22: CGFloat {
    get {
        if (DeviceType.IS_IPHONE_4_OR_LESS) {
            return 20
        }
        return 22
    }
}

var font_size_label20: CGFloat {
    get {
        if (DeviceType.IS_IPHONE_4_OR_LESS) {
            return 18
        }
        return 20
    }
}

var font_size_label18: CGFloat {
    get {
        if (DeviceType.IS_IPHONE_4_OR_LESS) {
            return 16
        }
        return 18
    }
}

var font_size_label16: CGFloat {
    get {
        if (DeviceType.IS_IPHONE_4_OR_LESS) {
            return 14
        }
        return 16
    }
}

var font_size_label14: CGFloat {
    get {
        if (DeviceType.IS_IPHONE_4_OR_LESS) {
            return 12
        }
        return 14
    }
}

var font_size_label12: CGFloat {
    get {
        if (DeviceType.IS_IPHONE_4_OR_LESS) {
            return 10
        }
        return 12
    }
}

var font_size_cell_label16: CGFloat {
    get {
        if (DeviceType.IS_IPHONE_4_OR_LESS) {
            return 14
        }
        return 16
    }
}


var font_size_desc14: CGFloat {
    get {
        if (DeviceType.IS_IPHONE_4_OR_LESS) {
            return 12
        }
        return 14
    }
}

var font_size_desc12: CGFloat {
    get {
        if (DeviceType.IS_IPHONE_4_OR_LESS) {
            return 10
        }
        return 12
    }
}

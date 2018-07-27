//
//  DescribableElementInfo.swift
//  Tutorializer
//
//  Created by Maxim Komlev on 7/14/18.
//  Copyright © 2018 Maxim Komlev. All rights reserved.
//

import Foundation

@objc public enum DescribableElementLayout: Int {
    case any
    case top
    case bottom
}

@objc open class DescribableElementInfo: NSObject {
    
    // MARK: Initializers/Deinitializer
    
    public required init(descriptionPosition: DescribableElementLayout = .any, descriptionWidth: CGFloat = tutorialDescriprionDefaultWidth, descriptionText: NSAttributedString) {
        self.descriptionPosition = descriptionPosition
        self.descriptionText = descriptionText
        self.descriptionWidth = descriptionWidth
    }
    
    // MARK: Properties
    
    public var descriptionPosition: DescribableElementLayout!
    public var descriptionWidth: CGFloat!
    public var descriptionText: NSAttributedString!
}

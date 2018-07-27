//
//  Weak.swift
//  Tutorializer
//
//  Created by Maxim Komlev on 7/16/18.
//  Copyright © 2018 Maxim Komlev. All rights reserved.
//

import Foundation

// Weak reference wraper

class Weak<T: AnyObject>: Equatable, Hashable {
    
    // MARK: Initializers/Deinitializers
    
    init(object: T) {
        self.object = object
    }
    
    // MARK: Properties
    
    weak var object: T?

    var hashValue: Int {
        if let object = self.object {
            return Unmanaged.passUnretained(object).toOpaque().hashValue
        }
        else {
            return 0
        }
    }
}

func == <T> (lhs: Weak<T>, rhs: Weak<T>) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

func == <T> (lhs: Weak<T>, rhs: T) -> Bool {
    return lhs.object === rhs
}

func == <T> (lhs: T, rhs: Weak<T>) -> Bool {
    return lhs === rhs.object
}

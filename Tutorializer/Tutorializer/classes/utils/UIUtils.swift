//
//  UIUtils.swift
//  Tutorializer
//
//  Created by Maxim Komlev on 7/17/18.
//  Copyright © 2018 Maxim Komlev. All rights reserved.
//

import Foundation

// MARK: String size calculation

func sizeConstrained(toWidth: CGFloat, label: UILabel) -> CGSize {
    let aText = NSMutableAttributedString(attributedString: label.attributedText!)
    
    let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    paragraphStyle.lineBreakMode = .byWordWrapping
    aText.addAttributes([NSAttributedStringKey.font: label.font], range: NSMakeRange(0, (aText.length)))
    aText.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: NSMakeRange(0, (aText.length)))
    
    let rect = aText.boundingRect(with: CGSize(width: toWidth, height:CGFloat(Int.max)),
                                          options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil)
    
    return rect.size
}

func sizeConstrained(toWidth: CGFloat, forAttributedString: NSAttributedString) -> CGSize {
    let aText = NSMutableAttributedString(attributedString: forAttributedString)
    
    let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    paragraphStyle.lineBreakMode = .byWordWrapping
    aText.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: NSMakeRange(0, (aText.length)))
    
    let rect = aText.boundingRect(with: CGSize(width: toWidth, height:CGFloat(Int.max)),
                                          options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil)
    
    return rect.size
}

func sizeConstrained(toHeight: CGFloat, label: UILabel) -> CGSize {
    let aText: NSMutableAttributedString = NSMutableAttributedString(attributedString: label.attributedText!)
    
    let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    paragraphStyle.lineBreakMode = .byWordWrapping
    aText.addAttributes([NSAttributedStringKey.font: label.font], range: NSMakeRange(0, (aText.length)))
    aText.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: NSMakeRange(0, (aText.length)))
    
    let rect = aText.boundingRect(with: CGSize(width: CGFloat(Int.max), height:toHeight),
                                          options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil)
    
    return rect.size
}

func sizeConstrained(toHeight: CGFloat, forAttributedString: NSAttributedString) -> CGSize {
    let rect = forAttributedString.boundingRect(with: CGSize(width: CGFloat(Int.max), height:toHeight),
                                                        options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil)
    
    return rect.size
}

func sizeOfAttributedStringForLabel(_ label: UILabel) -> CGSize {
    if let aText = label.attributedText {
        return sizeOfAttributedString(text: aText, font: label.font)
    } else if let text = label.text {
        return sizeOfString(text: text, font: label.font)
    }
    return CGSize.zero
}

func sizeOfString(text: String, font: UIFont) -> CGSize {
    let aText = NSMutableAttributedString(string: text)
    aText.addAttributes([NSAttributedStringKey.font: font], range: NSMakeRange(0, aText.length))
    return aText.size()
}

func sizeOfString(lable: UILabel) -> CGSize {
    return sizeOfString(text: lable.text!, font: lable.font)
}

func sizeOfAttributedString(text: NSAttributedString, font: UIFont) -> CGSize {
    let aText = NSMutableAttributedString(attributedString: text)
    aText.addAttributes([NSAttributedStringKey.font: font], range: NSMakeRange(0, aText.length))
    return aText.size()
}

class AttributedLabelHelper: NSObject {
    
    // MARK: Fields
    
    private var _defaulParagraphStyles: NSMutableParagraphStyle {
        let ps: NSMutableParagraphStyle = NSMutableParagraphStyle()
        ps.alignment = .center
        ps.lineBreakMode = .byWordWrapping
        return ps
    }
    
    private var _defaulColor: [UIColor] = [UIColor.white]
    
    private var _defaulFont: [UIFont] = [UIFont.systemFont(ofSize: font_size_label14)]
    
    // MARK: Properties
    
    var strings: [String]!
    
    var fonts: [UIFont]!
    
    var colors: [UIColor]?
    
    var paragraphStyles: [NSMutableParagraphStyle]?
    
    // MARK: Public methods
    
    func getAttributedText() -> NSAttributedString {
        
        if (paragraphStyles == nil) {
            paragraphStyles = [_defaulParagraphStyles]
        }
        
        if (fonts == nil) {
            fonts = _defaulFont
        }
        
        if (colors == nil) {
            colors = _defaulColor
        }
        
        if (paragraphStyles == nil) {
            paragraphStyles = [_defaulParagraphStyles]
        }
        
        let text: NSMutableAttributedString = NSMutableAttributedString()
        
        // create attributed string
        for string in strings {
            text.append(NSAttributedString(string: string))
        }
        
        var offset: Int = 0
        // assign attributes
        for i in 0..<(strings?.count)! {
            // Paragraph Style
            if let paragraphStyles = paragraphStyles, paragraphStyles.count > 0 {
                text.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyles.count > i ? paragraphStyles[i] : paragraphStyles[paragraphStyles.count - 1], range: NSMakeRange(offset, strings[i].count))
            }
            // Font
            if let fonts = fonts, fonts.count > 0 {
                text.addAttribute(NSAttributedStringKey.font, value: fonts.count > i ? fonts[i] : fonts[fonts.count - 1], range: NSMakeRange(offset, strings[i].count))
            }
            // Color
            if let colors = colors, colors.count > 0 {
                text.addAttribute(NSAttributedStringKey.foregroundColor, value: colors.count > i ? colors[i] : colors[colors.count - 1], range: NSMakeRange(offset, strings[i].count))
            }
            
            offset += strings[i].count
        }
        
        return text
    }
    
}

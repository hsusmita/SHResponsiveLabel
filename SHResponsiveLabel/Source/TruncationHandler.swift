//
//  TruncationHandler.swift
//  SHResponsiveLabel
//
//  Created by hsusmita on 31/07/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

import Foundation

extension SHResponsiveLabel {
  
  func removeTokenIfPresent() {
    if truncationTokenAppended() {
      if let currentString = textStorage.string as NSString? {
        let truncationRange = currentString.rangeOfString(attributedTruncationToken!.string)
        var finalString = NSMutableAttributedString(attributedString: textStorage)
        if truncationRange.location != NSNotFound {
          let rangeOfTuncatedString =  NSMakeRange(truncationRange.location,
            self.attributedText.length-truncationRange.location)
          let truncatedString = attributedText.attributedSubstringFromRange(rangeOfTuncatedString)
          finalString.replaceCharactersInRange(truncationRange, withAttributedString: truncatedString)
        }
        updateTextStorage(finalString)
      }
    }
  }
  
  func updateTruncationToken(truncationToken:NSAttributedString,action:PatternTapResponder) {
    //Disable old pattern if present
    if let tokenString = attributedTruncationToken as NSAttributedString? {
      let patternKey = kRegexFormatForSearchWord + tokenString.string
      if let descriptor = patternDescriptorDictionary[patternKey] {
        disablePatternDetection(descriptor)
      }
    }
    attributedTruncationToken = truncationToken
    var error = NSErrorPointer()
    let patternKey = kRegexFormatForSearchWord + truncationToken.string
    let regex = NSRegularExpression(pattern: patternKey, options: NSRegularExpressionOptions.allZeros, error: error)
    if let currentRegex = regex as NSRegularExpression? {
      if let tokenAction = action as PatternTapResponder? {
        let descriptor = PatternDescriptor(regularExpression: regex!, searchType: PatternSearchType.Last, patternAttributes:[RLTapResponderAttributeName:action])
        enablePatternDetection(descriptor)
      }else {
        let descriptor = PatternDescriptor(regularExpression: regex!, searchType: PatternSearchType.Last,patternAttributes:nil)
        enablePatternDetection(descriptor)
      }
    }

  }
  
  func shouldAppendTruncationToken()-> Bool {
    var shouldAppend = false
    if textStorage.length > 0 {
      if attributedTruncationToken?.length > 0 {
//        shouldAppend = customTruncationEnabled && numberOfLines != 0
        shouldAppend = customTruncationEnabled

      }
    }
    return shouldAppend
  }
  
  func appendTokenIfNeeded() {
    if (shouldAppendTruncationToken() && !truncationTokenAppended()) {
      if isNewLinePresent() {
        //Append token string at the end of last visible line
        let range = rangeForTokenInsertionForStringWithNewLine()
        if range.length > 0 {
          textStorage.replaceCharactersInRange(range, withAttributedString: attributedTruncationToken!)
        }
      }
      //Check for truncation range and append truncation token if required
      let tokenRange = rangeForTokenInsertion()
      
      if (tokenRange.length > 0 && tokenRange.location >= 0) {
        self.textStorage.replaceCharactersInRange(tokenRange, withAttributedString:attributedTruncationToken!)
        self.redrawTextForRange(NSMakeRange(0, textStorage.length))
      }
    
      //Apply attributes if truncation token appended
      let truncationRange = rangeOfTruncationToken()
      if (truncationRange.location != NSNotFound) {
        removeAttributeForTruncatedRange()
        //Apply attributes to the truncation token
        let patternKey = kRegexFormatForSearchWord + attributedTruncationToken!.string
        if let descriptor = patternDescriptorDictionary[patternKey] {
          if let attributes = descriptor.patternAttributes {
            textStorage.addAttributes(descriptor.patternAttributes!, range: truncationRange)
          }
        }
      }
    
    }

  }
  
  // MARK: Truncation Handlers
  
  func isNewLinePresent()-> Bool {
    let currentString = textStorage.string as NSString
    return currentString.rangeOfCharacterFromSet(NSCharacterSet.newlineCharacterSet()).location != NSNotFound
  }
  
  func rangeForTokenInsertionForStringWithNewLine()-> NSRange {
    let numberOfGlyphs = layoutManager.numberOfGlyphs
    var index = 0
    var lineRange = NSMakeRange(NSNotFound, 0);
    let approximateNumberOfLines = Int(layoutManager.usedRectForTextContainer(textContainer).height) / Int(font.lineHeight)

    for (var lineNumber = 0, index = 0; index < numberOfGlyphs; lineNumber++) {
      layoutManager.lineFragmentRectForGlyphAtIndex(index, effectiveRange: &lineRange)
      if (lineNumber == approximateNumberOfLines - 1){ break}
      index = NSMaxRange(lineRange);
    }
    
    let rangeOfText =  NSMakeRange(lineRange.location + lineRange.length - 1, self.textStorage.length - lineRange.location - lineRange.length + 1)
    return rangeOfText
  }
  
  func rangeOfTruncationToken()-> NSRange {
    println("number of line = \(numberOfLines)")
//    if (numberOfLines == 0) {
//      return NSMakeRange(NSNotFound, 0)
//    }
    if (attributedTruncationToken?.length > 0 && customTruncationEnabled == true) {
      var currentString:NSString = textStorage.string as NSString
      return currentString.rangeOfString(attributedTruncationToken!.string)
    }else {
      return rangeForTokenInsertion()
    }
  }
  
  func rangeForTokenInsertion()-> NSRange {
    textContainer.size = self.bounds.size
    println("size = \(textContainer.size.width) x \(textContainer.size.height)")
    println("label size = \(self.frame.size.width) x \(self.frame.size.height)")
    println("length \(textStorage.length)")
    let glyphIndex = layoutManager.glyphIndexForCharacterAtIndex(textStorage.length-1)
    println("glyph index = \(glyphIndex)")

    var range = layoutManager.truncatedGlyphRangeInLineFragmentForGlyphAtIndex(glyphIndex)
    println("range = \(range.location) x \(range.length)")
    if (range.length > 0 && customTruncationEnabled) {
      range.length += attributedTruncationToken!.length
      range.location -= attributedTruncationToken!.length
    }
    return range
  }

//  This method removes attributes from the truncated range.
//  TruncatedRange is defined as the pattern range which overlaps the range of
//  truncation token. When the truncation token is set, the attributes of the
//  truncated range should be removed.
  
  func removeAttributeForTruncatedRange() {
    let truncationRange = rangeOfTruncationToken()
    for (key,descriptor) in patternDescriptorDictionary {
      let ranges = descriptor.patternRangesForString(attributedText.string)
      for range in ranges {
        let truncationRange = rangeOfTruncationToken()
        let isTruncationRange = NSEqualRanges(range, truncationRange)
        let intersectionRange = NSIntersectionRange(range, truncationRange)
        let isRangeTruncated =  (intersectionRange.length > 0) && (range.location < truncationRange.location)
        //Remove attributes if the range is truncated
        if (isRangeTruncated) {
          let visibleRange = NSMakeRange(range.location,range.length - intersectionRange.length);
          if let attributes = descriptor.patternAttributes {
            for (name,NSObject) in attributes {
              textStorage.removeAttribute(name, range: visibleRange)
            }
            redrawTextForRange(range)
          }
        }
        
      }
    }
    
  }
  
  func truncationTokenAppended()-> Bool {
    var isAppended = false
    if let truncationToken = attributedTruncationToken {
      if let string = textStorage.string as NSString? {
        isAppended = string.rangeOfString(attributedTruncationToken!.string).location != NSNotFound
      }
    }
    return isAppended
  }
}

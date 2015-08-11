//
//  TouchHandler.swift
//  SHResponsiveLabel
//
//  Created by hsusmita on 31/07/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

import Foundation
import UIKit

extension SHResponsiveLabel {
  
  public override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    let touchLocation = (touches.first as! UITouch).locationInView(self)
    let index = characterIndexAtLocation(touchLocation)
    var rangeOfTappedText = NSMakeRange(NSNotFound, 0)
    if let currentString = textStorage as NSAttributedString? {
      if index < currentString.length {
        rangeOfTappedText = layoutManager.rangeOfNominallySpacedGlyphsContainingIndex(index)
      }
    }
    let shouldDetectTouch = shouldHandleTouchAtIndex(index) && !patternTouchInProgress()
    if shouldDetectTouch {
      handleTouchBeginForRange(rangeOfTappedText)
    }else {
      super.touchesBegan(touches, withEvent: event)
    }
  }
  
  public override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
    super.touchesMoved(touches, withEvent: event)
  }
  
  public override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    super.touchesCancelled(touches, withEvent: event)
    handleTouchCancelled()
  }
  
  public override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
    if patternTouchInProgress() && shouldHandleTouchAtIndex(selectedRange!.location) {
      removeHighlightingForIndex(selectedRange!.location)
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(0.05 * Double(NSEC_PER_SEC))),
        dispatch_get_main_queue(),{
          self.handleTouchEnd()
      })
    }else {
      super.touchesEnded(touches, withEvent: event)
    }
  }
  
  //MARK - Helper Methods
  
  func handleTouchBeginForRange(range:NSRange) {
    if (!patternTouchInProgress()) {
      //Set global variable
      selectedRange = range
      currentAttributedString = NSMutableAttributedString(attributedString: textStorage)
      addHighlightingForIndex(range.location)
    }
  }
  
  func handleTouchEnd() {
    if patternTouchInProgress() {
      
      performActionAtIndex(selectedRange!.location)
    }
    //Clear global Variable
    selectedRange = nil
    currentAttributedString = nil
  }
  
  func handleTouchCancelled() {
    if patternTouchInProgress() {
    removeHighlightingForIndex(self.selectedRange!.location)
    }
    selectedRange = NSMakeRange(NSNotFound, 0)
    currentAttributedString = nil
  }
  
  func addHighlightingForIndex(index:Int) {
    if (index < self.textStorage.length) {
      var patternRange = NSMakeRange(NSNotFound, 0)
    
      if let backgroundcolor = textStorage.attribute(RLHighlightedBackgroundColorAttributeName,atIndex:index,effectiveRange:&patternRange) as? UIColor {
        textStorage.addAttribute(NSBackgroundColorAttributeName, value: backgroundcolor, range: patternRange)
      }
      if let foregroundcolor = textStorage.attribute(RLHighlightedForegroundColorAttributeName,atIndex:index,effectiveRange:&patternRange) as? UIColor {
        textStorage.addAttribute(NSForegroundColorAttributeName, value: foregroundcolor, range: patternRange)
      }
      self.redrawTextForRange(patternRange)
    }
  }
  
  func removeHighlightingForIndex(index:Int) {
    if let range = selectedRange {
      if index < textStorage.length {
        var patternRange = NSMakeRange(NSNotFound, 0)
        
        if let backgroundcolor = currentAttributedString!.attribute(NSBackgroundColorAttributeName,atIndex:index,effectiveRange:&patternRange) as? UIColor {
          textStorage.addAttribute(NSBackgroundColorAttributeName, value: backgroundcolor, range: patternRange)
        }else {
          textStorage.removeAttribute(NSBackgroundColorAttributeName, range: patternRange)
        }
        if let foregroundcolor = currentAttributedString!.attribute(NSForegroundColorAttributeName,atIndex:index,effectiveRange:&patternRange) as? UIColor {
          textStorage.addAttribute(NSForegroundColorAttributeName, value: foregroundcolor, range: patternRange)
        }
        self.redrawTextForRange(patternRange)
      }
    }
    
  }
  
  /**
  Returns index of character located a given point
  @param location: CGPoint
  @return character index
  */
  
  func characterIndexAtLocation(location:CGPoint)-> Int {
    var chracterIndex = NSNotFound
    if let currentString = textStorage as NSAttributedString? {
      let glyphIndex = glyphIndexForLocation(location)
      var lineRangePointer = NSRangePointer()
      var lineRect = layoutManager.lineFragmentRectForGlyphAtIndex(glyphIndex, effectiveRange: lineRangePointer)
      lineRect.size.height = 60.0 //Adjustment to increase tap area
      if (CGRectContainsPoint(lineRect, location)) {
        chracterIndex = layoutManager.characterIndexForGlyphAtIndex(glyphIndex)
      }
    }
    return chracterIndex
  }
  
  func glyphIndexForLocation(location:CGPoint)-> (Int) {
    let glyphRange = self.layoutManager.glyphRangeForTextContainer(self.textContainer)
    let textOffset = self.textOffsetForGlyphRange(glyphRange)
    // Get the touch location and use text offset to convert to text cotainer coords
    let finalLocation = CGPointMake(location.x - textOffset.x, location.y - textOffset.y)
    return self.layoutManager.glyphIndexForPoint(finalLocation, inTextContainer: self.textContainer)
  }
  
  func performActionAtIndex(index:NSInteger) {
    var patternRange = NSMakeRange(NSNotFound, 0)
    if index < textStorage.length {
      if let tapResponder = textStorage.attribute(RLTapResponderAttributeName, atIndex: index, effectiveRange: &patternRange) as? PatternTapResponder {
        let string = NSString(string: textStorage.string)
        tapResponder.perform(string.substringWithRange(patternRange))
      }
    }
  }
  
  func patternTouchInProgress()-> Bool {
    if let range = selectedRange as NSRange? {
      return true
    }else {
      return false
    }
  }
  
  func configureGestures() {
    self.userInteractionEnabled = true
  }
  
//  This method checks whether the given index can handle touch
//  Touch will be handled if any of these attributes are set: RLTapResponderAttributeName
//  or RLHighlightedBackgroundColorAttributeName
//  or RLHighlightedForegroundColorAttributeName
//  @param index: NSInteger - Index to be checked
//  @return It returns a BOOL incating if touch handling is enabled or not
  
  func shouldHandleTouchAtIndex(index : NSInteger)-> Bool {
    var touchAttributesSet = false
    if index < textStorage.length {
      var rangePointer = NSRangePointer()
      if let dictionary =  textStorage.attributesAtIndex(index, effectiveRange: rangePointer) as [NSObject:AnyObject]? {
        let keys = dictionary.keys.filter({keyString -> Bool in
          return  keyString == RLTapResponderAttributeName ||
            keyString == RLHighlightedBackgroundColorAttributeName ||
            keyString == RLHighlightedForegroundColorAttributeName
        }).array
        touchAttributesSet = keys.count > 0
      }
    }
    return touchAttributesSet
  }
}


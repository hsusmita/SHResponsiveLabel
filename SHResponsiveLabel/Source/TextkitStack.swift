//
//  TextkitStack.swift
//  SHResponsiveLabel
//
//  Created by Susmita Horrow on 20/08/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

import Foundation
import UIKit

public let RLTapResponderAttributeName1 : String = "Tap Responder Name"
public let RLHighlightedForegroundColorAttributeName1: String = "HighlightedForegroundColor"
public let RLHighlightedBackgroundColorAttributeName1:String = "HighlightedBackgroundColor"


internal class TextkitStack:NSObject {
	
	let layoutManager : NSLayoutManager
	let textContainer : NSTextContainer
	let textStorage : NSTextStorage
  var gestureRecognizer: UIGestureRecognizer? {
    didSet {
      gestureRecognizer!.addTarget(self, action: "handleGesture")
    }
  }
  
  var textOffset : CGPoint
	
	override init() {
		textContainer = NSTextContainer()
		layoutManager = NSLayoutManager()
		textStorage = NSTextStorage()
		
		textContainer.lineFragmentPadding = 0;
		textContainer.widthTracksTextView = true;
		textContainer.layoutManager = layoutManager
		
		self.layoutManager.addTextContainer(textContainer)
		textStorage.addLayoutManager(self.layoutManager)
		self.layoutManager.textStorage = textStorage
    
    textOffset = CGPointZero
    super.init()
//		textContainer.lineBreakMode = self.lineBreakMode;
      gestureRecognizer = UITapGestureRecognizer(target: self, action: "handleGesture")
	}
  
//  init(aGestureRecognizer:UIGestureRecognizer) {
//    textContainer = NSTextContainer()
//    layoutManager = NSLayoutManager()
//    textStorage = NSTextStorage()
//    
//    textContainer.lineFragmentPadding = 0;
//    textContainer.widthTracksTextView = true;
//    textContainer.layoutManager = layoutManager
//    
//    self.layoutManager.addTextContainer(textContainer)
//    textStorage.addLayoutManager(self.layoutManager)
//    self.layoutManager.textStorage = textStorage
//    
//    textOffset = CGPointZero
//    gestureRecognizer = aGestureRecognizer
//    gestureRecognizer!.addTarget(self, action: Selector(handleGesture()))
//  }
  
  func handleGesture() {
    println("state = \(gestureRecognizer?.state.rawValue)")
    switch gestureRecognizer!.state {
    case .Began:
      println("UIGestureRecognizerState.Began")
    case .Ended:
      println("UIGestureRecognizerState.Ended")
    default:
      break;
    }
  }
	
	func updateTextStorage(attributedText:NSAttributedString?) {
		if (attributedText!.length > 0) {
			textStorage.setAttributedString(attributedText!)
			//      textContainer.size = rectFittingText(bounds.size, lineCount: numberOfLines).size
//			redrawTextForRange(NSMakeRange(0, attributedText!.length))
		}
//		for (key,descriptor) in patternDescriptorDictionary {
//			self.addPatternAttributes(descriptor)
//		}
	}
	
	func updateTextContainerSize(size:CGSize) {
		textContainer.size = size
	}
	
	internal func drawTextInRect(rect: CGRect) {
		var textOffset = CGPointZero
		var glyphRange = layoutManager.glyphRangeForTextContainer(textContainer)
		textOffset = textOffsetForGlyphRange(glyphRange,rect: rect);
		
		layoutManager.drawBackgroundForGlyphRange(glyphRange, atPoint: textOffset)
		layoutManager.drawGlyphsForGlyphRange(glyphRange, atPoint: textOffset)
	}
	
	internal func textOffsetForGlyphRange(glyphRange:NSRange,rect:CGRect)-> CGPoint {
		var textOffset = CGPointZero
		var textBounds = layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer: textContainer)
		let paddingHeight = (rect.size.height - textBounds.size.height) / 2.0
		if (paddingHeight > 0){
			textOffset.y = paddingHeight
		}
		return textOffset
	}
  
  func boundingRectForRange(range:NSRange,enclosingRect:CGRect)-> CGRect {
    var glyphRange = NSMakeRange(NSNotFound, 0)
    layoutManager.characterRangeForGlyphRange(range, actualGlyphRange: &glyphRange)
    
    var rect = layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer: textContainer)
    let totalGlyphRange = layoutManager.glyphRangeForTextContainer(textContainer)
    let point = textOffsetForGlyphRange(totalGlyphRange,rect:enclosingRect)
    rect.origin.y += point.y
    return rect
  }
  
	func rectFittingText(size:CGSize, lineCount:Int, font:UIFont)-> CGRect {
		textContainer.size = size
		self.textContainer.maximumNumberOfLines = lineCount
    
		let glyphRange = layoutManager.glyphRangeForTextContainer(textContainer);
		var textBounds = layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer: textContainer)
		let totalLines = Int(textBounds.size.height / font.lineHeight);
		if (lineCount > 0 && (lineCount < totalLines)) {
			textBounds.size.height -= CGFloat(totalLines - lineCount) * font.lineHeight
		}else if (lineCount > 0 && (lineCount > totalLines)) {
			textBounds.size.height += CGFloat(lineCount - totalLines) * font.lineHeight
		}
		textBounds.size.width = ceil(textBounds.size.width);
		textBounds.size.height = ceil(textBounds.size.height);
		textContainer.size = textBounds.size
		return textBounds
	}
	
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
    // Get the touch location and use text offset to convert to text cotainer coords
    let finalLocation = CGPointMake(location.x - textOffset.x, location.y - textOffset.y)
    return self.layoutManager.glyphIndexForPoint(finalLocation, inTextContainer: self.textContainer)
  }
  
  func rangeLocation(location:CGPoint)-> (NSRange) {
    let index = characterIndexAtLocation(location)
    var rangeOfText = NSMakeRange(NSNotFound, 0)
    if let currentString = textStorage as NSAttributedString? {
      if index < currentString.length {
        rangeOfText = layoutManager.rangeOfNominallySpacedGlyphsContainingIndex(index)
      }
    }
    return rangeOfText
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
          return  keyString == RLTapResponderAttributeName1 ||
            keyString == RLHighlightedBackgroundColorAttributeName1 ||
            keyString == RLHighlightedForegroundColorAttributeName1
        }).array
        touchAttributesSet = keys.count > 0
      }
    }
    return touchAttributesSet
  }

  func hasText()-> Bool {
    return self.textStorage.length > 0
  }
  
}

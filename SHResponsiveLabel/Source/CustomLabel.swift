//
//  CustomizedLabel.swift
//  SHResponsiveLabel
//
//  Created by hsusmita on 21/08/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

import UIKit


public class CustomLabel: UILabel {
  
  	let textkitStack:TextkitStack
	
  	override init(frame: CGRect) {
  		textkitStack = TextkitStack()
  
  		super.init(frame: frame)
  
  //		setup()
  		configureGestures()
  	}
  	override public func layoutSubviews() {
  		textkitStack.textContainer.size = self.bounds.size;
  	}
  	required public init(coder aDecoder: NSCoder) {
  
  		textkitStack = TextkitStack()
  		super.init(coder: aDecoder)
  		textkitStack.textContainer.lineBreakMode = self.lineBreakMode;
      userInteractionEnabled = true
//      let gesture = UITouchGestureRecognizer()
//      addGestureRecognizer(gesture)
//      textkitStack.gestureRecognizer = gesture
  //    configureGestures()
  	}
	
   public  override func awakeFromNib() {
    initialTextConfiguration()
        textkitStack.textContainer.lineBreakMode = self.lineBreakMode;
	
    		layoutIfNeeded()
    super.awakeFromNib()
    
  }
  func initialTextConfiguration() {
    var currentText : NSAttributedString?
    if (attributedText.length > 0) {
      //			currentText = self.attributedText.wordWrappedAttributedString()
    }else {
      currentText = NSAttributedString(string: text!, attributes: attributesFromProperties())
    }
    if (currentText != nil) {
      //			textkitStack.updateTextStorage(currentText)
      //			appendTokenIfNeeded()
    }
  }
  override public var text: String! {
    didSet {
      let currentText = NSAttributedString(string: text!, attributes: attributesFromProperties())
      			textkitStack.updateTextStorage(currentText)
    }
  }
  func configureGestures() {
    self.userInteractionEnabled = true
  }
  
  
  func attributesFromProperties()-> [String:AnyObject] {
    // Setup shadow attributes
    var shadow:NSShadow = NSShadow.new()
    if let shadowColor = self.shadowColor {
      shadow.shadowColor = shadowColor
      shadow.shadowOffset = self.shadowOffset
    }else {
      shadow.shadowOffset = CGSizeMake(0, -1)
      shadow.shadowColor = nil
    }
    
    // Setup colour attributes
    var colour = self.textColor
    if (!self.enabled) {
      colour = UIColor.lightGrayColor()
    }else if (self.highlighted) {
      colour = self.highlightedTextColor
    }
    
    // Setup paragraph attributes
    var paragraph = NSMutableParagraphStyle.new()
    paragraph.alignment = self.textAlignment
    
    // Create the dictionary
    return [NSFontAttributeName:self.font,
      NSForegroundColorAttributeName:colour,
      NSShadowAttributeName:NSShadowAttributeName,
      NSParagraphStyleAttributeName : paragraph]
  }
  
  
  
  public override func drawTextInRect(rect: CGRect) {
    		textkitStack.drawTextInRect(rect)
  }
  
  	public override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
      let requiredRect = textkitStack.rectFittingText(bounds.size, lineCount: numberOfLines, font: self.font)
  		return requiredRect
  	}
	
  public override class func requiresConstraintBasedLayout()-> Bool {
    return true
  }
}

//extension NSAttributedString {
//	func wordWrappedAttributedString()-> NSAttributedString {
//		var processedString = self
//		if self.length > 0 {
//			var range = NSRangePointer()
//			if let paragraphStyle = attribute(NSParagraphStyleAttributeName, atIndex: 0, effectiveRange: range) as? NSParagraphStyle {
//
//				// Remove the line breaks
//				var mutableParagraphStyle: NSMutableParagraphStyle = (paragraphStyle.mutableCopy() as? NSMutableParagraphStyle)!
//				mutableParagraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
//				// Apply new style
//				var restyled = NSMutableAttributedString(attributedString: self)
//				restyled.addAttribute(NSParagraphStyleAttributeName, value: mutableParagraphStyle, range: NSMakeRange(0, restyled.length))
//				processedString = restyled
//			}
//		}
//		return processedString
//	}
//}

extension CustomLabel {

  public override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    let gesture = UITapGestureRecognizer()

    let touchLocation = (touches.first as! UITouch).locationInView(self)
    let index = textkitStack.characterIndexAtLocation(touchLocation)
    println("index = \(index)")
//    let rangeOfTappedText = textkitStack.rangeLocation(touchLocation)
//     let shouldDetectTouch = textkitStack.shouldHandleTouchAtIndex(index) && !patternTouchInProgress()
//    var rangeOfTappedText = NSMakeRange(NSNotFound, 0)
//    if let currentString = textStorage as NSAttributedString? {
//      if index < currentString.length {
//        rangeOfTappedText = layoutManager.rangeOfNominallySpacedGlyphsContainingIndex(index)
//      }
//    }
//    let shouldDetectTouch = shouldHandleTouchAtIndex(index) && !patternTouchInProgress()
//    if shouldDetectTouch {
//      handleTouchBeginForRange(rangeOfTappedText)
//    }else {
//      super.touchesBegan(touches, withEvent: event)
//    }
  }

  public override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
    super.touchesMoved(touches, withEvent: event)
  }

  public override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    super.touchesCancelled(touches, withEvent: event)
  }

  public override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
//    if patternTouchInProgress() && shouldHandleTouchAtIndex(selectedRange!.location) {
//      removeHighlightingForIndex(selectedRange!.location)
//      dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(0.05 * Double(NSEC_PER_SEC))),
//        dispatch_get_main_queue(),{
//          self.handleTouchEnd()
//      })
//    }else {
//      super.touchesEnded(touches, withEvent: event)
//    }
  }
}


//
//  CustomizedLabel.swift
//  SHResponsiveLabel
//
//  Created by hsusmita on 21/08/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

import UIKit


public class CustomLabel: UILabel {
  
    let textkitStack:PatternTextkitStack
    var selectedRange: NSRange?
    var currentAttributedString: NSAttributedString?
    
    var truncationToken : NSString?
    var truncatedPatternRange : NSRange?
    var truncatedRange: NSRange?
    var attributedTruncationToken : NSAttributedString?
    
    var customTruncationEnabled : Bool {
      didSet {
        setNeedsDisplay()
      }
    }

  override init(frame: CGRect) {
    textkitStack = PatternTextkitStack()
    customTruncationEnabled = false
    
    selectedRange = NSMakeRange(NSNotFound, 0)
    currentAttributedString = NSAttributedString()
    super.init(frame: frame)
    
    configureGestures()
  }
  	override public func layoutSubviews() {
  		textkitStack.textContainer.size = self.bounds.size;
  	}
  	required public init(coder aDecoder: NSCoder) {
  
  		textkitStack = PatternTextkitStack()
      customTruncationEnabled = false

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
      self.customTruncationEnabled ? appendTokenIfNeeded() : removeTokenIfPresent()
    		textkitStack.drawTextInRect(rect)
  }
  
  	public override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
      let requiredRect = textkitStack.rectFittingText(bounds.size, lineCount: numberOfLines, font: self.font)
  		return requiredRect
  	}
	
  public override class func requiresConstraintBasedLayout()-> Bool {
    return true
  }
 
  func setTextWithTruncation(text:String,truncation:Bool) {
    self.text = text
    customTruncationEnabled = truncation
  }
  
  func setAttributedTextWithTruncation(text:NSAttributedString,truncation:Bool) {
    self.attributedText = text
    customTruncationEnabled = truncation
  }
  
  func setAttributedTruncationToken(attributedTruncationToken:NSAttributedString, action:PatternTapResponder) {
    removeTokenIfPresent()
   self.updateTruncationToken(attributedTruncationToken, action: action)
    setNeedsDisplay()
  }
  
  func updateTruncationToken(truncationToken:NSAttributedString,action:PatternTapResponder) {
    //Disable old pattern if present
    if let tokenString = attributedTruncationToken as NSAttributedString? {
      let patternKey = String(format: kRegexFormatForSearchWord,tokenString.string)
      textkitStack.disablePatternDetection(patternKey)
//      if let descriptor = patternDescriptorDictionary[patternKey] {
//        disablePatternDetection(descriptor)
//      }
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
  
  func enableHashTagDetection(dictionary:[String:AnyObject]) {
    textkitStack.enablePatternDetection(kRegexStringForHashTag, dictionary: dictionary)
    setNeedsDisplay()
  }
  
  func disableHashTagDetection() {
    textkitStack.disablePatternDetection(kRegexStringForHashTag)
    setNeedsDisplay()
  }
  
  func enableUserHandleDetection(dictionary:[String:AnyObject]) {
    textkitStack.enablePatternDetection(kRegexStringForUserHandle, dictionary: dictionary)
    setNeedsDisplay()
  }
  
  func disableUserHandleDetection() {
    textkitStack.disablePatternDetection(kRegexStringForUserHandle)
    setNeedsDisplay()
  }
  
  func enableURLDetection(dictionary:[String:AnyObject]) {
    textkitStack.enableDataDetector(NSTextCheckingType.Link, dictionary: dictionary)
    setNeedsDisplay()

  }
  
  func disableURLDetection() {
    textkitStack.disableDataDetector(NSTextCheckingType.Link)
    setNeedsDisplay()
  }
  
  func enableStringDetection(string:String,dictionary:[String:AnyObject]) {
    let key = String(format:kRegexFormatForSearchWord,string)
    textkitStack.enablePatternDetection(key, dictionary: dictionary)
    setNeedsDisplay()
  }
  
  func disableStringDetection(string:String) {
    let key = String(format:kRegexFormatForSearchWord,string)
    textkitStack.disablePatternDetection(key)
    setNeedsDisplay()
  }
  
  func enableDetectionForStrings(stringsArray:[String],dictionary:[String:AnyObject]) {
    for string in stringsArray {
      enableStringDetection(string, dictionary: dictionary)
    }
  }
  
  func disableDetectionForStrings(stringsArray:[String]) {
    for string in stringsArray {
      disableStringDetection(string)
    }
  }
  
  func enablePatternDetection(patternDescriptor:PatternDescriptor) {
    textkitStack.enablePatternDetection(patternDescriptor)
    setNeedsDisplay()
  }
  
  func disablePatternDetection(patternDescriptor:PatternDescriptor) {
    textkitStack.disablePatternDetection(patternDescriptor)
    setNeedsDisplay()
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

 /* public override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    let gesture = UITapGestureRecognizer()

    let touchLocation = (touches.first as! UITouch).locationInView(self)
    let index = textkitStack.characterIndexAtLocation(touchLocation)
    println("index = \(index)")
    let rangeOfTappedText = textkitStack.rangeLocation(touchLocation)
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
    if selectedRange.location != NSNotFound && shouldHandleTouchAtIndex(selectedRange.location) {
      removeHighlightingForIndex(selectedRange.location)
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(0.05 * Double(NSEC_PER_SEC))),
        dispatch_get_main_queue(),{
          self.handleTouchEnd()
      })
    }else {
      super.touchesEnded(touches, withEvent: event)
    }
  }
  //  This method checks whether the given index can handle touch
  //  Touch will be handled if any of these attributes are set: RLTapResponderAttributeName
  //  or RLHighlightedBackgroundColorAttributeName
  //  or RLHighlightedForegroundColorAttributeName
  //  @param index: NSInteger - Index to be checked
  //  @return It returns a BOOL incating if touch handling is enabled or not
  
  func shouldHandleTouchAtIndex(index : NSInteger)-> Bool {
    var touchAttributesSet = false
    let textStorage = textkitStack.textStorage
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
  currentAttributedString = nil*/
}

extension CustomLabel {
  /**
  This method appends truncation token if required
  Conditions : 1. self.customTruncationEnabled = YES
  2. self.attributedTruncationToken.length > 0
  3. Truncation token is not appended
  */

  func appendTokenIfNeeded() {
    if shouldAppendTruncationToken() && !truncationTokenAppended() {
      if textkitStack.isNewLinePresent() {
        //Append token string at the end of last visible line
        let range = textkitStack.rangeForTokenInsertionForStringWithNewLine()
        if (range.length > 0) {
          textkitStack.textStorage.replaceCharactersInRange(range, withAttributedString: attributedTruncationToken!)
        }
      }
      //Check for truncation range and append truncation token if required
      let tokenRange = textkitStack.rangeForTextInsertion(attributedTruncationToken!.string)
      if tokenRange.location != NSNotFound {
        // set truncated range
        self.truncatedRange = NSMakeRange(tokenRange.location, textkitStack.textStorage.length - tokenRange.location)
        // set truncatedPatternRange
        for range in textkitStack.rangeAttributesDictionary.keys {
          if isRangeTruncated(range.rangeValue) {
            self.truncatedPatternRange = range.rangeValue
          }
        }
        // Append truncation token
        textkitStack.textStorage.replaceCharactersInRange(tokenRange, withAttributedString: attributedTruncationToken!)
    }
    // Remove attribute from truncated pattern
    removeAttributeForTruncatedRange()
      // Add attribute to truncation range
    addAttributesToTruncationToken()
    }
  }
  
  func removeTokenIfPresent() {
    if truncationTokenAppended() {
      let storageText = textkitStack.textStorage.string as NSString
      let truncationRange = storageText.rangeOfString(attributedTruncationToken!.string)
      let visibleString = textkitStack.textStorage.attributedSubstringFromRange(NSMakeRange(0, truncationRange.location))
      let hiddenString = attributedText.attributedSubstringFromRange(self.truncatedRange!)
      var finalString = NSMutableAttributedString(attributedString:visibleString)
      finalString.appendAttributedString(hiddenString)
      textkitStack.textStorage.setAttributedString(finalString)
      addAttributeForTruncatedRange()
    }
  }
  
  func shouldAppendTruncationToken()-> Bool {
    var shouldAppend = false
    if let token = self.attributedTruncationToken {
      shouldAppend = textkitStack.hasText() && self.customTruncationEnabled
    }
    return shouldAppend
  }
  
  func truncationTokenAppended()-> Bool {
    var appended = false
    if let token = self.attributedTruncationToken {
      if let storageText = textkitStack.textStorage.string as NSString? {
        appended = storageText.rangeOfString(attributedTruncationToken!.string).location != NSNotFound
      }
    }
    return appended
  }
  
  func addAttributeForTruncatedRange() {
    if let truncatedRange = self.truncatedPatternRange {
      if let patternAttributes = textkitStack.rangeAttributesDictionary[truncatedRange] {
        textkitStack.textStorage.addAttributes(patternAttributes, range: truncatedRange)
      }
    }
  }
  
  func removeAttributeForTruncatedRange() {
    let storageString = textkitStack.textStorage.string as NSString
    let tokenRange = storageString.rangeOfString(attributedTruncationToken!.string)
    if (tokenRange.length > 0 && self.truncatedPatternRange?.length > 0) {
      let range =  self.truncatedPatternRange!
      if let patternAttributes = textkitStack.rangeAttributesDictionary[range] {
        for (key,value) in patternAttributes {
          textkitStack.textStorage.removeAttribute(key, range: range)
        }
      }
    }
  }
  
  func addAttributesToTruncationToken() {
    let storageString = textkitStack.textStorage.string as NSString
    let truncationRange = storageString.rangeOfString(attributedTruncationToken!.string)
    if (truncationRange.length > 0) {
//      let key = String(format: kRegexFormatForSearchWord, arguments: self.attributedTruncationToken!.string)
//      textkitStack.enablePatternDetection(<#patternDescriptor: PatternDescriptor#>)
//      if let descriptor = self.patternDescriptorDictionary[key] {
//        textkitStack.textStorage.addAttributes(descriptor.patternAttributes!, range: truncationRange)
//      }
    }
  }
  
  func isRangeTruncated(range:NSRange) -> (Bool) {
    var isTruncated = false
    let storageString = textkitStack.textStorage.string as NSString
    if attributedTruncationToken?.length > 0 {
    let truncationRange = storageString.rangeOfString(attributedTruncationToken!.string)
      if truncationRange.location != NSNotFound {
        isTruncated = ((NSIntersectionRange(range, truncationRange).length > 0) && (range.location < truncationRange.location))
      }
    }
    return isTruncated
  }
}

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
    var patternDescriptorDictionary: [String:PatternDescriptor]
    var rangeAttributesDictionary:[NSValue:[String:AnyObject]]
    
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
  		textkitStack = TextkitStack()
      patternDescriptorDictionary =  Dictionary()
      rangeAttributesDictionary = Dictionary()
      customTruncationEnabled = false
  		super.init(frame: frame)
  
  //		setup()
  		configureGestures()
  	}
  	override public func layoutSubviews() {
  		textkitStack.textContainer.size = self.bounds.size;
  	}
  	required public init(coder aDecoder: NSCoder) {
  
  		textkitStack = TextkitStack()
      patternDescriptorDictionary =  Dictionary()
      rangeAttributesDictionary = Dictionary()
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

  
  func enableHashTagDetection(dictionary:[String:AnyObject]) {
    var error:NSError?
    let regex = NSRegularExpression(pattern:kRegexStringForHashTag, options: NSRegularExpressionOptions.allZeros, error: &error)
    let descriptor = PatternDescriptor(regularExpression: regex!, searchType: PatternSearchType.All, patternAttributes: dictionary)
    enablePatternDetection(descriptor)
  }
  
  func disableHashTagDetection() {
    disablePatternDetection(patternDescriptorDictionary[kRegexStringForHashTag]!)
  }
  
  func enableUserHandleDetection(dictionary:[String:AnyObject]) {
    var error:NSError?
    let regex = NSRegularExpression(pattern:kRegexStringForUserHandle, options: NSRegularExpressionOptions.allZeros, error: &error)
    let descriptor = PatternDescriptor(regularExpression: regex!, searchType: PatternSearchType.All, patternAttributes: dictionary)
    enablePatternDetection(descriptor)
  }
  
  func disableUserHandleDetection() {
    disablePatternDetection(patternDescriptorDictionary[kRegexStringForUserHandle]!)
  }
  
  func enableURLDetection(dictionary:[String:AnyObject]) {
    var error:NSError?
    let regex = NSDataDetector(types: NSTextCheckingType.Link.rawValue, error: &error)
    let descriptor = PatternDescriptor(regularExpression: regex!, searchType: PatternSearchType.All, patternAttributes: dictionary)
    enablePatternDetection(descriptor)
  }
  
  func disableURLDetection() {
    let key = String(NSTextCheckingType.Link.rawValue)
    disablePatternDetection(patternDescriptorDictionary[key]!)
  }
  
  func enableStringDetection(string:String,dictionary:[String:AnyObject]) {
    var error:NSError?
    let pattern = String(format: kRegexFormatForSearchWord,string)
    let regex = NSRegularExpression(pattern:pattern, options: NSRegularExpressionOptions.allZeros, error: &error)
    let descriptor = PatternDescriptor(regularExpression: regex!, searchType: PatternSearchType.All, patternAttributes: dictionary)
    enablePatternDetection(descriptor)
  }
  
  func disableStringDetection(string:String) {
    let key = kRegexFormatForSearchWord + string
    disablePatternDetection(patternDescriptorDictionary[key]!)
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
    let patternKey = patternNameKeyForPatternDescriptor(patternDescriptor)
    patternDescriptorDictionary[patternKey] = patternDescriptor
    addPatternAttributes(patternDescriptor)
  }
  
  func disablePatternDetection(patternDescriptor:PatternDescriptor) {
    let patternKey = patternNameKeyForPatternDescriptor(patternDescriptor)
    patternDescriptorDictionary.removeValueForKey(patternKey)
    removePatternAttributes(patternDescriptor)
  }
  
  // MARK - Pattern Matching
  
  /**
  This method searches ranges for patternDescriptor and stores in rangeAttributeDictionary,
  adds corresponding entry to self.rangeAttributeDictionary.
  Then the attributes are added to those ranges depending upon the following conditions
  
  1. The range is not truncated by truncation token
  
  2. The range is out of bound of current textStorage
  
  @param patternDescriptor : PatternDescriptor
  */
  
  func addPatternAttributes(patternDescriptor:PatternDescriptor) {
    if attributedText.length > 0 {
      //Generate ranges for attributed text of the label
      let patternRanges = patternDescriptor.patternRangesForString(attributedText.string)
      for range in patternRanges { //Apply attributes to the ranges conditionally
        rangeAttributesDictionary[range] = patternDescriptor.patternAttributes
        if isRangeTruncated(range) {
          truncatedPatternRange = range
        }else if range.location < textkitStack.textStorage.length {
          textkitStack.textStorage.addAttributes(patternDescriptor.patternAttributes!, range: range)
          
        }
        let rect = textkitStack.boundingRectForRange(range, enclosingRect: self.bounds)
        setNeedsDisplayInRect(rect)
      }
    }
  }
  
  func removePatternAttributes(patternDescriptor:PatternDescriptor) {
    if attributedText.length > 0 {
      //Generate ranges for attributed text of the label
      let patternRanges = patternDescriptor.patternRangesForString(attributedText.string)
      for range in patternRanges { //Remove attributes from the ranges conditionally
        rangeAttributesDictionary.removeValueForKey(NSValue(range: range))
        if let attributes = patternDescriptor.patternAttributes {
          if isRangeTruncated(range) {
           self.truncatedPatternRange = NSMakeRange(NSNotFound, 0)
          }else if range.location < textkitStack.textStorage.length {
            for (name,NSObject) in attributes {
              textkitStack.textStorage.removeAttribute(name, range: range)
            }
          }
          let rect = textkitStack.boundingRectForRange(range, enclosingRect: self.bounds)
          setNeedsDisplayInRect(rect)
        }
      }
    }
  }
  //    This method returns the key for the given PatternDescriptor stored in patternDescriptorDictionary.
  //    In patternDescriptorDictionary, each entry has the format (NSString, PatternDescriptor).
  //    @param: PatternDescriptor
  //    @return: NSString
  func patternNameKeyForPatternDescriptor(patternDescriptor:PatternDescriptor)-> String {
    let key:String
    if patternDescriptor.patternExpression.isKindOfClass(NSDataDetector) {
      let types = (patternDescriptor.patternExpression as! NSDataDetector).checkingTypes
      key = String(types)
    }else {
      key = patternDescriptor.patternExpression.pattern;
      
    }
    return key
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
        for range in self.rangeAttributesDictionary.keys {
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
      if let patternAttributes = self.rangeAttributesDictionary[truncatedRange] {
        textkitStack.textStorage.addAttributes(patternAttributes, range: truncatedRange)
      }
    }
  }
  
  func removeAttributeForTruncatedRange() {
    let storageString = textkitStack.textStorage.string as NSString
    let tokenRange = storageString.rangeOfString(attributedTruncationToken!.string)
    if (tokenRange.length > 0 && self.truncatedPatternRange?.length > 0) {
      let range =  self.truncatedPatternRange!
      if let patternAttributes = self.rangeAttributesDictionary[range] {
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
      let key = kRegexFormatForSearchWord + self.attributedTruncationToken!.string
      if let descriptor = self.patternDescriptorDictionary[key] {
        textkitStack.textStorage.addAttributes(descriptor.patternAttributes!, range: truncationRange)
      }
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

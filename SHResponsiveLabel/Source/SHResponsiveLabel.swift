//
//  SHResponsiveLabel.swift
//  SHResponsiveLabel
//
//  Created by hsusmita on 03/07/15.
//
//

import Foundation
import UIKit

/**
Custom NSTextAttributeName which takes value of type PatternTapHandler.
It specifies the action to be performed when a range of text with that attribute is tapped.
*/
public let RLTapResponderAttributeName : String = "Tap Responder Name"
public let RLHighlightedForegroundColorAttributeName: String = "HighlightedForegroundColor"
public let RLHighlightedBackgroundColorAttributeName:String = "HighlightedBackgroundColor"

//public typealias PatternTapResponder = (tappedString:String) -> (Void)
public class PatternTapResponder {
  let action:(String)->Void
  init(currentAction:(tappedString:String) -> (Void)) {
    action = currentAction
  }
  public func perform(string:String){
    action(string)
  }
}
/**
Type for responder block to be specfied with RLTapResponderAttributeName
*/
let kRegexStringForHashTag = "(?<!\\w)#([\\w\\_]+)?"
let kRegexStringForUserHandle = "(?<!\\w)@([\\w\\_]+)?"
let kRegexFormatForSearchWord = "(%@)"

public class SHResponsiveLabel:UILabel {

	let layoutManager : NSLayoutManager
	let textContainer : NSTextContainer
	let textStorage : NSTextStorage
	
  var truncationToken : NSString?
	var attributedTruncationToken : NSAttributedString?
  
  var patternDescriptorDictionary: [String:PatternDescriptor]
  
  var selectedRange: NSRange?
  var currentAttributedString: NSAttributedString?

  
  var customTruncationEnabled : Bool {
    didSet {
      if shouldAppendTruncationToken() {
        appendTokenIfNeeded()
      }else {
        removeTokenIfPresent()
      }
    }
  }
	override public var bounds: CGRect {
		didSet {
      textContainer.size = bounds.size
    }
	}

	override public var frame: CGRect {
		didSet {
      textContainer.size = frame.size
    }
	}
	
	override public var preferredMaxLayoutWidth: CGFloat {
		didSet {
      textContainer.size = CGSizeMake(preferredMaxLayoutWidth, bounds.size.height)
		}
	}

	override public var numberOfLines: Int {
		didSet {
      initialTextConfiguration()
		}
	}
	
	override public var text: String! {
		didSet {
      let currentText = NSAttributedString(string: text!, attributes: attributesFromProperties())
      updateTextStorage(currentText)
		}
	}
  
  override public var attributedText: NSAttributedString! {
    didSet {
      updateTextStorage(attributedText)
    }
  }
	
  func initialTextConfiguration() {
    var currentText : NSAttributedString?
    if (attributedText.length > 0) {
        currentText = attributedText
    }else {
      currentText = NSAttributedString(string: text!, attributes: attributesFromProperties())
    }
    if (currentText != nil) {
      updateTextStorage(currentText)
//      textContainer.size = rectFittingText(bounds.size, numberOfLines: numberOfLines).size
      appendTokenIfNeeded()
    }
  }
  
	// MARK: Initializers
	func setup() {
		textContainer.lineFragmentPadding = 0;
		textContainer.maximumNumberOfLines = self.numberOfLines;
		textContainer.lineBreakMode = self.lineBreakMode;
		textContainer.widthTracksTextView = true;
		textContainer.size = self.frame.size;
		textContainer.layoutManager = layoutManager

		self.layoutManager.addTextContainer(textContainer)
		textStorage .addLayoutManager(self.layoutManager)
		self.layoutManager.textStorage = textStorage
	}
	
	override init(frame: CGRect) {
		textContainer = NSTextContainer()
		layoutManager = NSLayoutManager()
		textStorage = NSTextStorage()
		attributedTruncationToken = NSAttributedString.new()
    patternDescriptorDictionary = Dictionary()
    customTruncationEnabled = false

		super.init(frame: frame)
		setup()
		configureGestures()
	}
	
	required public init(coder aDecoder: NSCoder) {
		textContainer = NSTextContainer()
		layoutManager = NSLayoutManager()
		textStorage = NSTextStorage()
		attributedTruncationToken = NSAttributedString.new()
		patternDescriptorDictionary =  Dictionary()
    customTruncationEnabled = false
		super.init(coder: aDecoder)
		setup()
		configureGestures()
	}
	
	 public  override func awakeFromNib() {
    initialTextConfiguration()
    layoutIfNeeded()
    super.awakeFromNib()

	}
	
	override public func layoutSubviews() {
		self.textContainer.size = self.bounds.size;
	}
  
  //MARK: Custom Drawing methods

  func updateTextStorage(attributedText:NSAttributedString?) {
    if (attributedText!.length > 0) {
      textStorage.setAttributedString(attributedText!)
      redrawTextForRange(NSMakeRange(0, attributedText!.length))
    }
  textContainer.size = rectFittingText(bounds.size, numberOfLines: numberOfLines).size
    for (key,descriptor) in patternDescriptorDictionary {
      self.addPatternAttributes(descriptor)
    }
  }
  
  func redrawTextForRange(range:NSRange) {
    var glyphRange = NSMakeRange(NSNotFound, 0)
    layoutManager.characterRangeForGlyphRange(range, actualGlyphRange: &glyphRange);
    var rect = layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer: textContainer)
    let totalGlyphRange = layoutManager.glyphRangeForTextContainer(textContainer)
    let point = textOffsetForGlyphRange(totalGlyphRange)
    rect.origin.y += point.y
    setNeedsDisplayInRect(rect)
  }
  
  public override func drawTextInRect(rect: CGRect) {
    var textOffset = CGPointZero
    var glyphRange = layoutManager.glyphRangeForTextContainer(textContainer)
    textOffset = textOffsetForGlyphRange(glyphRange);
    
    layoutManager.drawBackgroundForGlyphRange(glyphRange, atPoint: textOffset)
    layoutManager.drawGlyphsForGlyphRange(glyphRange, atPoint: textOffset)
  
  }
  
  func textOffsetForGlyphRange(glyphRange:NSRange)-> CGPoint {
    var textOffset = CGPointZero
    var textBounds = layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer: textContainer)
    let paddingHeight = (self.bounds.size.height - textBounds.size.height) / 2.0
    if (paddingHeight > 0){
      textOffset.y = paddingHeight
    }
    
    return textOffset
  }
  
  public override class func requiresConstraintBasedLayout()-> Bool {
    return true
  }
  
  //MARK: Override methods
  
  public override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
    let requiredRect = rectFittingText(bounds.size, numberOfLines: numberOfLines)
    textContainer.size = requiredRect.size
    return requiredRect;
  }
  
  func rectFittingText(size:CGSize, numberOfLines:Int)-> CGRect {
    textContainer.size = size
    if (numberOfLines == 0) {
      self.textContainer.maximumNumberOfLines = Int.max
    }else {
      self.textContainer.maximumNumberOfLines = numberOfLines
    }
    let glyphRange = layoutManager.glyphRangeForTextContainer(textContainer);
    var textBounds = layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer: textContainer)
    let totalLines = Int(textBounds.size.height / self.font.lineHeight);
    if (numberOfLines > 0 && (numberOfLines < totalLines)) {
      textBounds.size.height -= CGFloat(totalLines - numberOfLines) * self.font.lineHeight
    }else if (numberOfLines > 0 && (numberOfLines > totalLines)) {
      textBounds.size.height += CGFloat(numberOfLines - totalLines) * self.font.lineHeight
    }
    textBounds.size.width = ceil(textBounds.size.width);
    textBounds.size.height = ceil(textBounds.size.height);
    return textBounds
  }

	func calcTextOffsetForGlyphRange(glyphRange:NSRange)-> (CGPoint) {
		var textOffset = CGPointZero
		let textBounds = self.layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer: self.textContainer)
		let paddingHeight = (self.bounds.size.height - textBounds.size.height) / 2.0
		if (paddingHeight > 0) {
			textOffset.y = paddingHeight
		}
		return textOffset
	}
	
  //MARK: Helpers
  
  
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

  // MARK - Pattern Matching
  
  func addPatternAttributes(patternDescriptor:PatternDescriptor) {
    if (self.textStorage.length == 0) {return}
    //Generate ranges for attributed text of the label
   let patternRanges = patternDescriptor.patternRangesForString(attributedText.string)
    for range in patternRanges { //Apply attributes to the ranges conditionally
      if (shouldAddAttributesAtRange(range)) {
        textStorage.addAttributes(patternDescriptor.patternAttributes!, range: range)
        redrawTextForRange(range)
      }
    }
  }
  
  func shouldAddAttributesAtRange(range:NSRange)-> Bool {
    let truncationRange = rangeOfTruncationToken()
    let isTruncationRange = NSEqualRanges(range, truncationRange)
    let isRangeOutOfBound = isTruncationRange && (truncationRange.location + truncationRange.length) > self.textStorage.length
    let doesIntersectTruncationRange = NSIntersectionRange(range, truncationRange).length > 0
    return ((!isRangeOutOfBound && !doesIntersectTruncationRange) || isTruncationRange)
  }
  
  func removePatternAttributes(patternDescriptor:PatternDescriptor) {
    if (self.textStorage.length == 0) {return}
    //Generate ranges for current text of textStorage
    let patternRanges = patternDescriptor.patternRangesForString(self.textStorage.string)
    for range in patternRanges { //Remove attributes from the ranges conditionally
      if let attributes = patternDescriptor.patternAttributes {
        for (name,NSObject) in attributes {
          textStorage.removeAttribute(name, range: range)
        }
        redrawTextForRange(range)
      }
    }
  }
  func shouldRemoveAttributesFromRange(range:NSRange)-> Bool {
    let truncationRange = rangeOfTruncationToken()
    let isTruncationRange = NSEqualRanges(range, truncationRange)
    let doesIntersectTruncationRange = NSIntersectionRange(range, truncationRange).length == 0
    return (isTruncationRange || doesIntersectTruncationRange)
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

 // MARK: Public Interfaces

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
    updateTruncationToken(attributedTruncationToken, action: action)
    if(customTruncationEnabled) {
      appendTokenIfNeeded()
    }
  }
  
  func setTruncationIndicatorImage(image:UIImage,size:CGSize,action:PatternDescriptor) {
//    InlineTextAttachment *textAttachment = [[InlineTextAttachment alloc]init];
//    textAttachment.image = image;
//    textAttachment.fontDescender = self.font.descender;
//    textAttachment.bounds = CGRectMake(0, -self.font.descender - self.font.lineHeight/2,size.width,size.height);
//    NSAttributedString *imageAttributedString = [NSAttributedString attributedStringWithAttachment:textAttachment];
//    
//    NSAttributedString *paddingString = [[NSAttributedString alloc]initWithString:@" "];
//    NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc]initWithAttributedString:paddingString];
//    [finalString appendAttributedString:imageAttributedString];
//    [finalString appendAttributedString:paddingString];
//    [self setAttributedTruncationToken:finalString withAction:action];
  }
  
  func enableHashTagDetection(dictionary:[String:AnyObject]) {
    var error:NSError?
    let regex = NSRegularExpression(pattern:kRegexStringForHashTag, options: NSRegularExpressionOptions.allZeros, error: &error)
    let descriptor = PatternDescriptor(regularExpression: regex!, searchType: PatternSearchType.PatternSearchTypeAll, patternAttributes: dictionary)
    enablePatternDetection(descriptor)
  }
  
  func disableHashTagDetection() {
    disablePatternDetection(patternDescriptorDictionary[kRegexStringForHashTag]!)
  }
  
  func enableUserHandleDetection(dictionary:[String:AnyObject]) {
    var error:NSError?
    let regex = NSRegularExpression(pattern:kRegexStringForUserHandle, options: NSRegularExpressionOptions.allZeros, error: &error)
    let descriptor = PatternDescriptor(regularExpression: regex!, searchType: PatternSearchType.PatternSearchTypeAll, patternAttributes: dictionary)
    enablePatternDetection(descriptor)
  }

  func disableUserHandleDetection() {
    disablePatternDetection(patternDescriptorDictionary[kRegexStringForUserHandle]!)
  }
  
  func enableURLDetection(dictionary:[String:AnyObject]) {
    var error:NSError?
    let regex = NSDataDetector(types: NSTextCheckingType.Link.rawValue, error: &error)
    let descriptor = PatternDescriptor(regularExpression: regex!, searchType: PatternSearchType.PatternSearchTypeAll, patternAttributes: dictionary)
    enablePatternDetection(descriptor)
  }
  
  func disableURLDetection() {
    let key = String(NSTextCheckingType.Link.rawValue)
    disablePatternDetection(patternDescriptorDictionary[key]!)
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
  
  func enableStringDetection(string:String,dictionary:[String:NSObject]) {
    var error:NSError?
    let pattern = kRegexFormatForSearchWord + string
    let regex = NSRegularExpression(pattern:pattern, options: NSRegularExpressionOptions.allZeros, error: &error)
    let descriptor = PatternDescriptor(regularExpression: regex!, searchType: PatternSearchType.PatternSearchTypeAll, patternAttributes: dictionary)
    enablePatternDetection(descriptor)
  }

  func disableStringDetection(string:String) {
    let key = kRegexFormatForSearchWord + string
    disablePatternDetection(patternDescriptorDictionary[key]!)
  }
  
  func enableDetectionForStrings(stringsArray:[String],dictionary:[String:NSObject]) {
    for string in stringsArray {
      enableStringDetection(string, dictionary: dictionary)
    }
  }
  
  func disableDetectionForStrings(stringsArray:[String]) {
    for string in stringsArray {
      disableStringDetection(string)
    }
  }
}


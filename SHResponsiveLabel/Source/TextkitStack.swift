//
//  TextkitStack.swift
//  SHResponsiveLabel
//
//  Created by Susmita Horrow on 20/08/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

import Foundation
import UIKit

internal class TextkitStack {
	
	let layoutManager : NSLayoutManager
	let textContainer : NSTextContainer
	let textStorage : NSTextStorage
	
	init() {
		textContainer = NSTextContainer()
		layoutManager = NSLayoutManager()
		textStorage = NSTextStorage()
		
		textContainer.lineFragmentPadding = 0;
		textContainer.widthTracksTextView = true;
		textContainer.layoutManager = layoutManager
		
		self.layoutManager.addTextContainer(textContainer)
		textStorage.addLayoutManager(self.layoutManager)
		self.layoutManager.textStorage = textStorage
		
//		textContainer.maximumNumberOfLines = self.numberOfLines;
//		textContainer.lineBreakMode = self.lineBreakMode;
//		textContainer.size = self.frame.size;

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
		println("SHResponsive : label bounds = \(rect.size.height), textbounds = \(textBounds.height)")

		return textOffset
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
		
		return textBounds
	}
	

	
}

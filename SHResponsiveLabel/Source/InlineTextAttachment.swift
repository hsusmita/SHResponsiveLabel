//
//  InlineTextAttachment.swift
//  SHResponsiveLabel
//
//  Created by hsusmita on 10/08/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

import UIKit

class InlineTextAttachment: NSTextAttachment {
  
  var fontDescender: CGFloat?
  
 override  func  attachmentBoundsForTextContainer(textContainer: NSTextContainer, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
  var superRect = super.attachmentBoundsForTextContainer(textContainer, proposedLineFragment: lineFrag, glyphPosition: position, characterIndex: charIndex)
  if let descender = self.fontDescender {
    superRect.origin.y = descender
  }
  return superRect
  }
   
}

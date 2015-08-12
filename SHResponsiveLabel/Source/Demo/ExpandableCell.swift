//
//  ExpandibleCell.swift
//  SHResponsiveLabel
//
//  Created by hsusmita on 11/08/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

import UIKit

let kCollapseToken = "Read Less"


class ExpandableCell: UITableViewCell {
  
  @IBOutlet weak var customLabel: SHResponsiveLabel!
  
  var delegate : ExpandableCellDelegate?
  
  override func awakeFromNib() {
    let token = NSAttributedString(string: "...Read More",
      attributes: [NSFontAttributeName:self.customLabel.font,
        NSForegroundColorAttributeName:UIColor.brownColor(),
        RLHighlightedBackgroundColorAttributeName:UIColor.blackColor(),
        RLHighlightedForegroundColorAttributeName:UIColor.greenColor()])
    let action = PatternTapResponder {(tappedString)-> (Void) in
        self.delegate?.didTapOnMoreButton(self)
      let messageString = "You have tapped token string"
    }
    customLabel.setAttributedTruncationToken(token, action: action)
  }
  
  func configureCell(text:String, shouldExpand:Bool) {
    if shouldExpand {
      //expand
      let expandedString = text + kCollapseToken
      let finalString = NSMutableAttributedString(string: expandedString)
      let action = PatternTapResponder{(tappedString)-> (Void) in
        self.delegate?.didTapOnMoreButton(self)
      }
      let range = NSMakeRange(count(text), count(kCollapseToken))
      finalString.addAttributes([NSForegroundColorAttributeName:UIColor.redColor(),
                                    RLTapResponderAttributeName:action], range: range)
      finalString.addAttribute(  NSFontAttributeName,value:customLabel.font, range: NSMakeRange(0,finalString.length))
    //      customLabel.numberOfLines = 0
//      customLabel.attributedText = finalString
      customLabel.customTruncationEnabled = false
      customLabel.setAttributedTextWithTruncation(finalString, truncation: false)
      
    }else {
//      customLabel.numberOfLines = 4
//      customLabel.text = text
        customLabel.customTruncationEnabled = true
        customLabel.setTextWithTruncation(text, truncation: true)
    }
  }
}

protocol ExpandableCellDelegate {
  func didTapOnMoreButton(cell:ExpandableCell)
}

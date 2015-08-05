//
//  ViewController.swift
//  SHResponsiveLabel
//
//  Created by hsusmita on 27/07/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var customLabel: SHResponsiveLabel!
  override func viewDidLoad() {
    super.viewDidLoad()
    customLabel.text = "Hello #hashtag @username some more text some more text some more text some more text some more textsome more text";

    let action = PatternTapResponder { (tappedString) -> (Void) in
      println("str = "+tappedString)
    }
    
    let dict = [NSForegroundColorAttributeName:(UIColor.redColor() as AnyObject),
      RLTapResponderAttributeName:action as AnyObject]
    customLabel.enableHashTagDetection(dict)
    customLabel.enableUserHandleDetection([NSForegroundColorAttributeName:(UIColor.brownColor() as AnyObject),
                                           RLHighlightedBackgroundColorAttributeName:(UIColor.blackColor() as AnyObject),
                                           RLHighlightedForegroundColorAttributeName:(UIColor.greenColor() as AnyObject),
      RLTapResponderAttributeName:action as AnyObject])
    let token = NSAttributedString(string: "...More",
      attributes: [NSFontAttributeName:self.customLabel.font,
      NSForegroundColorAttributeName:UIColor.blueColor(),
      RLHighlightedBackgroundColorAttributeName:UIColor.blackColor(),
      RLHighlightedForegroundColorAttributeName:UIColor.greenColor()])
    
    customLabel.setAttributedTruncationToken(token, action: action)
    customLabel.customTruncationEnabled = true
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}


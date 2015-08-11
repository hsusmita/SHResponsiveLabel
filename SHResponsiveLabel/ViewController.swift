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
    customLabel.text = "Hello #hashtag @username some more text www.google.com some more text some more textsome more text hsusmita4@gmail.com";
//
    let action = PatternTapResponder { (tappedString) -> (Void) in
    println("tapped = "+tappedString)
  }

    let dict = [NSForegroundColorAttributeName:UIColor.redColor(),
      RLTapResponderAttributeName:action as AnyObject]
//    customLabel.enableHashTagDetection(dict)
//    customLabel.enableUserHandleDetection([NSForegroundColorAttributeName:(UIColor.brownColor() as AnyObject),
//                                           RLHighlightedBackgroundColorAttributeName:(UIColor.blackColor() as AnyObject),
//                                           RLHighlightedForegroundColorAttributeName:(UIColor.greenColor() as AnyObject),
//      RLTapResponderAttributeName:action as AnyObject])
    let token = NSAttributedString(string: "...More",
      attributes: [NSFontAttributeName:self.customLabel.font,
      NSForegroundColorAttributeName:UIColor.blueColor(),
      RLHighlightedBackgroundColorAttributeName:UIColor.blackColor(),
      RLHighlightedForegroundColorAttributeName:UIColor.greenColor()])
    
    let imageToken = UIImage(named: "Add-Caption-Plus")
    customLabel.setTruncationIndicatorImage(imageToken!, size: CGSizeMake(20, 20), action: action)
//    customLabel.setAttributedTruncationToken(token, action: action)
    customLabel.customTruncationEnabled = true
    
    //Detects email in text
    let emailRegexString = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    var error = NSErrorPointer()
    let regex = NSRegularExpression(pattern: emailRegexString, options: NSRegularExpressionOptions.allZeros, error: error)
    let descriptor = PatternDescriptor(regularExpression: regex!, searchType: PatternSearchType.All, patternAttributes:[NSForegroundColorAttributeName:UIColor.redColor()])
    customLabel.enablePatternDetection(descriptor)
    
    //Detect the word "text" and "some"
    let tapResponder = PatternTapResponder { (tappedString) -> (Void) in
      println("tapped = "+tappedString)
    }
    let attributes = [NSForegroundColorAttributeName:UIColor.brownColor(),
      RLTapResponderAttributeName:action as AnyObject]
    self.customLabel.enableDetectionForStrings(["text","some"], dictionary: attributes)
    
    let hashtagTapAction = PatternTapResponder { (tappedString) -> (Void) in
      println("Hashtag Tapped = "+tappedString)
      }
    self.customLabel.enableHashTagDetection([NSForegroundColorAttributeName:UIColor.redColor(),
                                  RLHighlightedBackgroundColorAttributeName:UIColor.blackColor(),
                                                RLTapResponderAttributeName:hashtagTapAction])
    
    let userhandleTapAction = PatternTapResponder { (tappedString) -> (Void) in
      println("Username Handle Tapped = " + tappedString)
    }
    self.customLabel.enableUserHandleDetection([NSForegroundColorAttributeName:UIColor.grayColor(),
                                     RLHighlightedForegroundColorAttributeName:UIColor.greenColor(),
                                     RLHighlightedBackgroundColorAttributeName:UIColor.blackColor(),
                                                   RLTapResponderAttributeName:userhandleTapAction])
    
    let urlTapAction  = PatternTapResponder { (tappedString) -> (Void) in
      println("URL Tapped = " + tappedString)
    }
    self.customLabel.enableURLDetection([NSForegroundColorAttributeName:UIColor.cyanColor(),
                                          NSUnderlineStyleAttributeName:0,
                                            RLTapResponderAttributeName:urlTapAction])
//    
   
    }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}


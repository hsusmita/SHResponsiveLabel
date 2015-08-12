//
//  ViewController.swift
//  SHResponsiveLabel
//
//  Created by hsusmita on 27/07/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

  @IBOutlet weak var customLabel: SHResponsiveLabel!
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var segmentControl: UISegmentedControl!
  override func viewDidLoad() {
    super.viewDidLoad()
    customLabel.text = "Hello #hashtag @username some more text www.google.com some more text some more textsome more text hsusmita4@gmail.com";
//    //Detects email in text
//    let emailRegexString = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//    var error = NSErrorPointer()
//    let regex = NSRegularExpression(pattern: emailRegexString, options: NSRegularExpressionOptions.allZeros, error: error)
//    let descriptor = PatternDescriptor(regularExpression: regex!, searchType: PatternSearchType.All, patternAttributes:[NSForegroundColorAttributeName:UIColor.redColor()])
//    customLabel.enablePatternDetection(descriptor)
//    
    //Detect the word "text" and "some"
//    let tapResponder = PatternTapResponder { (tappedString) -> (Void) in
//      println("tapped = "+tappedString)
//    }
//    self.customLabel.enableDetectionForStrings(["text","some"], dictionary: [NSForegroundColorAttributeName:UIColor.brownColor(),
//      RLTapResponderAttributeName:tapResponder])
//
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func enableHashTagButton(sender:UIButton) {
    sender.selected = !sender.selected
    if sender.selected {
      let hashTagTapAction = PatternTapResponder {(tappedString)-> (Void) in
        let messageString = "You have tapped hashTag:"+tappedString
        self.messageLabel.text = messageString
      }
      customLabel.enableHashTagDetection([NSForegroundColorAttributeName : UIColor.redColor(),
        RLHighlightedBackgroundColorAttributeName:UIColor.blackColor(),
        RLTapResponderAttributeName:hashTagTapAction]);
      
    }else {
      customLabel.disableHashTagDetection()
    }
  }
  
  
  @IBAction func enableUserhandleButton(sender:UIButton) {
    sender.selected = !sender.selected
    if sender.selected {
      let userHandleTapAction = PatternTapResponder{ (tappedString)-> (Void) in
      let messageString = "You have tapped user handle:"+tappedString
      self.messageLabel.text = messageString
      }
      self.customLabel.enableUserHandleDetection([NSForegroundColorAttributeName:UIColor.grayColor(),
        RLHighlightedForegroundColorAttributeName:UIColor.greenColor(),
        RLHighlightedBackgroundColorAttributeName:UIColor.blackColor(),
        RLTapResponderAttributeName:userHandleTapAction])
    }else {
      customLabel.disableUserHandleDetection()
    }
  }
  
  @IBAction func enableURLButton(sender:UIButton) {
    sender.selected = !sender.selected
    if sender.selected {
      let URLTapAction = PatternTapResponder{(tappedString)-> (Void) in
        let messageString = "You have tapped URL:" + tappedString
        self.messageLabel.text = messageString
      }
      self.customLabel.enableURLDetection([NSForegroundColorAttributeName:UIColor.blueColor(),RLTapResponderAttributeName:URLTapAction])
    }else{
      self.customLabel.disableURLDetection()
    }
  }
  
  
  @IBAction func handleSegmentChange(sender:UISegmentedControl) {
    switch(segmentControl.selectedSegmentIndex) {
    case 0:
      let token = NSAttributedString(string: "...More",
        attributes: [NSFontAttributeName:self.customLabel.font,
          NSForegroundColorAttributeName:UIColor.brownColor(),
          RLHighlightedBackgroundColorAttributeName:UIColor.blackColor(),
          RLHighlightedForegroundColorAttributeName:UIColor.greenColor()])
      let action = PatternTapResponder {(tappedString)-> (Void) in
        let messageString = "You have tapped token string"
        self.messageLabel.text = messageString}
      customLabel.setAttributedTruncationToken(token, action: action)
      
    case 1:
      let action = PatternTapResponder {(tappedString)-> (Void) in
        let messageString = "You have tapped token string"
        self.messageLabel.text = messageString}
      let imageToken = UIImage(named: "Add-Caption-Plus")
      customLabel.setTruncationIndicatorImage(imageToken!, size: CGSizeMake(20, 20), action: action)
      
    default:
      break
    }
  }
  
  @IBAction func enableTruncationUIButton(sender:UIButton) {
    println("current token = \(customLabel.attributedTruncationToken?.string)")
    sender.selected = !sender.selected;
    customLabel.customTruncationEnabled = sender.selected;
  }

}


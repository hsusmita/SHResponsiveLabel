//
//  UITouchGestureRecognizer.swift
//  SHResponsiveLabel
//
//  Created by hsusmita on 21/08/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

let gesture: UITouchGestureRecognizer = UITouchGestureRecognizer()

 class UITouchGestureRecognizer: UIGestureRecognizer {
  
  override func touchesBegan(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    state = .Began
  }
  
  override func touchesMoved(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    state = .Failed
  }
  
  override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    state = .Cancelled
  }
  
  override func touchesEnded(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    state = .Ended
  }
}

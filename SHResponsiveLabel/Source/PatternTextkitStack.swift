//
//  PatternTextkitStack.swift
//  SHResponsiveLabel
//
//  Created by hsusmita on 25/08/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

import UIKit

class PatternTextkitStack: TextkitStack {
  var patternDescriptorDictionary: [String:PatternDescriptor]
  var rangeAttributesDictionary:[NSValue:[String:AnyObject]]

  override init() {
    patternDescriptorDictionary =  Dictionary()
    rangeAttributesDictionary = Dictionary()
  }
  
  func enablePatternDetection(patternDescriptor:PatternDescriptor) {
    let patternKey = patternNameKeyForPatternDescriptor(patternDescriptor)
    patternDescriptorDictionary[patternKey] = patternDescriptor
    addPatternAttributes(patternDescriptor)
  }
  
  func enableDataDetector(type:NSTextCheckingType,dictionary:[String:AnyObject]) {
    var error:NSError?
    let regex = NSDataDetector(types: type.rawValue, error: &error)
    let descriptor = PatternDescriptor(regularExpression: regex!, searchType: PatternSearchType.All, patternAttributes: dictionary)
    enablePatternDetection(descriptor)
  }
  
  func disableDataDetector(type:NSTextCheckingType) {
    let key = String(type.rawValue)
    disablePatternDetection(patternDescriptorDictionary[key]!)
  }
  func enablePatternDetection(string:String,dictionary:[String:AnyObject]) {
    var error:NSError?
    let pattern = String(format: kRegexFormatForSearchWord,string)
    let regex = NSRegularExpression(pattern:pattern, options: NSRegularExpressionOptions.allZeros, error: &error)
    let descriptor = PatternDescriptor(regularExpression: regex!, searchType: PatternSearchType.All, patternAttributes: dictionary)
    patternDescriptorDictionary[string] = descriptor
    addPatternAttributes(descriptor)
  }
  
  func disablePatternDetection(patternDescriptor:PatternDescriptor) {
    let patternKey = patternNameKeyForPatternDescriptor(patternDescriptor)
    patternDescriptorDictionary.removeValueForKey(patternKey)
    removePatternAttributes(patternDescriptor)
  }
  
  func disablePatternDetection(pattern:String) {
    if patternDescriptorDictionary[pattern] != nil {
      disablePatternDetection(patternDescriptorDictionary[pattern]!)
    }
  }
  
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
  
  func addPatternAttributes(patternDescriptor:PatternDescriptor) {
    if textStorage.length > 0 {
      //Generate ranges for attributed text of the label
      let patternRanges = patternDescriptor.patternRangesForString(textStorage.string)
      for range in patternRanges { //Apply attributes to the ranges conditionally
        if (range.location + range.length < textStorage.length) {
          rangeAttributesDictionary[range] = patternDescriptor.patternAttributes
          textStorage.addAttributes(patternDescriptor.patternAttributes!, range: range)
        }
      }
    }
  }
  
  func removePatternAttributes(patternDescriptor:PatternDescriptor) {
    if textStorage.length > 0 {
      //Generate ranges for attributed text of the label
      let patternRanges = patternDescriptor.patternRangesForString(textStorage.string)
      for range in patternRanges { //Remove attributes from the ranges conditionally
        if (range.location + range.length < textStorage.length) {
          rangeAttributesDictionary.removeValueForKey(NSValue(range: range))
          if let attributes = patternDescriptor.patternAttributes {
            for (name,NSObject) in attributes {
              textStorage.removeAttribute(name, range: range)
            }
          }
        }
      }
    }
  }
}

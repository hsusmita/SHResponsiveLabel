###Features
1. It can detect pattern specified by regular expression and apply style like font, color etc.
2. It allows to replace default ellipse with tappable attributed string to mark truncation
3. Convenience methods are provided to detect hashtags, username handler and URLs

###Installation
Add following lines in your pod file  
pod 'SHResponsiveLabel', '~> 1.0.1'

###Usage
The following snippets explain the usage of public methods. These snippets assume an instance of ResponsiveLabel named "customLabel".
#### Pattern Detection
```
//Detects email in text
let emailRegexString = "A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
var error = NSErrorPointer()
let regex = NSRegularExpression(pattern: emailRegexString,
                                options: NSRegularExpressionOptions.allZeros, 
                                  error: error)
let descriptor = PatternDescriptor(regularExpression: regex!, 
                                          searchType: PatternSearchType.All,
                                   patternAttributes:[NSForegroundColorAttributeName:UIColor.redColor()])
customLabel.enablePatternDetection(descriptor)
```

#### String Detection
```
//Detect the word "text"
let tapResponder = PatternTapResponder { (tappedString) -> (Void) in
      println("tapped = "+tappedString)
}
let attributes = [NSForegroundColorAttributeName:UIColor.brownColor(),
                     RLTapResponderAttributeName:action as AnyObject]
self.customLabel.enableStringDetection("text", dictionary:attributes)
```
#### Array of String Detection
```
//Detect the word "text" and "some"
let tapResponder = PatternTapResponder { (tappedString) -> (Void) in
   println("tapped = "+tappedString)
}
let attributes = [NSForegroundColorAttributeName:UIColor.brownColor(),
                     RLTapResponderAttributeName:action as AnyObject]
self.customLabel.enableDetectionForStrings(["text","some"], dictionary: attributes)
```
#### HashTag Detection
```
let hashtagTapAction = PatternTapResponder { (tappedString) -> (Void) in
  println("Hashtag Tapped = "+tappedString)
 }
self.customLabel.enableHashTagDetection([NSForegroundColorAttributeName:UIColor.redColor(),
                                            RLTapResponderAttributeName:hashtagTapAction])
```   
#### Username Handle Detection
```
let userhandleTapAction = PatternTapResponder { (tappedString) -> (Void) in
  println("Username Handle Tapped = " + tappedString)
}
self.customLabel.enableUserHandleDetection([NSForegroundColorAttributeName:UIColor.grayColor(),
                                               RLTapResponderAttributeName:userhandleTapAction])
```
#### URL Detection
```
let urlTapAction  = PatternTapResponder { (tappedString) -> (Void) in
  println("URL Tapped = " + tappedString)
}
self.customLabel.enableURLDetection([NSForegroundColorAttributeName:UIColor.cyanColor(),
                                      NSUnderlineStyleAttributeName:0,
                                        RLTapResponderAttributeName:urlTapAction])
```
#### Highlight Patterns On Tap
To highlight patterns, one can set the attributes:
* RLHighlightedForegroundColorAttributeName
* RLHighlightedBackgroundColorAttributeName

```
let userhandleTapAction = PatternTapResponder { (tappedString) -> (Void) in
  println("Username Handle Tapped = " + tappedString)
}
self.customLabel.enableUserHandleDetection([NSForegroundColorAttributeName:UIColor.grayColor(), 
								 RLHighlightedForegroundColorAttributeName:UIColor.greenColor(),
                                 RLHighlightedBackgroundColorAttributeName:UIColor.blackColor(),
                                               RLTapResponderAttributeName:userhandleTapAction])
```
#### Custom Truncation Token
##### Set attributed string as truncation token
```
let token = NSAttributedString(string: "...More",
                            attributes: [NSFontAttributeName:self.customLabel.font,
                              NSForegroundColorAttributeName:UIColor.blueColor(),
                   RLHighlightedBackgroundColorAttributeName:UIColor.blackColor(),
                   RLHighlightedForegroundColorAttributeName:UIColor.greenColor()])
customLabel.setAttributedTruncationToken(token, action: action)
```
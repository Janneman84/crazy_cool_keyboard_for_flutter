    var methodChannel: FlutterMethodChannel?
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        
        if methodChannel == nil, let rootViewController = window?.rootViewController as? FlutterViewController {
            
            methodChannel = FlutterMethodChannel(name: "kbtestwidget", binaryMessenger: rootViewController as! FlutterBinaryMessenger)
            
            //this method basically sets the y position of the keyboard to what Flutter says it to
            methodChannel?.setMethodCallHandler {(call: FlutterMethodCall, result: FlutterResult) -> Void in
                if UIApplication.shared.windows.count > 2, let kbWindow = UIApplication.shared.windows.last {
                    DispatchQueue.main.async(execute: {
                        kbWindow.frame = CGRect.init(x: kbWindow.frame.minX, y: call.arguments as! CGFloat, width: kbWindow.frame.width, height: kbWindow.frame.height)
                    })
                }
                result(true)
            }
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }
        
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            
            let startFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            
            if let startFrame = startFrame, let endFrame = endFrame {
                //print(startFrame.size.height)
                //print(endFrame.size.height)
                
                if startFrame.origin.y == endFrame.origin.y
                {
                    return
                }
                
                if startFrame.origin.y > endFrame.origin.y //keyboard show
                {
                    //tell Flutter the keyboard is showing and its height
                    methodChannel?.invokeMethod("kbshow", arguments: endFrame.size.height)
                    
                    //this moves the keyboard frame down with the same animation curve as it is sliding up, effectively keeping it stationary just below the screen
                    if UIApplication.shared.windows.count > 2, let kbWindow = UIApplication.shared.windows.last {
                        UIView.animate(withDuration: duration,
                                       delay: TimeInterval(0.0),
                                       options: animationCurve,
                                       animations: {
                                        kbWindow.frame = CGRect.init(x: kbWindow.frame.minX, y: kbWindow.frame.minY + endFrame.size.height, width: kbWindow.frame.width, height: kbWindow.frame.height)
                        })
                    }
                    return;
                }
                else //keyboard hide
                {
                    //tell Flutter the keyboard is hiding and its height
                    methodChannel?.invokeMethod("kbhide", arguments: endFrame.size.height)
                    
                    //this moves the keyboard frame up with the same animation curve as it is sliding down, effectively keeping it stationary for about 0.4 seconds before it disappears
                    if UIApplication.shared.windows.count > 2, let kbWindow = UIApplication.shared.windows.last {
                        UIView.animate(withDuration: duration,
                                       delay: TimeInterval(0.0),
                                       options: animationCurve,
                                       animations: {
                                        kbWindow.subviews[0].subviews[0].frame = CGRect.init(x: kbWindow.subviews[0].subviews[0].frame.minX+0.0, y: kbWindow.subviews[0].subviews[0].frame.minY - startFrame.size.height, width: kbWindow.subviews[0].subviews[0].frame.width, height: kbWindow.subviews[0].subviews[0].frame.height)
                        })
                    }
                    return;
                }
            }
        }
    }
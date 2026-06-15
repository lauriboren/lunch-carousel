import UIKit

extension ViewController {
    func bringOutTheLobster() {
        
        lobsterView.removeFromSuperview()
        lobsterView.text = "🦞"
        lobsterView.font = UIFont.systemFont(ofSize: 100)
        lobsterView.isUserInteractionEnabled = false
        let textSize = lobsterView.font.getSize(for: lobsterView.text!)
        
        self.lobsterView.layer.position = CGPoint(x: 0, y: 0)
        self.lobsterView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        if selectedLunchType == .nice {
            lobsterView.frame = CGRect(
                x: 100,
                y: 100,
                width: textSize.width,
                height: textSize.height * 2
            )
            view.addSubview(lobsterView)
            
            
            // ----------------------------------------------------------------------
            // MOVE TO BASIC LUNCH
            
            let moveDuration = 1.0
            let moveAnimation = CAKeyframeAnimation(keyPath: "position")
            moveAnimation.duration = moveDuration
            moveAnimation.values = [
                CGPoint(x: 100, y: 100),
                CGPoint(x: 150, y: 180),
                CGPoint(x: self.basicLunchButton.center.x, y: self.basicLunchButton.center.x - 20)
            ].map { NSValue(cgPoint: $0) }
            moveAnimation.keyTimes = [0.0, 0.5, 1.0]
            self.lobsterView.layer.add(moveAnimation, forKey: nil)
            
            let rotateAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
            rotateAnimation.duration = moveDuration / 3
            rotateAnimation.repeatCount = 3
            rotateAnimation.values = [0.0, -.pi/4.0, 0.0, .pi/4.0, 0.0]
            rotateAnimation.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
            self.lobsterView.layer.add(rotateAnimation, forKey: nil)
            
            self.lobsterView.layer.position = CGPoint(x: self.basicLunchButton.center.x, y: self.basicLunchButton.center.x - 20)
            
            // ----------------------------------------------------------------------
            // TAP ON BASIC LUNCH
            DispatchQueue.main.asyncAfter(deadline: .now() + moveDuration + 0.2) {
                let tapDuration = 0.2
                let tapAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
                tapAnimation.duration = tapDuration
                tapAnimation.values = [1.0, 0.5, 1.0].map { NSNumber(value: $0) }
                tapAnimation.keyTimes = [0.0, 0.5, 1.0]
                self.lobsterView.layer.add(tapAnimation, forKey: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + tapDuration) {
                    self.setLunchType(.basic)
                    
                    // ----------------------------------------------------------------------
                    // MOVE TO CAROUSEL
                    DispatchQueue.main.asyncAfter(deadline: .now() + tapDuration + 0.5) {
                        self.setLunchType(.basic)
                        let moveDuration = 1.0
                        let moveAnimation = CAKeyframeAnimation(keyPath: "position")
                        moveAnimation.duration = moveDuration
                        moveAnimation.values = [
                            CGPoint(x: self.basicLunchButton.center.x, y: self.basicLunchButton.center.x - 20),
                            CGPoint(x: self.basicLunchButton.center.x - 100, y: self.basicLunchButton.center.x + 120),
                            CGPoint(x: self.basicLunchButton.center.x - 30, y: self.basicLunchButton.center.x + 220)
                        ].map { NSValue(cgPoint: $0) }
                        moveAnimation.keyTimes = [0.0, 0.5, 1.0]
                        self.lobsterView.layer.add(moveAnimation, forKey: nil)
                        
                        let rotateAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
                        rotateAnimation.duration = moveDuration / 3
                        rotateAnimation.repeatCount = 3
                        rotateAnimation.values = [0.0, -.pi/4.0, 0.0, .pi/4.0, 0.0]
                        rotateAnimation.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
                        self.lobsterView.layer.add(rotateAnimation, forKey: nil)
                        
                        self.lobsterView.layer.position = CGPoint(x: self.basicLunchButton.center.x - 30, y: self.basicLunchButton.center.x + 220)
                        
                        // ----------------------------------------------------------------------
                        // SPIN THE CAROUSEL
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            self.lobsterView.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
                            self.lobsterView.layer.position = CGPoint(x: self.lobsterView.layer.position.x, y: self.lobsterView.layer.position.y + self.lobsterView.layer.frame.height / 2)
                            let spinAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
                            spinAnimation.duration = 2.0
                            spinAnimation.repeatCount = 1
                            spinAnimation.values =   [0.0, .pi/4.0,  -.pi/4.0, -.pi/4.0, 0.0]
                            spinAnimation.keyTimes = [0.0,     0.10,     0.20,     0.50, 1.0]
                            spinAnimation.timingFunctions = [
                                CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear),
                                CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear),
                                CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear),
                                CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                            ]
                            self.lobsterView.layer.add(spinAnimation, forKey: nil)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                self.carouselView.spinTo(restaurant: "Burger & Lobster", duration: 3.0)
                                
                                // ----------------------------------------------------------------------
                                // CELEBRATE
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                    let tapDuration = 0.2
                                    let tapAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
                                    tapAnimation.duration = tapDuration
                                    tapAnimation.values = [1.0, 1.5, 1.0].map { NSNumber(value: $0) }
                                    tapAnimation.keyTimes = [0.0, 0.5, 1.0]
                                    self.lobsterView.layer.add(tapAnimation, forKey: nil)
                                }
                            }
                        }
                    }
                }
            }
            
        } else {
            lobsterView.frame = CGRect(
                x: 100,
                y: 100,
                width: textSize.width,
                height: textSize.height * 2
            )
            view.addSubview(lobsterView)
            // ----------------------------------------------------------------------
            // MOVE TO CAROUSEL
            let duration = 1.0
            let moveAnimation = CAKeyframeAnimation(keyPath: "position")
            moveAnimation.duration = duration
            moveAnimation.values = [
                CGPoint(x: self.view.frame.width, y: self.view.frame.height - 100),
                CGPoint(x: self.view.frame.width - 250.0, y: self.view.frame.height - 200),
                CGPoint(x: self.view.frame.width - 300.0, y: self.view.frame.height - 350)
            ].map { NSValue(cgPoint: $0) }

            moveAnimation.keyTimes = [0.0, 0.5, 1.0]
            self.lobsterView.layer.add(moveAnimation, forKey: nil)
            
            let rotateAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
            rotateAnimation.duration = duration / 3
            rotateAnimation.repeatCount = 3
            rotateAnimation.values = [0.0, -.pi/4.0, 0.0, .pi/4.0, 0.0]
            rotateAnimation.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
            self.lobsterView.layer.add(rotateAnimation, forKey: nil)
            self.lobsterView.layer.position = CGPoint(x: self.view.frame.width - 300.0, y: self.view.frame.height - 350)
            // ----------------------------------------------------------------------
            // SPIN THE CAROUSEL
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.lobsterView.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
                self.lobsterView.layer.position = CGPoint(x: self.lobsterView.layer.position.x, y: self.lobsterView.layer.position.y + self.lobsterView.layer.frame.height / 2)
                let spinAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
                spinAnimation.duration = 2.0
                spinAnimation.repeatCount = 1
                spinAnimation.values =   [0.0, .pi/4.0,  -.pi/4.0, -.pi/4.0, 0.0]
                spinAnimation.keyTimes = [0.0,     0.10,     0.20,     0.50, 1.0]
                spinAnimation.timingFunctions = [
                    CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear),
                    CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear),
                    CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear),
                    CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                ]
                self.lobsterView.layer.add(spinAnimation, forKey: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.carouselView.spinTo(restaurant: "Burger & Lobster", duration: 3.0)
                    
                    // ----------------------------------------------------------------------
                    // CELEBRATE
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                        let tapDuration = 0.2
                        let tapAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
                        tapAnimation.duration = tapDuration
                        tapAnimation.values = [1.0, 1.5, 1.0].map { NSNumber(value: $0) }
                        tapAnimation.keyTimes = [0.0, 0.5, 1.0]
                        self.lobsterView.layer.add(tapAnimation, forKey: nil)
                    }
                }
            }
        }
        
        
    }
}

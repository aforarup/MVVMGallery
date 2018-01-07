//
//  PopAnimationController.swift
//  photoGallery
//
//  Created by Arup Saha on 12/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit

final class PopAnimationController: NSObject {
    fileprivate let duration: Double = 0.4
    var presenting = true
    var origin = CGRect.zero
}

extension PopAnimationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from), let toView = transitionContext.view(forKey: .to) else {
            return
        }
        if presenting {
            toView.frame = fromView.frame
        }
        let targetView = presenting ? toView : fromView
        let initialFrame = presenting ? origin : targetView.frame
        let finalFrame = presenting ? targetView.frame : origin
        
        let scaleX = presenting ? (initialFrame.width/finalFrame.width) : (finalFrame.width/initialFrame.width)
        let scaleY = presenting ? (initialFrame.height/finalFrame.height) : (finalFrame.height/initialFrame.height)
        
        let scaleTransform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        
        if presenting {
            targetView.transform = scaleTransform
            targetView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
        }
        targetView.clipsToBounds = true
        
        transitionContext.containerView.addSubview(toView)
        transitionContext.containerView.bringSubview(toFront: targetView)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, animations: {
            targetView.transform = self.presenting ? CGAffineTransform.identity : scaleTransform
            targetView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
    }
}

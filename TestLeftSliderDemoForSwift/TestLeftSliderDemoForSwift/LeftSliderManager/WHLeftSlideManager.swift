//
//  WHLeftSlideManager.swift
//  TestLeftSliderDemoForSwift
//
//  Created by 邓伟浩 on 2020/6/1.
//  Copyright © 2020 邓伟浩. All rights reserved.
//

import UIKit

/// 手势轻扫临界速度
let LSLeftSlipCriticalVelocity: CGFloat = 800
/// 左滑手势触发距离
let LSLeftSlipLeftSlipPanTriggerWidth: CGFloat = 50

open class WHLeftSlideManager: UIPercentDrivenInteractiveTransition {
    
    weak var mainVC: UIViewController!
    weak var leftVC: UIViewController!
    
    /** 点击返回的遮罩view */
    lazy var tapView: UIView = {
        let tapView = UIView(frame: self.mainVC.view.bounds)
        tapView.backgroundColor = UIColor(white: 0, alpha: 0.4);
        tapView.alpha = 0
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(pan:)))
        tapView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        tapView.addGestureRecognizer(tapGesture)
        return tapView
    }()
    
    /** present or dismiss */
    var isPresent: Bool = false

    /** 是否已经显示左滑视图 */
    var isShowLeft: Bool = false

    /** 是否在交互中 */
    var interactive: Bool = false

    /** 主VC是否跟随滑动 */
    var shouldMove: Bool = false

    /** 左滑视图宽度 */
    var leftViewWidth: CGFloat = 0.0

    /** 侧滑手势 */
    lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(pan:)))
        panGesture.delegate = self
        return panGesture
    }()
    
    /** 左滑管理器实例 */
    public static let shared = WHLeftSlideManager()

    /**
     *    @brief    设置左滑控制器及主控制器
     *    @param    leftViewController  左侧菜单视图控制器
     *    @param    leftViewWidth  左侧菜单视图宽度
     *    @param    mainViewController  主控制器
     *    @param    shouldMove  主视图是否跟随移动
     */
    open func set(leftViewController: UIViewController, leftViewWidth: CGFloat = scaleFor(width: 310), mainViewController: UIViewController, shouldMove: Bool = true) {
        self.leftVC = leftViewController
        self.mainVC = mainViewController
        self.leftViewWidth = leftViewWidth
        self.shouldMove = shouldMove
        
        if (self.mainVC.navigationController == nil) {
            self.mainVC.view.addSubview(self.tapView)
        } else {
            self.mainVC.navigationController?.view.addSubview(self.tapView)
        }
        self.tapView.isHidden = true
        
        self.leftVC.transitioningDelegate = self
        // 侧滑手势
        self.mainVC.view.addGestureRecognizer(self.panGesture)
        
    }
    
    /** 显示菜单 */
    func show() {
        if !self.isShowLeft {
            self.leftVC.modalPresentationStyle = .fullScreen
            self.mainVC.present(self.leftVC, animated: true, completion: nil)
        } else {
            self.dismiss()
        }
    }

    /** 取消显示菜单 */
    @objc func dismiss() {
        self.leftVC.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- —————— 手势处理方法 ——————
    @objc func pan(pan: UIPanGestureRecognizer) {
        // X轴偏移
        let offsetX = pan.translation(in: pan.view).x
        // X轴速度
        let velocityX = pan.velocity(in: pan.view).x
        
        var percent: CGFloat = 0
        if (self.isShowLeft) {
            // 不能超过1
            percent = CGFloat.minimum(-offsetX / self.leftViewWidth, 1)
        } else {
            percent = CGFloat.minimum(offsetX / self.leftViewWidth, 1);
        }
        
        switch pan.state {
        case .began:
            self.interactive = true
            if self.isShowLeft {
                self.dismiss()
            } else {
                self.show()
            }
            break
        case .changed:
            self.update(percent)
            break
        case .ended, .cancelled:
            self.interactive = false
            
            // 判断是否需要转场
            var shouldTransition = false
            
            // 1.present时
            // 1.1 速度正方向，>800，则正向转场
            // 1.2 速度反向时，<-800，则反向转场
            // 1.3 速度正向<800 或者 速度反向>-800， 判断percent是否大于0.5
            if !self.isShowLeft {
                if (velocityX > 0) {
                    if (velocityX > LSLeftSlipCriticalVelocity) {
                        shouldTransition = true
                    } else {
                        shouldTransition = percent > 0.5
                    }
                } else {
                    if (velocityX < -LSLeftSlipCriticalVelocity) {
                        shouldTransition = false
                    } else {
                        shouldTransition = percent > 0.5
                    }
                }
            } else {
                if (velocityX < 0) {
                    if (velocityX < -LSLeftSlipCriticalVelocity) {
                        shouldTransition = true
                    } else {
                        shouldTransition = percent > 0.5
                    }
                } else {
                    if (velocityX > LSLeftSlipCriticalVelocity) {
                        shouldTransition = false
                    } else {
                        shouldTransition = percent > 0.5
                    }
                }
            }
            
            // 2.dismiss时
            // 2.1 速度正向，<-800，则正向转场
            // 2.2 速度反向，>800，则反向转场
            // 2.3 速度正向>-800 或者 速度反向<800，判断percent是否大于0.5
            if (shouldTransition) {
                self.finish()
            } else {
                self.cancel()
            }
            break
        default:
            break
        }
    }
    
    //MARK:- —————— UIGestureRecognizerDelegate ——————
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.isShowLeft {
            return true
        }
        
        guard let panGesture: UIPanGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        
        // 忽略起始点不在左侧触发范围内的手势
        let touchBeganX = panGesture.location(in: panGesture.view).x
        if (touchBeganX > LSLeftSlipLeftSlipPanTriggerWidth) {
            return false
        }
        
        // 忽略反向手势
        let translation = panGesture.translation(in: panGesture.view)
        if (translation.x <= 0) {
            return false
        }
        
        return true
    }
    
    

}

public func scaleFor(width: CGFloat) -> CGFloat {
    return ((width)*(UIScreen.main.bounds.size.width/375))
}

extension WHLeftSlideManager: UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate, UIViewControllerAnimatedTransitioning {
    
    //MARK:- —————— UIViewControllerTransitioningDelegate ——————
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresent = true
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresent = false
        return self
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactive ? self : nil
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactive ? self : nil
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if self.isPresent {
            
            var toView: UIView? = nil
            var fromView: UIView? = nil
            
            if let from = transitionContext.view(forKey: .from), let to = transitionContext.view(forKey: .to) {
                fromView = from
                toView = to
            } else if let toVC = transitionContext.viewController(forKey: .to), let fromVC = transitionContext.viewController(forKey: .from) {
                fromView = fromVC.view
                toView = toVC.view
            }
            
            if let fromView = fromView, let toView = toView {
                let containerView = transitionContext.containerView
                containerView.addSubview(toView)
                toView.frame = CGRect(x: -self.leftViewWidth, y: 0, width: self.leftViewWidth, height: containerView.frame.size.height)
                
                self.tapView.superview?.bringSubviewToFront(self.tapView)
                self.tapView.isHidden = false
                
                // 动画block
                let animateBlock = {
                    toView.frame = CGRect(x: 0, y: 0, width: self.leftViewWidth, height: toView.frame.size.height)
                    if (self.shouldMove) {
                        fromView.frame = CGRect(x: self.leftViewWidth, y: 0, width: fromView.frame.size.width, height: fromView.frame.size.height)
                    }
                    self.tapView.alpha = 1.0
                }
                
                // 动画完成block
                let completeBlock = {
                    if transitionContext.transitionWasCancelled {
                        transitionContext.completeTransition(false)
                    } else {
                        transitionContext.completeTransition(true)
                        containerView.addSubview(fromView)
                        containerView.sendSubviewToBack(fromView)
                        self.isShowLeft = true
                    }
                }
                
                if self.interactive {
                    UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .curveLinear, animations: {
                        animateBlock()
                    }) { (finished) in
                        completeBlock()
                    }
                } else {
                    UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                        animateBlock()
                    }) { (finished) in
                        completeBlock()
                    }
                }
            }
        } else {
            var toView: UIView? = nil
            var fromView: UIView? = nil
            
            if let from = transitionContext.view(forKey: .from), let to = transitionContext.view(forKey: .to) {
                fromView = from
                toView = to
            } else if let toVC = transitionContext.viewController(forKey: .to), let fromVC = transitionContext.viewController(forKey: .from) {
                fromView = fromVC.view
                toView = toVC.view
            }
            
            if let fromView = fromView, let toView = toView {
                let containerView = transitionContext.containerView
                containerView.addSubview(toView)
                containerView.sendSubviewToBack(toView)
                
                // 动画block
                let animateBlock = {
                    fromView.frame = CGRect(x: -self.leftViewWidth, y: 0, width: self.leftViewWidth, height: fromView.frame.size.height)
                    if (self.shouldMove) {
                        toView.frame = CGRect(x: 0, y: 0, width: toView.frame.size.width, height: toView.frame.size.height)
                    }
                    self.tapView.alpha = 1.0
                }
                
                // 动画完成block
                let completeBlock = {
                    if transitionContext.transitionWasCancelled {
                        transitionContext.completeTransition(false)
                    } else {
                        transitionContext.completeTransition(true)
                        self.isShowLeft = false
                        self.tapView.isHidden = true
                    }
                }
                
                if self.interactive {
                    // 呵呵🙃
                    UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .curveLinear, animations: {
                        animateBlock()
                    }) { (finished) in
                        completeBlock()
                    }
                } else {
                    UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                        animateBlock()
                    }) { (finished) in
                        completeBlock()
                    }
                }
            }
        }
    }
    
    
}

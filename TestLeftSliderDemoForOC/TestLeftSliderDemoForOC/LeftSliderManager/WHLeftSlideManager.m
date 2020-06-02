//
//  WHLeftSlideManager.m
//  TestLeftSliderDemoForOC
//
//  Created by 邓伟浩 on 2020/6/1.
//  Copyright © 2020 邓伟浩. All rights reserved.
//

#import "WHLeftSlideManager.h"

/// 手势轻扫临界速度
CGFloat const LSLeftSlipCriticalVelocity = 800;
/// 左滑手势触发距离
CGFloat const LSLeftSlipLeftSlipPanTriggerWidth = 50;

@interface WHLeftSlideManager ()<UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate, UIViewControllerAnimatedTransitioning>

@property (nonatomic, weak) UIViewController *leftVC;
//@property (nonatomic, weak) UIViewController *mainVC;

/** 点击返回的遮罩view */
@property (nonatomic, strong) UIView *tapView;

/** present or dismiss */
@property (nonatomic, assign) BOOL isPresent;

/** 是否已经显示左滑视图 */
@property (nonatomic, assign) BOOL isShowLeft;

/** 是否在交互中 */
@property (nonatomic, assign) BOOL interactive;

/** 主VC是否跟随滑动 */
@property (nonatomic, assign) BOOL shouldMove;

/** 左滑视图宽度 */
@property (nonatomic, assign) CGFloat leftViewWidth;

/** 侧滑手势 */
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;


@end

@implementation WHLeftSlideManager

+ (instancetype)sharedManager {
    static WHLeftSlideManager *sharedWHLeftSlideManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedWHLeftSlideManager = [[self alloc] init];
    });
    return sharedWHLeftSlideManager;
}

#pragma mark - ———— 公共方法 ————

- (CGFloat)scaleFor:(CGFloat)width {
    return ((width)*(([[UIScreen mainScreen] bounds].size.width)/375.0f));
}

- (void)setLeftViewController:(UIViewController *)leftViewController mainViewController:(UIViewController *)mainViewController {
    [self setLeftViewController:leftViewController leftViewWidth:[self scaleFor:310] mainViewController:mainViewController shouldMove:YES];
}

- (void)setLeftViewController:(UIViewController *)leftViewController leftViewWidth:(CGFloat)leftViewWidth mainViewController:(UIViewController *)mainViewController shouldMove:(BOOL)shouldMove {
    self.leftVC = leftViewController;
    self.mainVC = mainViewController;
    self.leftViewWidth = leftViewWidth;
    self.shouldMove = shouldMove;
    
    if (self.mainVC.navigationController == nil) {
        [self.mainVC.view addSubview:self.tapView];
    } else {
        [self.mainVC.navigationController.view addSubview:self.tapView];
    }
    self.tapView.hidden = YES;
    
    self.leftVC.transitioningDelegate = self;
    // 侧滑手势
    [self.mainVC.view addGestureRecognizer:self.panGesture];
}

/** 显示菜单 */
- (void)showLeftMenuView {
    if (!self.isShowLeft) {
        self.leftVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.mainVC presentViewController:self.leftVC animated:YES completion:nil];
    } else {
        [self dismissLeftMenuView];
    }
    
}

/** 取消显示菜单 */
- (void)dismissLeftMenuView {
    //    dispatch_async(dispatch_get_main_queue(), ^{
    [self.leftVC dismissViewControllerAnimated:YES completion:nil];
    //    });
}

#pragma mark - ———— 手势处理方法 ————
- (void)pan:(UIPanGestureRecognizer *)pan {
    // X轴偏移
    CGFloat offsetX = [pan translationInView:pan.view].x;
    // X轴速度
    CGFloat velocityX = [pan velocityInView:pan.view].x;
    
    CGFloat percent;
    if (self.isShowLeft) {
        // 坑点。千万不要超过1
        percent = MIN(-offsetX / self.leftViewWidth, 1);
    } else {
        percent = MIN(offsetX / self.leftViewWidth, 1);
    }
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.interactive = YES;
            if (self.isShowLeft) {
                [self dismissLeftMenuView];
            } else {
                [self showLeftMenuView];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self updateInteractiveTransition:percent];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            self.interactive = NO;
            
            // 判断是否需要转场
            BOOL shouldTransition = NO;
            
            // 1.present时
            // 1.1 速度正方向，>800，则正向转场
            // 1.2 速度反向时，<-800，则反向转场
            // 1.3 速度正向<800 或者 速度反向>-800， 判断percent是否大于0.5
            if (!self.isShowLeft) {
                if (velocityX > 0) {
                    if (velocityX > LSLeftSlipCriticalVelocity) {
                        shouldTransition = YES;
                    } else {
                        shouldTransition = percent > 0.5;
                    }
                } else {
                    if (velocityX < -LSLeftSlipCriticalVelocity) {
                        shouldTransition = NO;
                    } else {
                        shouldTransition = percent > 0.5;
                    }
                }
            } else {
                if (velocityX < 0) {
                    if (velocityX < -LSLeftSlipCriticalVelocity) {
                        shouldTransition = YES;
                    } else {
                        shouldTransition = percent > 0.5;
                    }
                } else {
                    if (velocityX > LSLeftSlipCriticalVelocity) {
                        shouldTransition = NO;
                    } else {
                        shouldTransition = percent > 0.5;
                    }
                }
            }
            
            // 2.dismiss时
            // 2.1 速度正向，<-800，则正向转场
            // 2.2 速度反向，>800，则反向转场
            // 2.3 速度正向>-800 或者 速度反向<800，判断percent是否大于0.5
            if (shouldTransition) {
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate Methods
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.isShowLeft) {
        return YES;
    }
    
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gestureRecognizer;
    
    // 忽略起始点不在左侧触发范围内的手势
    CGFloat touchBeganX = [panGesture locationInView:panGesture.view].x;
    if (touchBeganX > LSLeftSlipLeftSlipPanTriggerWidth) {
        return NO;
    }
    
    // 忽略反向手势
    CGPoint translation = [panGesture translationInView:panGesture.view];
    if (translation.x <= 0) {
        return NO;
    }
    
    return YES;
}

#pragma mark - ———— UIViewControllerTransitioningDelegate代理方法 ————
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.isPresent = YES;
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.isPresent = NO;
    return self;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.interactive ? self : nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.interactive ? self : nil;
}

#pragma mark - ———— UIViewControllerAnimatedTransitioning代理方法 ————
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return .3f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.isPresent) {
        UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        UIView *toView = nil;
        UIView *fromView = nil;
        
        if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
            fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
            toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        } else {
            fromView = fromVC.view;
            toView = toVC.view;
        }
        
        UIView *containerView = [transitionContext containerView];
        [containerView addSubview:toView];
        
        toView.frame = CGRectMake(-self.leftViewWidth, 0, self.leftViewWidth, containerView.frame.size.height);
        
        [self.tapView.superview bringSubviewToFront:self.tapView];
        self.tapView.hidden = NO;
        
        // 动画block
        void(^animateBlock)(void) = ^{
            toView.frame = CGRectMake(0, 0, self.leftViewWidth, toView.frame.size.height);
            if (self.shouldMove) {
                fromView.frame = CGRectMake(self.leftViewWidth, 0, fromView.frame.size.width, fromView.frame.size.height);
            }
            self.tapView.alpha = 1.f;
        };
        
        // 动画完成block
        void(^completeBlock)(void) = ^{
            if ([transitionContext transitionWasCancelled]) {
                [transitionContext completeTransition:NO];
            } else {
                [transitionContext completeTransition:YES];
                [containerView addSubview:fromView];
                [containerView sendSubviewToBack:fromView];
                self.isShowLeft = YES;
            }
        };
        
        if (self.interactive) {
            // 呵呵🙃
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                animateBlock();
            } completion:^(BOOL finished) {
                completeBlock();
            }];
        } else {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                animateBlock();
            } completion:^(BOOL finished) {
                completeBlock();
            }];
        }
    } else {
        UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        UIView *toView = nil;
        UIView *fromView = nil;
        
        if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
            fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
            toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        } else {
            fromView = fromVC.view;
            toView = toVC.view;
        }
        
        UIView *containerView = [transitionContext containerView];
        [containerView addSubview:toView];
        [containerView sendSubviewToBack:toView];
        
        // 动画block
        void(^animateBlock)(void) = ^{
            fromView.frame = CGRectMake(-self.leftViewWidth, 0, self.leftViewWidth, fromView.frame.size.height);
            if (self.shouldMove) {
                toView.frame = CGRectMake(0, 0, toView.frame.size.width, toView.frame.size.height);
            }
            self.tapView.alpha = 0.f;
            
        };
        
        // 动画完成block
        void(^completeBlock)(void) = ^{
            if ([transitionContext transitionWasCancelled]) {
                [transitionContext completeTransition:NO];
            } else {
                [transitionContext completeTransition:YES];
                self.isShowLeft = NO;
                self.tapView.hidden = YES;
            }
        };
        
        if (self.interactive) {
            // 呵呵🙃
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                animateBlock();
            } completion:^(BOOL finished) {
                completeBlock();
            }];
        } else {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                animateBlock();
            } completion:^(BOOL finished) {
                completeBlock();
            }];
        }
    }
    
    
    
}

#pragma mark - setter/getter方法
- (UIView *)tapView {
    if (!_tapView) {
        _tapView = [[UIView alloc] initWithFrame:self.mainVC.view.bounds];
        _tapView.backgroundColor = [UIColor colorWithWhite:0 alpha:.4f];
        _tapView.alpha = 0.f;
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [_tapView addGestureRecognizer:panGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissLeftMenuView)];
        [_tapView addGestureRecognizer:tapGesture];
    }
    return _tapView;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

@end

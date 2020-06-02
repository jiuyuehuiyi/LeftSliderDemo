//
//  WHLeftSlideManager.h
//  TestLeftSliderDemoForOC
//
//  Created by 邓伟浩 on 2020/6/1.
//  Copyright © 2020 邓伟浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHLeftSlideManager : UIPercentDrivenInteractiveTransition

@property (nonatomic, weak) UIViewController *mainVC;

/** 左滑管理器实例 */
+ (instancetype)sharedManager;

/**
 *    @brief    设置左滑控制器及主控制器
 *    @param    leftViewController  左侧菜单视图控制器
 *    @param    mainViewController  主控制器
 */
- (void)setLeftViewController:(UIViewController *)leftViewController mainViewController:(UIViewController *)mainViewController;

- (void)setLeftViewController:(UIViewController *)leftViewController leftViewWidth:(CGFloat)leftViewWidth mainViewController:(UIViewController *)mainViewController shouldMove:(BOOL)shouldMove;

/** 显示菜单 */
- (void)showLeftMenuView;

/** 取消显示菜单 */
- (void)dismissLeftMenuView;

@end

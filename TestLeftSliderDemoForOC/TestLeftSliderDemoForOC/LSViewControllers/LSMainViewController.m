//
//  LSMainViewController.m
//  TestLeftSliderDemoForOC
//
//  Created by 邓伟浩 on 2020/6/1.
//  Copyright © 2020 邓伟浩. All rights reserved.
//

#import "LSMainViewController.h"
#import "LSLeftMenuViewController.h"

@implementation LSBaseVC

- (void)dealloc {
    NSLog(@"===== 释放 %@ =====", [self class]);
}

@end

@interface LSMainViewController ()

@property (nonatomic, strong) LSLeftMenuViewController *leftVC;

@end

@implementation LSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    LSLeftMenuViewController *leftMenuVC = [board instantiateViewControllerWithIdentifier:@"LeftMenuVC"];
    _leftVC = leftMenuVC;
    _leftVC.manager = [WHLeftSlideManager sharedManager];
    [[WHLeftSlideManager sharedManager] setLeftViewController:_leftVC mainViewController:self];
}

- (IBAction)showLeftMenuView:(id)sender {
    [[WHLeftSlideManager sharedManager] showLeftMenuView];
}

- (IBAction)exchange:(id)sender {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *anotherVC = [board instantiateViewControllerWithIdentifier:@"AnotherVC"];
    [[[UIApplication sharedApplication] delegate] window].rootViewController = anotherVC;
}

@end


@implementation LSAnotherViewController

- (IBAction)exchange:(id)sender {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *rootVC = [board instantiateViewControllerWithIdentifier:@"rootVC"];
    [[[UIApplication sharedApplication] delegate] window].rootViewController = rootVC;
}


@end

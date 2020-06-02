//
//  LSLeftMenuViewController.m
//  TestLeftSliderDemoForOC
//
//  Created by 邓伟浩 on 2020/6/1.
//  Copyright © 2020 邓伟浩. All rights reserved.
//

#import "LSLeftMenuViewController.h"

@interface LSLeftMenuViewController ()

@end

@implementation LSLeftMenuViewController

- (IBAction)pushToSecondVC:(id)sender {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *secondVC = [board instantiateViewControllerWithIdentifier:@"SecondVC"];
    
    [_manager dismissLeftMenuView];
    [_manager.mainVC.navigationController pushViewController:secondVC animated:YES];
}

@end

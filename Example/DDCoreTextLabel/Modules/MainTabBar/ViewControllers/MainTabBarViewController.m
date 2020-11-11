//
//  MainTabBarViewController.m
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/18.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "DDFriendCircleViewController.h"
#import "DDTest1ViewController.h"
#import "YYFPSLabel.h"

@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self __configSubVC];
    
    [self _configUI];
    
}

- (void)__configSubVC
{
    DDTest1ViewController * vc1 = [[DDTest1ViewController alloc] init];
    UINavigationController * nav1 = [[UINavigationController alloc] initWithRootViewController:vc1];
    nav1.tabBarItem = [self _createTabBarItem:@"测试"];
    
    DDFriendCircleViewController * vc2 = [[DDFriendCircleViewController alloc] init];
    UINavigationController * nav2 = [[UINavigationController alloc] initWithRootViewController:vc2];
    nav2.tabBarItem = [self _createTabBarItem:@"朋友圈"];
    
    self.viewControllers = @[nav1,nav2];
    
}

- (void)_configUI
{
    /// 添加 FPS
    YYFPSLabel * fpsLabel = [YYFPSLabel new];
    [fpsLabel sizeToFit];

    CGRect fpsFrame = fpsLabel.frame;
    fpsFrame.origin.x = CGRectGetWidth(self.view.bounds) - CGRectGetWidth(fpsLabel.bounds) - 20;
    
    fpsFrame.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    fpsLabel.frame = fpsFrame;
    
    [self.view addSubview:fpsLabel];
}

/** 返回 TabBarItem */
- (UITabBarItem *)_createTabBarItem:(NSString *)title
{
    UITabBarItem * item = [[UITabBarItem alloc] initWithTitle:title image:nil selectedImage:nil];
    return item;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

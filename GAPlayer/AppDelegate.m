//
//  AppDelegate.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/13.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "AppDelegate.h"
#import "GAHomeListViewController.h"
#import "GACacheManager.h"

@interface AppDelegate () <UIAlertViewDelegate>


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]init];
    self.window.frame = [UIScreen mainScreen].bounds;
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[GAHomeListViewController alloc] init]];
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    [self download];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)download {
    __weak __typeof__(self) weakSelf = self;
    [[GACacheManager sharedInstance] queryingTheDatabaseUnfinishedDownloadTaskCallBlock:^(BOOL success) {
        if (success) {
            [weakSelf showAlert];
        }
    }];
}

- (void)showAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您有未未完成的任务，是否继续下载" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"下载", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[GACacheManager sharedInstance] allSuspended];
    } else {
        [[GACacheManager sharedInstance] allStart];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end

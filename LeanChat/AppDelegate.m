//
//  AppDelegate.m
//  LeanChat
//
//  Created by gao on 15/11/17.
//  Copyright © 2015年 gao. All rights reserved.
//

#import "AppDelegate.h"
#import <NIMSDK.h>
#import "RootViewController.h"
#import "LoginViewController.h"

@interface AppDelegate () <NIMLoginManagerDelegate,NIMChatManagerDelegate>

@end

@implementation AppDelegate

- (void)onLogin:(NIMLoginStep)step
{
    
}

// 自动登录失败调用
- (void)onAutoLoginFailed:(NSError *)error
{
    NSLog(@"%@",[error localizedDescription]);
}

// 监听收到的消息
- (void)onRecvMessages:(NSArray *)messages
{
    [UIApplication sharedApplication].applicationIconBadgeNumber += messages.count;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // 注册云信
    [[NIMSDK sharedSDK] registerWithAppID:@"bdf4710be2ae1da40a56cf50aa5acea9"
                                  cerName:nil];
    // 设置chatManager代理(用来监听未读消息)
    [[[NIMSDK sharedSDK] chatManager] addDelegate:self];
    
    // 8.0以后需要手动注册推送通知
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 8.0) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // 自动登录
    [[[NIMSDK sharedSDK] loginManager] autoLogin:[USER_DEFAULTS objectForKey:@"userName"]
                                           token:[USER_DEFAULTS objectForKey:@"password"]];
    
    // 第一次打开程序进入登录页面 否则进入主页面
    if (![USER_DEFAULTS integerForKey:@"login"]) {
        self.window.rootViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    } else {
        self.window.rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // 程序活跃状态不显示未读消息
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // 即将进入前台将未读消息置0
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

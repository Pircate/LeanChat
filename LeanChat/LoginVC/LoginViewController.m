//
//  LoginViewController.m
//  LeanChat
//
//  Created by gao on 15/11/17.
//  Copyright © 2015年 gao. All rights reserved.
//

#import "LoginViewController.h"
#import "RootViewController.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)login:(UIButton *)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)login
{
    [[[NIMSDK sharedSDK] loginManager] login:self.userNameTextField.text
                                       token:self.passwordTextField.text
                                  completion:^(NSError *error) {
                                      if (!error) {
                                          // 获取登录账户的用户帐号
                                          NSString *userID = [NIMSDK sharedSDK].loginManager.currentAccount;
                                          // 保存用户帐号 用户名 和用户密码用来自动登录
                                          [USER_DEFAULTS setObject:userID forKey:@"userID"];
                                          [USER_DEFAULTS setObject:self.userNameTextField.text forKey:@"userName"];
                                          [USER_DEFAULTS setObject:self.passwordTextField.text forKey:@"password"];
                                          // 设置登录状态为1
                                          [USER_DEFAULTS setInteger:1 forKey:@"login"];
                                          [USER_DEFAULTS synchronize];

                                          RootViewController *rootVC = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
                                          [self presentViewController:rootVC animated:YES completion:nil];
                                      } else {
                                          UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"登录错误" message:@"请重新输入帐号信息" preferredStyle:UIAlertControllerStyleAlert];
                                          [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                                          [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
                                          [self presentViewController:alert animated:YES completion:nil];
                                      }
                                      
                                  }];
}

// 登录按钮点击事件
- (IBAction)login:(UIButton *)sender {
    [self login];
}

@end

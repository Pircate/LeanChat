//
//  MyViewController.m
//  LeanChat
//
//  Created by gao on 15/11/17.
//  Copyright © 2015年 gao. All rights reserved.
//

#import "MyViewController.h"
#import "LoginViewController.h"

@interface MyViewController () <UITableViewDataSource,UITableViewDelegate,NIMUserManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MyViewController
{
    NSArray *_titles;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:@"MyViewController" bundle:nil]) {
        _titles = @[@[@""],@[@"消息提醒"],@[@"免打扰"],@[@"清空所有聊天记录",@"设置"]];
        [[[NIMSDK sharedSDK] userManager] addDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[[NIMSDK sharedSDK] userManager] removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.sc_navigationItem.title = @"动态";
    [[Help shareHelp] initTableView:self.tableView target:self];

    [self createLogoutButton];
}

- (void)createLogoutButton
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    self.tableView.tableFooterView = view;
    UIButton *logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 40)];
    logoutBtn.backgroundColor = [UIColor colorWithRed:0.9412 green:0.2980 blue:0.3843 alpha:1];
    logoutBtn.layer.cornerRadius = 8;
    logoutBtn.layer.masksToBounds = YES;
    [logoutBtn setTitle:@"注销" forState:UIControlStateNormal];
    [view addSubview:logoutBtn];
    [logoutBtn addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - UITableViewDataSource方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _titles.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_titles[section] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NIMUser *user = [[[NIMSDK sharedSDK] userManager] userInfo:[USER_DEFAULTS objectForKey:@"userName"]];
    if (indexPath.section == 0) {
        UIImage *image = [[ImageTool shareTool] resizeImageToSize:CGSizeMake(40, 40) sizeOfImage:[UIImage imageNamed:@"fbe"]];
        cell.imageView.image = image;
        cell.textLabel.text = user.userInfo.nickName;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"帐号: %@",user.userId];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.textLabel.text = _titles[indexPath.section][indexPath.row];
        if (indexPath.section == 2) {
            UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 8, 0, 0)];
            [cell.contentView addSubview:sw];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 60;
    } else {
        return 44;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return @"在iPhone的“设置-通知中心”功能，找到应用程序“LeanChat”，可以更改程序新消息提醒设置";
    } else {
        return nil;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)logout:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"退出当前帐号" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error) {
            [USER_DEFAULTS setObject:nil forKey:@"userName"];
            [USER_DEFAULTS setObject:nil forKey:@"password"];
            [USER_DEFAULTS setInteger:0 forKey:@"login"];
            [USER_DEFAULTS synchronize];
            LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            [self presentViewController:loginVC animated:YES completion:nil];
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
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

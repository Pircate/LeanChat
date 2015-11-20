//
//  TeamViewController.m
//  LeanChat
//
//  Created by gao on 15/11/19.
//  Copyright © 2015年 gao. All rights reserved.
//

#import "TeamViewController.h"

@interface TeamViewController () <UITableViewDataSource,UITableViewDelegate,NIMTeamManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *teamTableView;

@end

@implementation TeamViewController
{
    NSMutableArray *_teamArray;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:@"TeamViewController" bundle:nil]) {
        _teamArray = [NSMutableArray array];
        [[[NIMSDK sharedSDK] teamManager] addDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[[NIMSDK sharedSDK] teamManager] removeDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController.tabBar setHidden:YES];
    
    NSArray *teams = [[[NIMSDK sharedSDK] teamManager] allMyTeams];
    [_teamArray addObjectsFromArray:teams];
    [self.teamTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.rdv_tabBarController.tabBar setHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - 初始化群组列表
- (void)initTeamTableView
{
    [[Help shareHelp] initTableView:self.teamTableView target:self];
}

#pragma mark - 数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _teamArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

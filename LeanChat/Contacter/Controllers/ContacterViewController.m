//
//  ContacterViewController.m
//  LeanChat
//
//  Created by gao on 15/11/17.
//  Copyright © 2015年 gao. All rights reserved.
//

#import "ContacterViewController.h"
#import "AddFriendViewController.h"
#import "ContacterCell.h"
#import "ChatViewController.h"
#import "TableHeaderView.h"
#import "TeamViewController.h"

@interface ContacterViewController () <UITableViewDataSource,UITableViewDelegate,NIMUserManagerDelegate,NIMTeamManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contacterTableView;
@end

@implementation ContacterViewController
{
    NSMutableArray *_contacterDataArray;
    NSArray *_users;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:@"ContacterViewController" bundle:nil]) {
        _contacterDataArray = [NSMutableArray array];
        self.automaticallyAdjustsScrollViewInsets = NO;
        _users = [NSArray array];
        [[[NIMSDK sharedSDK] userManager] addDelegate:self];
        [[[NIMSDK sharedSDK] teamManager] addDelegate:self];
    }
    return self;
}
- (void)dealloc
{
    [[[NIMSDK sharedSDK] userManager] removeDelegate:self];
    [[[NIMSDK sharedSDK] teamManager] removeDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 获取联系人列表
    _contacterDataArray = [NSMutableArray array];
    NSArray *friends = [[[NIMSDK sharedSDK] userManager] myFriends];
    [_contacterDataArray addObjectsFromArray:friends];
    [self.contacterTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.sc_navigationItem.title = @"联系人";
    [self initNavigationItem];
    
    [self initContacterTableView];
   
}

#pragma mark - 初始化联系人列表
- (void)initContacterTableView
{
    [[Help shareHelp] initTableView:self.contacterTableView target:self];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, (SCREEN_WIDTH - 75) / 4)];
    float width = (SCREEN_WIDTH - 15 * 5) / 4.0;
    NSArray *titles = @[@"验证消息",@"群组",@"讨论组",@"黑名单"];
    NSArray *images = @[@"qq_contact_list_discussion_entry_icon",@"qq_contact_list_troop_entry_icon",@"qb_group_menu_create_discussion",@"frv"];
    for (int i = 0; i < 4; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15 + (width + 15) * i, 0, width, width)];
        button.tag = 10 + i;
        UIImage *image = [[ImageTool shareTool] resizeImageToSize:CGSizeMake(40, 40) sizeOfImage:[UIImage imageNamed:images[i]]];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setImage:image forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 20, 0)];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(50, -50, 5, 0)];
        [headerView addSubview:button];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.contacterTableView.tableHeaderView = headerView;
}

- (void)buttonClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 10:
        {
            NSLog(@"10");
        }
            break;
        case 11:
        {
            TeamViewController *teamVC = [[TeamViewController alloc] initWithNibName:@"TeamViewController" bundle:nil];
            [self.navigationController pushViewController:teamVC animated:YES];
        }
            break;
        case 12:
        {
            TeamViewController *teamVC = [[TeamViewController alloc] initWithNibName:@"TeamViewController" bundle:nil];
            [self.navigationController pushViewController:teamVC animated:YES];
        }
            break;
        case 13:
        {
            NSLog(@"13");
        }
            break;
        default:
            break;
    }
}

#pragma mark - 初始化导航栏控件
- (void)initNavigationItem
{
    // 添加加好友按钮
    UIImage *image = [[ImageTool shareTool] resizeImageToSize:CGSizeMake(30, 30) sizeOfImage:[UIImage imageNamed:@"erk.png"]];
    SCBarButtonItem *addFriendBtn = [[SCBarButtonItem alloc] initWithImage:image style:SCBarButtonItemStylePlain handler:^(id sender) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择操作" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"添加好友" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            AddFriendViewController *addFriendVC = [[AddFriendViewController alloc] initWithNibName:@"AddFriendViewController" bundle:nil];
            void(^refreshFriend)(void) = ^{
                [self.contacterTableView reloadData];
            };
            addFriendVC.block = refreshFriend;
            [self.navigationController pushViewController:addFriendVC animated:YES];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"创建高级群" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"创建普通群" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            _users = [[[NIMSDK sharedSDK] userManager] myFriends];
            
            NIMCreateTeamOption *teamOption = [[NIMCreateTeamOption alloc] init];
            teamOption.type = NIMTeamTypeNormal;
            teamOption.name = @"GX的个人群";
            teamOption.intro = @"IM测试专用";
            teamOption.announcement = @"群主很懒,什么都没写";
            teamOption.clientCustomInfo = @"无";
            
            [[[NIMSDK sharedSDK] teamManager] createTeam:teamOption users:_users completion:^(NSError *error, NSString *teamId) {
                if (error) {
                    NSLog(@"%@",error.localizedDescription);
                }
            }];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"搜索高级群" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    self.sc_navigationItem.rightBarButtonItem = addFriendBtn;
}

// 建群成功回调
- (void)onTeamAdded:(NIMTeam *)team
{
    NSLog(@"群主: %@",team.owner);
}

#pragma mark - 数据源方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contacterDataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NIMUser *user = _contacterDataArray[indexPath.row];
    ContacterCell *contacterCell = [tableView dequeueReusableCellWithIdentifier:@"ContacterCell"];
    if (!contacterCell) {
        contacterCell = [[[NSBundle mainBundle] loadNibNamed:@"ContacterCell" owner:self options:nil] lastObject];
    }
    contacterCell.textLabel.text = user.userInfo.nickName;
    return contacterCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NIMUser *user = _contacterDataArray[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatViewController *chatVC = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    chatVC.user = user;
    chatVC.sessionID = user.userId;
    SCNavigationController *SCNav = [[SCNavigationController alloc] initWithRootViewController:chatVC];
    [self presentViewController:SCNav animated:YES completion:nil];
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

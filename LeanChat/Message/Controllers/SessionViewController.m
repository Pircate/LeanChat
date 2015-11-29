//
//  MessageViewController.m
//  LeanChat
//
//  Created by gao on 15/11/17.
//  Copyright © 2015年 gao. All rights reserved.
//

#import "SessionViewController.h"
#import "ChatViewController.h"
#import "MessageCell.h"

@interface SessionViewController () <UITableViewDataSource,UITableViewDelegate,NIMConversationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *sessionTableView;

@end

@implementation SessionViewController
{
    NSArray *array;
}

// 构造方法
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:@"SessionViewController" bundle:nil]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        // 设置conversation代理
        [NIM_CONVERSATION_MANAGER addDelegate:self];
    }
    return self;
}
// 析构方法
- (void)dealloc
{
    // 移除conversation代理
    [NIM_CONVERSATION_MANAGER removeDelegate:self];
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 进入会话窗口刷新页面
    [self.sessionTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.sc_navigationItem.title = @"最近会话";
    [self initSessionTableView];
    
    // 监听移除最近会话的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRecentSession:) name:@"delete" object:nil];
}

// 收到通知后调用方法
- (void)removeRecentSession:(NSNotification *)sender
{
    for (NIMRecentSession *recentSession in [[[NIMSDK sharedSDK] conversationManager] allRecentSessions]) {
        if ([recentSession.session.sessionId isEqualToString:sender.object]) {
            [NIM_CONVERSATION_MANAGER deleteRecentSession:recentSession];
            [self.sessionTableView reloadData];
        }
    }
}

#pragma mark - 初始化会话列表
- (void)initSessionTableView
{
    self.sessionTableView.dataSource = self;
    self.sessionTableView.delegate = self;
    self.sessionTableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark - UITableViewDataSource方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[NIM_CONVERSATION_MANAGER allRecentSessions] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NIMRecentSession *recentSession = [[[NIMSDK sharedSDK] conversationManager] allRecentSessions][indexPath.row];
    MessageCell *messageCell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    if (!messageCell) {
        messageCell = [[[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:nil] lastObject];
    }
    messageCell.textLabel.text = recentSession.session.sessionId;
    messageCell.detailTextLabel.text = recentSession.lastMessage.text;
    return messageCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 点击最近会话跳转对应的聊天界面
    NIMRecentSession *recentSession = [NIM_CONVERSATION_MANAGER allRecentSessions][indexPath.row];
    ChatViewController *chatVC = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    chatVC.sessionID = recentSession.session.sessionId;
    SCNavigationController *SCNav = [[SCNavigationController alloc] initWithRootViewController:chatVC];
    [self presentViewController:SCNav animated:YES completion:nil];
}

#pragma mark - 编辑
// 开启编辑按钮效果
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.sessionTableView setEditing:editing animated:YES];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
// 提交cell的编辑效果
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NIMRecentSession *recentSession = [NIM_CONVERSATION_MANAGER allRecentSessions][indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 删除最近会话
        [NIM_CONVERSATION_MANAGER deleteRecentSession:recentSession];
        // 重新刷新tableView
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}
/**
 *  @return cell的编辑方式
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
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

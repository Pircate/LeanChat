//
//  ChatViewController.m
//  LeanChat
//
//  Created by gao on 15/11/17.
//  Copyright © 2015年 gao. All rights reserved.
//

#import "ChatViewController.h"
#import "SendMessageCell.h"
#import "ReceiveMessageCell.h"

@interface ChatViewController () <NIMChatManagerDelegate,NIMConversationManagerDelegate,NIMMediaManagerDelgate,UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UITextView *chatTextView;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UIButton *faceBtn;
@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
- (IBAction)voiceClick:(UIButton *)sender;
- (IBAction)moreClick:(UIButton *)sender;
- (IBAction)faceClick:(UIButton *)sender;

@end

@implementation ChatViewController
{
    NSMutableArray *_dataArray;
}

// 构造方法
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:@"ChatViewController" bundle:nil]) {
        _dataArray = [NSMutableArray array];
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        [[NIMSDK sharedSDK].chatManager addDelegate:self];
        [NIM_CONVERSATION_MANAGER addDelegate:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

// 析构方法
- (void)dealloc
{
    [[NIMSDK sharedSDK].chatManager removeDelegate:self];
    [NIM_CONVERSATION_MANAGER removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NIMSession *session = [NIMSession session:self.sessionID type:NIMSessionTypeP2P];
    NSArray *messages = [[[NIMSDK sharedSDK] conversationManager] messagesInSession:session message:nil limit:100];
    _dataArray = [NSMutableArray array];
    [_dataArray addObjectsFromArray:messages];
    [self.chatTableView reloadData];
    if (_dataArray.count > 1) {
        NSIndexPath * idxPath = [NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0];
        [self.chatTableView scrollToRowAtIndexPath:idxPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.sc_navigationItem.title = self.user.userInfo.nickName;
    self.chatTextView.returnKeyType = UIReturnKeySend;
    self.chatTextView.delegate = self;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self initNavigationItem];
    [self initChatTableView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[[NIMSDK sharedSDK] mediaManager] stopRecord];
    [[[NIMSDK sharedSDK] mediaManager] stopPlay];
}

#pragma mark - 初始化导航栏控件
- (void)initNavigationItem
{
    SCBarButtonItem *deleteBtn = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ino"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        NIMSession *session = [NIMSession session:self.sessionID type:NIMSessionTypeP2P];
        [NIM_CONVERSATION_MANAGER deleteAllmessagesInSession:session removeRecentSession:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"delete" object:self.sessionID];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    self.sc_navigationItem.rightBarButtonItem = deleteBtn;
    
    UIImage *backImage = [[ImageTool shareTool] resizeImageToSize:CGSizeMake(50, 35) sizeOfImage:[UIImage imageNamed:@"ie_arrow_normal"]];
    SCBarButtonItem *backBtn = [[SCBarButtonItem alloc] initWithImage:backImage style:SCBarButtonItemStylePlain handler:^(id sender) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    self.sc_navigationItem.leftBarButtonItem = backBtn;
}

#pragma mark - 初始化chatTableView
- (void)initChatTableView
{
    self.chatTableView.dataSource = self;
    self.chatTableView.delegate = self;
    self.chatTableView.tableFooterView = [[UIView alloc] init];
    self.chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

}

#pragma mark - UITableViewDataSource方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NIMMessage *message = _dataArray[indexPath.row];
    
    if (message.isOutgoingMsg) {
        SendMessageCell *sendCell = [tableView dequeueReusableCellWithIdentifier:@"SendMessageCell"];
        if (!sendCell) {
            sendCell = [[[NSBundle mainBundle] loadNibNamed:@"SendMessageCell" owner:self options:nil] lastObject];
        }
        sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [sendCell initWithMessage:message target:self];
        return sendCell;
    } else {
        ReceiveMessageCell *receiveCell = [tableView dequeueReusableCellWithIdentifier:@"ReceiveMessageCell"];
        if (!receiveCell) {
            receiveCell = [[[NSBundle mainBundle] loadNibNamed:@"ReceiveMessageCell" owner:self options:nil] lastObject];
        }
        receiveCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [receiveCell initWithMessage:message target:self];
        return receiveCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NIMMessage *message = _dataArray[indexPath.row];
    switch (message.messageType) {
        case NIMMessageTypeText:
        {
            CGRect rect = [message.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 16, 300) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
            return rect.size.height + 20;
        }
            break;
        case NIMMessageTypeImage:
        {
            NIMImageObject *imageObject = (NIMImageObject *)message.messageObject;
            NSString *path = imageObject.thumbPath;
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            if (image.size.height < 150) {
                return image.size.height + 20;
            } else {
                return 170;
            }
        }
            break;
        case NIMMessageTypeAudio:
        {
            return 44;
        }
            break;
        case NIMMessageTypeVideo:
        {
            return 44;
        }
            break;
        case NIMMessageTypeLocation:
        {
            return 44;
        }
            break;
        case NIMMessageTypeNotification:
        {
            return 44;
        }
            break;
        case NIMMessageTypeFile:
        {
            return 44;
        }
            break;
        case NIMMessageTypeCustom:
        {
            return 44;
        }
            break;
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - 响应键盘事件
- (void)keyboardWillShow:(NSNotification *)sender
{
    CGRect rect = [[sender.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    [UIView animateWithDuration:[[sender.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        self.backgroundView.transform = CGAffineTransformMakeTranslation(0, -rect.size.height);
    }];
}
- (void)keyboardWillHide:(NSNotification *)sender
{
    [UIView animateWithDuration:[[sender.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        self.backgroundView.transform = CGAffineTransformIdentity;
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - 键盘发送按钮点击事件
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"] && ![text isEqualToString:@""]) {
        [self sendTextMessage];
        self.chatTextView.text = @"";
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - 发送消息
// 创建对话和发送消息
- (void)sendMessageWithNIMMessage:(NIMMessage *)message
{
    NIMSession *session = [NIMSession session:self.sessionID type:NIMSessionTypeP2P];
    [[[NIMSDK sharedSDK] chatManager] sendMessage:message toSession:session error:nil];
}
// 发送文字消息
- (void)sendTextMessage
{
    NIMMessage *message = [[NIMMessage alloc] init];
    message.text = self.chatTextView.text;
    message.timestamp = [[NSDate date] timeIntervalSince1970];
    
    [self sendMessageWithNIMMessage:message];
}
// 发送图片消息
- (void)sendImageMessageWithImage:(UIImage *)image
{
    NIMImageObject *imageObject = [[NIMImageObject alloc] initWithImage:image];
    NIMImageOption *option = [[NIMImageOption alloc] init];
    option.compressQuality = 0.8;
    NIMMessage *message = [[NIMMessage alloc] init];
    message.messageObject = imageObject;
    message.timestamp = [[NSDate date] timeIntervalSince1970];
    
    [self sendMessageWithNIMMessage:message];
}
// 发送音频消息
- (void)sendVoiceMessageWithFilePath:(NSString *)filePath
{
    NIMAudioObject *audioObject = [[NIMAudioObject alloc] initWithSourcePath:filePath];
    NIMMessage *message = [[NIMMessage alloc] init];
    message.messageObject = audioObject;
    message.timestamp = [[NSDate date] timeIntervalSince1970];
    [self sendMessageWithNIMMessage:message];
}
// 发送视频信息
- (void)sendVideoMessage
{
    NIMVideoObject *videoObject = [[NIMVideoObject alloc] initWithSourcePath:@""];
    NIMMessage *message = [[NIMMessage alloc] init];
    message.messageObject = videoObject;
    [self sendMessageWithNIMMessage:message];
}
// 发送地理位置
- (void)sendLocationMessage
{
    NIMLocationObject *locationObject = [[NIMLocationObject alloc] initWithLatitude:0 longitude:0 title:@""];
    NIMMessage *message = [[NIMMessage alloc] init];
    message.messageObject = locationObject;
    [self sendMessageWithNIMMessage:message];
}

// 录制音频
- (void)recordAudio
{
    if (![[[NIMSDK sharedSDK] mediaManager] isRecording]) {
        [[[NIMSDK sharedSDK] mediaManager] recordAudioForDuration:60 withDelegate:self];
    }
}
#pragma mark - NIMMediaManagerDelgate方法
// 开始录制
- (void)recordAudio:(NSString *)filePath didBeganWithError:(NSError *)error
{
    
}
// 录制完成
- (void)recordAudio:(NSString *)filePath didCompletedWithError:(NSError *)error
{
    [self sendVoiceMessageWithFilePath:filePath];
}
// 录制时间进度
- (void)recordAudioProgress:(NSTimeInterval)currentTime
{
    
}
// 音频播放结束
- (void)playAudio:(NSString *)filePath didCompletedWithError:(NSError *)error
{
    
}

#pragma mark - NIMChatManagerDelegate方法
// 消息即将发送
- (void)willSendMessage:(NIMMessage *)message
{
    [_dataArray addObject:message];
    [self.chatTableView reloadData];
    NSIndexPath * idxPath = [NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0];
    [self.chatTableView scrollToRowAtIndexPath:idxPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
// 消息发送完毕回调
- (void)sendMessage:(NIMMessage *)message didCompleteWithError:(NSError *)error
{
    if (!error) {
        
    } else {
        NSLog(@"发送失败");
    }
}
// 消息发送失败重发
- (BOOL)resendMessage:(NIMMessage *)message
                error:(NSError **)error
{
    if (error) {
        [self sendMessageWithNIMMessage:message];
        return YES;
    }
    return YES;
}

// 接收消息回调
- (void)onRecvMessages:(NSArray *)messages
{
    for (NIMMessage *message in messages) {
        // 判断消息来源是否是当前会话的好友
        if (message.from == self.sessionID) {
            switch (message.messageType) {
                case NIMMessageTypeText:
                {
                    [_dataArray addObject:message];
                    [self.chatTableView reloadData];
                    NSIndexPath * idxPath = [NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0];
                    [self.chatTableView scrollToRowAtIndexPath:idxPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
                    break;
                case NIMMessageTypeImage:
                {
                    [_dataArray addObject:message];
                    [self.chatTableView reloadData];
                    NSIndexPath * idxPath = [NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0];
                    [self.chatTableView scrollToRowAtIndexPath:idxPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
                    break;
                case NIMMessageTypeAudio:
                {
                    [_dataArray addObject:message];
                    [self.chatTableView reloadData];
                    NSIndexPath * idxPath = [NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0];
                    [self.chatTableView scrollToRowAtIndexPath:idxPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
                    break;
                default:
                    break;
            }

        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)voiceClick:(UIButton *)sender {
    if (!sender.selected) {
        [self recordAudio];
    } else {
        [[NIMSDK sharedSDK].mediaManager stopRecord];
    }
    sender.selected = !sender.selected;
}

- (IBAction)moreClick:(UIButton *)sender {
    UIImagePickerController * imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.navigationBar.tintColor = [UIColor blackColor];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark --UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [self sendImageMessageWithImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)faceClick:(UIButton *)sender {
}
@end

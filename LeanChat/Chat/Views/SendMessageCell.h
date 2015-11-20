//
//  SendMessageCell.h
//  LeanChat
//
//  Created by gao on 15/11/17.
//  Copyright © 2015年 gao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendMessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *sendMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sendMessageImgView;
@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;

@property (nonatomic, copy) void(^block)(void);

- (IBAction)playAudio:(UIButton *)sender;
- (void)initWithMessage:(NIMMessage *)message target:(id)target;

@end

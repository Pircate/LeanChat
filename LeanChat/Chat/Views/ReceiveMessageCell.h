//
//  ReceiveMessageCell.h
//  LeanChat
//
//  Created by gao on 15/11/17.
//  Copyright © 2015年 gao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceiveMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *receiveMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *receiveMessageImgView;
@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;

@property (nonatomic, copy) void(^block)(void);
@property (nonatomic, strong) UIButton *selectedBtn;

- (IBAction)playAudio:(UIButton *)sender;
- (void)initWithMessage:(NIMMessage *)message target:(id)target;

@end

//
//  SendMessageCell.m
//  LeanChat
//
//  Created by gao on 15/11/17.
//  Copyright © 2015年 gao. All rights reserved.
//

#import "SendMessageCell.h"

@class NIMMessage;

@implementation SendMessageCell
{
    NSString *_duration;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)playAudio:(UIButton *)sender {
    if (!sender.selected) {
        [[[NIMSDK sharedSDK] mediaManager] stopPlay];
        self.block();
    } else {
        [[[NIMSDK sharedSDK] mediaManager] stopPlay];
    }
    sender.selected = !sender.selected;
}

- (void)initWithMessage:(NIMMessage *)message target:(id)target
{
    switch (message.messageType) {
        case NIMMessageTypeText:
        {
            self.sendMessageImgView.hidden = YES;
            self.voiceBtn.hidden = YES;
            self.sendMessageLabel.text = message.text;
        }
            break;
        case NIMMessageTypeImage:
        {
            self.sendMessageLabel.hidden = YES;
            self.voiceBtn.hidden = YES;
            NIMImageObject *imageObject = (NIMImageObject *)message.messageObject;
            NSString *path = imageObject.thumbPath;
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            self.sendMessageImgView.image = image;
        }
            break;
        case NIMMessageTypeAudio:
        {
            self.sendMessageLabel.hidden = YES;
            self.sendMessageImgView.hidden = YES;
            NIMAudioObject *audioObject = (NIMAudioObject *)message.messageObject;
            _duration = [NSString stringWithFormat:@"%ld”",(long)audioObject.duration / 1000];
            [[[NIMSDK sharedSDK] mediaManager]switchAudioOutputDevice:NIMAudioOutputDeviceReceiver];
            void(^playAudio)(void) = ^{
                if (![[[NIMSDK sharedSDK] mediaManager] isPlaying]) {
                    [[[NIMSDK sharedSDK] mediaManager] playAudio:audioObject.path withDelegate:target];
                }
            };
            self.block = playAudio;
        }
            break;
        default:
            break;
    }
}

- (void)layoutSubviews
{
    [self.voiceBtn setTitle:_duration forState:UIControlStateNormal];
}

@end

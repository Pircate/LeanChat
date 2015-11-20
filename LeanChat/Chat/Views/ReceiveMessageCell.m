//
//  ReceiveMessageCell.m
//  LeanChat
//
//  Created by gao on 15/11/17.
//  Copyright © 2015年 gao. All rights reserved.
//

#import "ReceiveMessageCell.h"

@implementation ReceiveMessageCell
{
    NSString *_duration;
}

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (IBAction)playAudio:(UIButton *)sender {
    if (!sender.selected) {
        [[[NIMSDK sharedSDK] mediaManager] stopPlay];
        self.block();
        sender.selected = YES;
    } else {
        [[[NIMSDK sharedSDK] mediaManager] stopPlay];
        sender.selected = NO;
    }
}

- (void)initWithMessage:(NIMMessage *)message target:(id)target
{
    switch (message.messageType) {
        case NIMMessageTypeText:
        {
            self.receiveMessageImgView.hidden = YES;
            self.voiceBtn.hidden = YES;
            self.receiveMessageLabel.text = message.text;
        }
            break;
        case NIMMessageTypeImage:
        {
            self.receiveMessageLabel.hidden = YES;
            self.voiceBtn.hidden = YES;
            NIMImageObject *imageObject = (NIMImageObject *)message.messageObject;
            NSString *path = imageObject.thumbPath;
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            self.receiveMessageImgView.image = image;
        }
            break;
        case NIMMessageTypeAudio:
        {
            self.receiveMessageLabel.hidden = YES;
            self.receiveMessageImgView.hidden = YES;
            NIMAudioObject *audioObject = (NIMAudioObject *)message.messageObject;
            _duration = [NSString stringWithFormat:@"%ld”",(long)audioObject.duration / 1000];
            void(^playAudio)(void) = ^{
                [[[NIMSDK sharedSDK] mediaManager]switchAudioOutputDevice:NIMAudioOutputDeviceReceiver];
                
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

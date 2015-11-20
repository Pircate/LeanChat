//
//  ChatViewController.h
//  LeanChat
//
//  Created by gao on 15/11/17.
//  Copyright © 2015年 gao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController

@property (nonatomic, strong) NIMUser *user;
@property (nonatomic, strong) NSString *sessionID;

@end

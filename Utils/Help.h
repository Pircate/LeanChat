//
//  Help.h
//  LeanChat
//
//  Created by gao on 15/11/19.
//  Copyright © 2015年 gao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Help : NSObject

+ (Help *)shareHelp;

- (void)initTableView:(UITableView *)tableView target:(id)target;

@end

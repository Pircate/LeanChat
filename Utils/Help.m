//
//  Help.m
//  LeanChat
//
//  Created by gao on 15/11/19.
//  Copyright © 2015年 gao. All rights reserved.
//

#import "Help.h"

static Help *help = nil;

@implementation Help

- (void)initTableView:(UITableView *)tableView target:(id)target
{
    tableView.dataSource = target;
    tableView.delegate = target;
    tableView.tableFooterView = [[UIView alloc] init];
}

+ (Help *)shareHelp
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (help == nil) {
            help = [[Help alloc] init];
        }
    });
    return help;
}

@end

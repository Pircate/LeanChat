//
//  TableHeaderView.m
//  LeanChat
//
//  Created by gao on 15/11/19.
//  Copyright © 2015年 gao. All rights reserved.
//

#import "TableHeaderView.h"

@implementation TableHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initLayout];
    }
    return self;
}

- (void)initLayout
{
    float width = (SCREEN_WIDTH - 15 * 5) / 4.0;
    NSArray *titles = @[@"验证消息",@"高级群组",@"普通群组",@"黑名单"];
    for (int i = 0; i < 4; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15 + (width + 15) * i, 0, width, width)];
        button.tag = 10 + i;
        button.layer.cornerRadius = width / 2.0;
        button.layer.masksToBounds = YES;
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self addSubview:self.button];
    }
}


@end

//
//  RootViewController.m
//  LeanChat
//
//  Created by gao on 15/11/17.
//  Copyright © 2015年 gao. All rights reserved.
//

#import "RootViewController.h"
#import "LoginViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.backgroundView.backgroundColor = [UIColor colorWithRed:0.2392 green:0.4314 blue:0.7176 alpha:1];
    [self setUpViewControllers];
}

- (void)setUpViewControllers
{
    NSArray *titleArray = @[@"Session",@"Contacter",@"My"];
    NSMutableArray * classArray = [NSMutableArray array];
    for (NSString *title in titleArray) {
        Class class = NSClassFromString([NSString stringWithFormat:@"%@ViewController",title]);
        UIViewController * vc = [[class alloc] initWithNibName:[NSString stringWithFormat:@"%@ViewController",title] bundle:nil];
        SCNavigationController *nav = [[SCNavigationController alloc] initWithRootViewController:vc];
        [classArray addObject:nav];
    }
    self.viewControllers = classArray;
    self.selectedIndex = 0;
    [self customizeTabBarForController:self];
}

- (void)customizeTabBarForController:(RDVTabBarController *)tabBarController {
    
    NSArray *imageArray = @[@"skin_tab_icon_conversation_normal",@"skin_tab_icon_contact_normal",@"skin_tab_icon_plugin_normal"];
    NSArray *imgPressArray = @[@"skin_tab_icon_conversation_selected",@"skin_tab_icon_contact_selected",@"skin_tab_icon_plugin_selected"];
    NSArray *titleArr = @[@"消息",@"联系人",@"动态"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[tabBarController tabBar] items]) {
        // 设置title
        item.title = titleArr[index];
        
        UIImage *image = [UIImage imageNamed:imageArray[index]];
        UIImage *imagePress = [UIImage imageNamed:imgPressArray[index]];
        
        UIImage *newImage = [[ImageTool shareTool] resizeImageToSize:CGSizeMake(30, 30) sizeOfImage:image];
        UIImage *newImagePress = [[ImageTool shareTool] resizeImageToSize:CGSizeMake(30, 30) sizeOfImage:imagePress];
        
        [item setFinishedSelectedImage:newImagePress withFinishedUnselectedImage:newImage];
        
        NSDictionary *normalAttributes = nil;
        NSDictionary *selectedAttributes = nil;
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            normalAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor lightGrayColor]};
            selectedAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor whiteColor]};
        }
        
        // 设置未选中状态title的字体大小和颜色
        item.unselectedTitleAttributes = normalAttributes;
        // 设置选中状态title的字体大小和颜色
        item.selectedTitleAttributes = selectedAttributes;
        
        index++;
    }
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

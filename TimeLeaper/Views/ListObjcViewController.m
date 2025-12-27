//
//  ListObjcViewController.m
//  TimeLeaper
//
//  Created by 上條蓮太朗 on 2025/12/26.
//

#import "ListObjcViewController.h"

@implementation ListObjcViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.systemBlueColor;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = @"Hello from Objective-C";
    label.textColor = UIColor.whiteColor;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:label];
    
    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
}

@end

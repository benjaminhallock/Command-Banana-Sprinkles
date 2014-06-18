//
//  TabBarViewController.m
//  MyFace
//
//  Created by benjaminhallock@gmail.com on 6/17/14.
//  Copyright (c) 2014 Mobile Makers Academy. All rights reserved.
//

#import "TabBarViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad
{
//    CGRect tabBarFrame = self.tabBar.frame ;
//    tabBarFrame.origin.y = self.view.window.frame.size.height;
//    tabBarFrame.size.height = 100;
//    self.tabBar.frame = tabBarFrame;
//    self.tabBarController.delegate = self;
    self.delegate = self;
    /* Tab Bar Background */

    //
//    UIImage *tabBarBackgroundImage = [UIImage imageNamed:@""];
//    [[UITabBar appearance] setBackgroundImage:tabBarBackgroundImage];

    /* Tab Bar Item */
    UIButton *surveyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [surveyButton addTarget:self action:@selector(surveyButtonDidSelect) forControlEvents:UIControlEventTouchUpInside];
    surveyButton.tag = 0;
    [surveyButton setBackgroundImage:[UIImage imageNamed:@"gallerybutton"] forState:UIControlStateNormal];

    CGRect surveyButtonFrame = surveyButton.frame ;
    surveyButtonFrame.origin.x = 0;
    surveyButtonFrame.origin.y = 0;
    surveyButtonFrame.size.height = 50;
    surveyButtonFrame.size.width = (320/3);
    surveyButton.frame = surveyButtonFrame;
    [self.tabBar addSubview:surveyButton];

    ////////////////

    UIButton *statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    statusButton.tag = 1;
    [statusButton addTarget:self action:@selector(statusButtonDidSelect) forControlEvents:UIControlEventTouchUpInside];
    [statusButton setBackgroundImage:[UIImage imageNamed:@"myfacebutton"] forState:UIControlStateNormal];

    CGRect statusButtonFrame = statusButton.frame ;
    statusButtonFrame.origin.x = (320/3);
    statusButtonFrame.origin.y = 0;
    statusButtonFrame.size.height = 50;
    statusButtonFrame.size.width = (320/3);
    statusButton.frame = statusButtonFrame;

    [self.tabBar addSubview:statusButton];

    ////////////////////

    UIButton *camerabutton = [UIButton buttonWithType:UIButtonTypeCustom];
    camerabutton.tag = 2;
    [camerabutton addTarget:self action:@selector(cameraButtonDidSelect) forControlEvents:UIControlEventTouchUpInside];
    [camerabutton setBackgroundImage:[UIImage imageNamed:@"camerabutton"] forState:UIControlStateNormal];

    CGRect cameraButtonFrame = camerabutton.frame ;
    cameraButtonFrame.origin.x = (320/3 + 320/3);
    cameraButtonFrame.origin.y = 0;
    cameraButtonFrame.size.height = 50;
    cameraButtonFrame.size.width = 108;
    camerabutton.frame = cameraButtonFrame;
    [self.tabBar addSubview:camerabutton];
}

-(void)surveyButtonDidSelect
{
    self.selectedIndex = 0;
    self.selectedViewController = self.viewControllers[0];
}
-(void)statusButtonDidSelect
{
    self.selectedIndex = 1;
    self.selectedViewController = self.viewControllers[1];

}
-(void)cameraButtonDidSelect
{
    self.selectedIndex = 2;
    self.selectedViewController = self.viewControllers[2];
}

@end

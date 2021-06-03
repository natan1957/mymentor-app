//
//  MMNavigationController.h
//  MyMentorV2
//
//  Created by Walter Yaron on 12/29/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "FavoriteViewController.h"
#import "AboutViewController.h"
#import "AppSettingsViewController.h"
#import "LoginViewController.h"


@interface MMNavigationController : UINavigationController

@property (strong, nonatomic) MainViewController *mainController;
@property (strong, nonatomic) FavoriteViewController *favoriteController;
@property (strong, nonatomic) AppSettingsViewController *appSettingsController;
@property (strong, nonatomic) LoginViewController *loginController;
@property (strong, nonatomic) AboutViewController *aboutController;
//@property (strong, nonatomic) LessonSettingsViewController *settingsController;

//- (instancetype)initWithStoryBoard:(UIStoryboard*)storyboard;
- (void)exchangeRootViewController:(NSInteger)index;

- (MainViewController*)getMainViewController;
- (FavoriteViewController*)getFavoriteViewController;
- (AppSettingsViewController*)getAppSettingsViewController;
- (AboutViewController*)getAboutViewController;
- (LoginViewController*)getLoginViewController;
//- (LessonSettingsViewController*)getLessonSettingsViewController;

@end

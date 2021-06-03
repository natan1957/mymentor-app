//
//  MMNavigationController.m
//  MyMentorV2
//
//  Created by Walter Yaron on 12/29/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

//@import Parse;
#import <Parse/Parse.h>
#import "MMNavigationController.h"

@interface MMNavigationController ()

@end

@implementation MMNavigationController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        self.mainController = self.viewControllers[0];
        self.favoriteController = [storyboard instantiateViewControllerWithIdentifier:@"FavoriteViewController"];
        self.appSettingsController = [storyboard instantiateViewControllerWithIdentifier:@"AppSettingsViewController"];
        self.loginController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        self.aboutController = [storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
    }

    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (instancetype)initWithStoryBoard:(UIStoryboard*)storyboard
//{
//    self = [super initWithRootViewController:self.mainController];
//    if (self)
//    {
//        self.favoriteController = [storyboard instantiateViewControllerWithIdentifier:@"FavoriteViewController"];
//        self.appSettingsController = [storyboard instantiateViewControllerWithIdentifier:@"AppSettingsViewController"];
//        self.aboutController = [storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
//    }
//    return self;
//}

-(MainViewController*)getMainViewController
{
    return self.mainController;
}

- (FavoriteViewController*)getFavoriteViewController
{
    return self.favoriteController;
}

- (AppSettingsViewController*)getAppSettingsViewController
{
    return self.appSettingsController;
}

- (LoginViewController*)getLoginViewController
{
    return self.loginController;
}

- (AboutViewController*)getAboutViewController
{
    return self.aboutController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBar.translucent = NO;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)exchangeRootViewController:(NSInteger)index
{
    [self popToRootViewControllerAnimated:NO];
    switch (index)
    {
        case 0:
            self.viewControllers = @[self.mainController];
            break;
        case 1:
            self.viewControllers = @[self.favoriteController];
            break;
        case 2:
            self.viewControllers = @[self.appSettingsController];
            break;
        case 3:
        {
            if ([[PFUser currentUser] isAuthenticated])
                self.viewControllers = @[self.aboutController];
            else
                self.viewControllers = @[self.loginController];
            break;
        }
        case 4:
            self.viewControllers = @[self.aboutController];
            break;
        default:
            break;
    }
}

@end

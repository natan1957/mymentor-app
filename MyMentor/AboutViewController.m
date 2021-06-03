//
//  AboutViewController.m
//  MyMentor
//
//  Created by Walter Yaron on 11/11/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

//@import Parse;
#import <Parse/Parse.h>
#import "AboutViewController.h"
#import "MMNavigationController.h"
#import "RNFrostedSidebar.h"
#import "Settings.h"

@interface AboutViewController () <RNFrostedSidebarDelegate>

@property (weak, nonatomic) IBOutlet UILabel *applicationVersionLabel;
@property (strong, nonatomic) RNFrostedSidebar *sideBar;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutText1Label;
@property (weak, nonatomic) IBOutlet UILabel *aboutText2Label;

- (IBAction)menuButtonDidPressed:(id)sender;

@end

@implementation AboutViewController

- (void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index
{
    SWRevealViewController *revealController = [self revealViewController];
    MMNavigationController *navController = (MMNavigationController*)revealController.frontViewController;
    [sidebar dismissAnimated:YES
                  completion:^(BOOL finished)
     {
         [navController exchangeRootViewController:index];
     }];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupMenu];
    [self updateTexts];
}

- (void)setupMenu
{
    self.applicationVersionLabel.text = [NSString stringWithFormat:@"MyMentor Version %@ Build %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];

    NSMutableArray *images = [@[ [UIImage imageNamed:@"btn_list_normal.png"],
                                 [UIImage imageNamed:@"btn_fav_normal.png"],
                                 [UIImage imageNamed:@"btn_settings_normal.png"],
                                 [UIImage imageNamed:@"btn_login_normal.png"],
                                 [UIImage imageNamed:@"btn_about_normal.png"]] mutableCopy];

    NSMutableArray *selectedImages = [@[ [UIImage imageNamed:@"btn_list_selected.png"],
                                         [UIImage imageNamed:@"btn_fav_selected.png"],
                                         [UIImage imageNamed:@"btn_settings_selected.png"],
                                         [UIImage imageNamed:@"btn_login_selected.png"],
                                         [UIImage imageNamed:@"btn_about_selected.png"]] mutableCopy];

    if ([[PFUser currentUser] isAuthenticated])
    {
        [images removeObjectAtIndex:3];
        [selectedImages removeObjectAtIndex:3];
        self.usernameLabel.text = [PFUser currentUser].username;
    }
    else
    {
        self.usernameLabel.text = @"";
    }

    self.sideBar = [[RNFrostedSidebar alloc] initWithImages:images selectedImages:selectedImages];
    self.sideBar.delegate = self;
}

- (void)updateTexts
{
    if ([[Settings sharedInstance].currentLanguage isEqual:@"he_il"])
    {
        self.aboutText1Label.textAlignment = NSTextAlignmentRight;
        self.aboutText2Label.textAlignment = NSTextAlignmentRight;
    }
    else
    {
        self.aboutText1Label.textAlignment = NSTextAlignmentLeft;
        self.aboutText2Label.textAlignment = NSTextAlignmentLeft;
    }
    self.title = [[Settings sharedInstance] getStringByName:@"about_title"];
    self.aboutText1Label.text = [[Settings sharedInstance] getStringByName:@"about_text1"];
    self.aboutText2Label.text = [[Settings sharedInstance] getStringByName:@"about_text2"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)menuButtonDidPressed:(id)sender
{
    if ([[PFUser currentUser] isAuthenticated])
        [self.sideBar show:3];
    else
        [self.sideBar show:4];
}

@end

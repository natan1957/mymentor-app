//
//  LoginViewController.m
//  MyMentorV2
//
//  Created by Walter Yaron on 4/16/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "MMNavigationController.h"
#import "Settings.h"
#import "MBProgressHUD.h"
#import "RNFrostedSidebar.h"
#import "AppDelegate.h"
#import "User.h"
#import "YHRoundBorderedButton.h"
#import "Settings.h"

@interface LoginViewController () < UITextFieldDelegate,
                                    RNFrostedSidebarDelegate,
                                    UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet YHRoundBorderedButton *loginButton;
@property (weak, nonatomic) IBOutlet YHRoundBorderedButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UIButton *portalButton;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) RNFrostedSidebar *sideBar;
@property (strong, nonatomic) MBProgressHUD *hud;

- (IBAction)cancelButtonDidClicked:(id)sender;
- (IBAction)loginButtonDidClicked:(id)sender;
- (IBAction)menuButtonDidPressed:(id)sender;

@end

@implementation LoginViewController

#pragma mark - RNfrostedSideBar Delegate

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

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        {
            [self updateLogWithAction:ActionTypeLogout];
            [PFUser logOut];
            self.usernameTextField.text = @"";
            self.passwordTextField.text = @"";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.hud hide:YES];
                [self closeView];
            });
            break;
        }
        case 1:
        {
            self.usernameTextField.text = @"";
            self.passwordTextField.text = @"";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.hud hide:YES];
                [self registerUserToDevice];
            });
            break;
        }
        default:
            break;
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 1)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField.tag == 2)
    {
        [self loginWithUserInformation];
    }
    return YES;
}

- (void)closeView
{
    SWRevealViewController *revealController = [self revealViewController];
    MMNavigationController *navController = (MMNavigationController*)revealController.frontViewController;

    [navController exchangeRootViewController:0];
    [revealController revealToggle:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)updateLogWithAction:(ActionType)type
{
    PFObject *log = [PFObject objectWithClassName:@"LogFile"];
    switch (type) {
        case ActionTypeLogin:
            log[@"action"] = @"Login";
            log[@"userName"] = [PFUser currentUser].username;
            if (![[PFUser currentUser][@"deviceIdentifier"] isEqualToString:[Settings sharedInstance].deviceIdentifier] && [PFUser currentUser][@"deviceIdentifier"]) {
                log[@"prevDevice"] = [PFUser currentUser][@"deviceIdentifier"];
            }
            break;
        case ActionTypeFailed_Login:
        {
            log[@"action"] = @"Failed_Login";
            break;
        }
        case ActionTypeLogout:
            log[@"action"] = @"Logout";
            log[@"userName"] = [PFUser currentUser].username;
            break;

        default:
            break;
    }

    log[@"appVersion"] = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    log[@"deviceID"] = [Settings sharedInstance].deviceIdentifier;
    log[@"sysVersion"] = [NSString stringWithFormat:@"iOS%@",[[UIDevice currentDevice] systemVersion]];
    log[@"system"] = @"App";
    log[@"time"] = [NSDate date];

    [log saveInBackground];
}

- (void)registerUserToDevice
{
    // Make a new role for administrators

//    PFACL *roleACL = [PFACL ACL];
//    [roleACL setPublicReadAccess:YES];
//    PFRole *role = [PFRole roleWithName:@"Administrators" acl:roleACL];
//    [role.users addObject:[PFUser currentUser]];
//    [role save];



//    PFQuery *query = [PFRole query];
//    [query whereKey:@"name" equalTo:@"Administrators"];
//    NSArray *results = [query findObjects];
//    PFRole *role = results[0];
//    [role.users addObject:[PFUser currentUser]];
//    [role save];



    [self updateLogWithAction:ActionTypeLogin];
    [Settings deleteContentWorlds];
    [Settings deleteClips];
    [Settings deleteAllUserFiles];
    [Settings deleteUser];
    self.usernameTextField.text = @"";
    self.passwordTextField.text = @"";

    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];

    [[PFUser currentUser] setObject:[Settings sharedInstance].deviceIdentifier forKey:@"deviceIdentifier"];
    [[PFUser currentUser] saveInBackground];
    [[Settings sharedInstance] saveUserToCoreData];

    PFObject *contentWorldId = [PFUser currentUser][@"contentType"];
    if (contentWorldId) {
    PFObject *world = [PFObject objectWithoutDataWithClassName:@"WorldContentType" objectId:contentWorldId.objectId];
        [[Settings sharedInstance] saveContentWorldToCoreData:world save:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateLessonsListAfterAction
                                                            object:nil
                                                          userInfo:nil];
        [self closeView];
    }
    else {
        MMNavigationController *navController = (MMNavigationController*)self.navigationController;
        [navController exchangeRootViewController:0];
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        AppSetupViewController *appSetup = [self.storyboard instantiateInitialViewController];
        appDelegate.window.rootViewController = appSetup;
        [appDelegate.window makeKeyAndVisible];
        [appDelegate setupMainViewController];
    }

}

- (void)loginWithUserInformation
{
    if (![self checkForInternet])
        return;

    UIWindow *tempKeyboardWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    self.hud=[[MBProgressHUD alloc] initWithWindow:tempKeyboardWindow];
    self.hud.mode=MBProgressHUDModeIndeterminate;
    [tempKeyboardWindow addSubview:self.hud];
    [self.hud show:YES];

    __weak LoginViewController *weakSelf = self;
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text
                                 password:self.passwordTextField.text
                                    block:^(PFUser *user, NSError *error)
    {
        [weakSelf.hud hide:NO];
        if (!error)
        {
            if (![[PFUser currentUser][@"deviceIdentifier"] isEqualToString:[Settings sharedInstance].deviceIdentifier] && [PFUser currentUser][@"deviceIdentifier"])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.hud show:YES];
                    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                         message:[[Settings sharedInstance] getStringByName:@"needtoreplacedevice"]
                                                                        delegate:weakSelf
                                                               cancelButtonTitle:[[Settings sharedInstance] getStringByName:@"needtoreplacedevicecancelbutton"]
                                                                                                          otherButtonTitles:[[Settings sharedInstance] getStringByName:@"needtoreplacedeviceokbutton"],nil];
                    [alertView show];
                });
            }
            else
            {
                PFObject *adminData = [PFUser currentUser][@"adminData"];
                [adminData fetch];
                PFObject *userStatus = adminData[@"userStatus"];
                [userStatus fetch];
                if ([userStatus[@"status"] isEqualToString:@"active"] || [userStatus[@"status"] isEqualToString:@"checking"] || [userStatus[@"status"] isEqualToString:@"app"])
                {
                    [weakSelf registerUserToDevice];
                }
                else
                {
                    [PFUser logOut];

                    NSString *message;

                    if ([userStatus[@"status"] isEqualToString:@"blocked"])
                    {
                        message = [[Settings sharedInstance] getStringByName:@"login_userstatusblocked"];
                    }
                    else if ([userStatus[@"status"] isEqualToString:@"hold"])
                    {
                        message = [[Settings sharedInstance] getStringByName:@"login_userstatushold"];
                    }
                    else if ([userStatus[@"status"] isEqualToString:@"new"])
                    {
                        message = [[Settings sharedInstance] getStringByName:@"login_userstatusnew"];
                    }

                    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                         message:message
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil];
                    [alertView show];
                }
            }
        }
        else
        {
            [weakSelf updateLogWithAction:ActionTypeFailed_Login];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:[[Settings sharedInstance] getStringByName:@"usernameandpasswordwrong"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            });
        }
    }];
}

- (void)updateTexts
{
    self.title = [[Settings sharedInstance] getStringByName:@"login_title"];
    [self.cancelButton setTitle:[[Settings sharedInstance] getStringByName:@"login_cancel"] forState:UIControlStateNormal];
    [self.loginButton setTitle:[[Settings sharedInstance] getStringByName:@"login_login"] forState:UIControlStateNormal];
    [self.portalButton setTitle:[[Settings sharedInstance] getStringByName:@"login_portal"] forState:UIControlStateNormal];
    self.usernameLabel.text = [[Settings sharedInstance] getStringByName:@"login_username"];
    self.passwordLabel.text = [[Settings sharedInstance] getStringByName:@"login_password"];

    
    if ([[UIScreen mainScreen] bounds].size.height == 480.f)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[[Settings sharedInstance] getStringByName:@"login_portal_480"] style:UIBarButtonItemStylePlain target:self action:@selector(pushRegisterView)];
        self.portalButton.hidden = YES;
    }
    else
    {
        NSMutableAttributedString *registerTitle = [[NSMutableAttributedString alloc] initWithString:[[Settings sharedInstance] getStringByName:@"login_portal"]];
        [registerTitle addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, [registerTitle length])];
        self.portalButton.titleLabel.attributedText = registerTitle;
        self.portalButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:20.];
    }
}

- (void)pushRegisterView
{
    [self performSegueWithIdentifier:@"openRegisterView" sender:nil];
}

- (BOOL)checkForInternet
{
    if (![(AppDelegate*)[[UIApplication sharedApplication] delegate] internetActive])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:[[Settings sharedInstance] getStringByName:@"nointernetfound"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    return YES;
}

- (void)setupView
{
//    [self.usernameTextField becomeFirstResponder];
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
    }

    self.sideBar = [[RNFrostedSidebar alloc] initWithImages:images selectedImages:selectedImages];
    self.sideBar.delegate = self;


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
    [self.usernameTextField becomeFirstResponder];
    [self updateTexts];
    [self checkForInternet];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonDidClicked:(id)sender
{
    [self loginWithUserInformation];
}

- (IBAction)cancelButtonDidClicked:(id)sender
{
    MMNavigationController *navController = (MMNavigationController*)self.navigationController;
    [navController exchangeRootViewController:0];
}

- (IBAction)menuButtonDidPressed:(id)sender
{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.sideBar show:3];
}

@end

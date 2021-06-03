//
//  SwitchUserViewController.m
//  MyMentorV2
//
//  Created by Walter Yaron on 5/10/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import "SwitchUserViewController.h"
#import "MMNavigationController.h"
#import "MBProgressHUD.h"
#import "Defines.h"
#import "AppDelegate.h"
#import "User.h"
#import "ChooseContentWorldViewController.h"
#import "Settings.h"
#import "YHRoundBorderedButton.h"

@interface SwitchUserViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *helpLabel;
@property (weak, nonatomic) IBOutlet YHRoundBorderedButton *loginButton;
@property (weak, nonatomic) IBOutlet YHRoundBorderedButton *logoutButton;
@property (weak, nonatomic) IBOutlet YHRoundBorderedButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (copy, nonatomic) NSString *firstUsername;
@property (copy, nonatomic) NSString *firstpassword;

@property (strong, nonatomic) PFUser *oldUser;
@property (assign, nonatomic) BOOL oldUserValideted;

- (IBAction)cancelButtonDidClicked:(id)sender;
- (IBAction)loginButtonDidClicked:(id)sender;
- (IBAction)logoutButtonTouchUpInside:(id)sender;

@end

@implementation SwitchUserViewController

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

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 3000) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            switch (buttonIndex) {
                case 0:
                    [self loginWithFirstUser];
                    break;
                case 1:
                    [self switchUser];
                    break;

                default:
                    break;
            }

        });
    }
    else if (alertView.tag == 2000)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            switch (buttonIndex) {
                case 0:
                    [self.usernameTextField resignFirstResponder];
                    [self.passwordTextField resignFirstResponder];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    break;
                case 1:
                    break;
                default:
                    break;
            }
        });
    }
    else
    {
        [self.usernameTextField becomeFirstResponder];
    }
}

- (void)continueToStep2
{
    self.title = [[Settings sharedInstance] getStringByName:@"switchuser_title2"];
    [self.logoutButton setHidden:YES];
    [self.loginButton setTitle:[[Settings sharedInstance] getStringByName:@"switchuser_login"] forState:UIControlStateNormal];
    self.helpLabel.text = [[Settings sharedInstance] getStringByName:@"switchuser_step2title"];
    self.firstUsername  = self.usernameTextField.text;
    self.firstpassword = self.passwordTextField.text;
    self.usernameTextField.text = @"";
    self.passwordTextField.text = @"";
    self.usernameTextField.userInteractionEnabled = YES;
    [self.usernameTextField becomeFirstResponder];
    [self.oldUser removeObjectForKey:@"deviceIdentifier"];
    [self.oldUser save];
}

- (void)loginWithFirstUser
{
    [PFUser logOut];
    [PFUser logInWithUsernameInBackground:self.firstUsername
                                 password:self.firstpassword
                                    block:^(PFUser *user, NSError *error)
     {
         if (!error)
         {
             [[PFUser currentUser] setObject:[Settings sharedInstance].deviceIdentifier forKey:@"deviceIdentifier"];
             [[PFUser currentUser] save];
             MMNavigationController *navController = (MMNavigationController*)self.navigationController;
             [navController exchangeRootViewController:0];
             [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateLessonsListAfterAction
                                                                 object:nil
                                                               userInfo:nil];
         }
     }];
}

- (void)switchUser
{
    [self updateLogWithAction:ActionTypeSwitch_User];
    [Settings deleteUser];
    [Settings deleteClips];
    [Settings deleteContentWorlds];
    [Settings deleteAllUserFiles];
    [[PFUser currentUser] setObject:[Settings sharedInstance].deviceIdentifier forKey:@"deviceIdentifier"];
    [[PFUser currentUser] save];
    [[Settings sharedInstance] saveUserToCoreData];

    PFObject *contentWorldId = [PFUser currentUser][@"contentType"];
    if (contentWorldId) {
        PFObject *world = [PFObject objectWithoutDataWithClassName:@"WorldContentType" objectId:contentWorldId.objectId];
        [[Settings sharedInstance] saveContentWorldToCoreData:world save:NO];
        MMNavigationController *navController = (MMNavigationController*)self.navigationController;
        [navController exchangeRootViewController:0];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateLessonsListAfterAction
                                                            object:nil
                                                          userInfo:nil];
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
    __block MBProgressHUD *hud=[[MBProgressHUD alloc] initWithWindow:tempKeyboardWindow];
    hud.mode=MBProgressHUDModeIndeterminate;
    [tempKeyboardWindow addSubview:hud];
    [hud show:YES];
    self.oldUser = [PFUser currentUser];
    __weak SwitchUserViewController *weakSelf = self;
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text
                                 password:self.passwordTextField.text
                                    block:^(PFUser *user, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^
         {
             [hud hide:NO];
             BOOL good = [weakSelf.oldUser.objectId isEqualToString:user.objectId] || weakSelf.oldUserValideted;
             if (!error && good)
             {
                 if (!weakSelf.oldUserValideted)
                 {
                     weakSelf.oldUserValideted = YES;
                     weakSelf.oldUser = user;
                     [weakSelf continueToStep2];
                 }
                 else
                 {
                     if (![[PFUser currentUser][@"deviceIdentifier"] isEqualToString:[Settings sharedInstance].deviceIdentifier] && [PFUser currentUser][@"deviceIdentifier"])
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                                  message:[[Settings sharedInstance] getStringByName:@"needtoreplacedevice"]
                                                                                 delegate:weakSelf
                                                                        cancelButtonTitle:[[Settings sharedInstance] getStringByName:@"needtoreplacedevicecancelbutton"]
                                                                        otherButtonTitles:[[Settings sharedInstance] getStringByName:@"needtoreplacedeviceokbutton"],nil];
                             alertView.tag = 3000;
                             [alertView show];
                         });
                     }
                     else
                     {
                         [weakSelf switchUser];
                     }
                 }
             }
             else
             {
                 [weakSelf updateLogWithAction:ActionTypeFailed_Login];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                 message:[[Settings sharedInstance] getStringByName:@"usernameandpasswordwrong"]
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
             }
         });
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
    [self.passwordTextField becomeFirstResponder];
}

- (void)setupView
{
    self.title = [[Settings sharedInstance] getStringByName:@"switchuser_title1"];
    self.helpLabel.text = [[Settings sharedInstance] getStringByName:@"switchuser_step1title"];
    self.usernameTextField.text = [PFUser currentUser].username;
    self.usernameTextField.userInteractionEnabled = NO;
    [self.loginButton setTitle:[[Settings sharedInstance] getStringByName:@"switchuser_next"] forState:UIControlStateNormal];
    [self.logoutButton setTitle:[[Settings sharedInstance] getStringByName:@"switchuser_logout"] forState:UIControlStateNormal];
    [self.cancelButton setTitle:[[Settings sharedInstance] getStringByName:@"switchuser_cancel"] forState:UIControlStateNormal];
    self.helpLabel.text = [[Settings sharedInstance] getStringByName:@"switchuser_step1title"];
    self.usernameLabel.text = [[Settings sharedInstance] getStringByName:@"switchuser_username"];
    self.passwordLabel.text = [[Settings sharedInstance] getStringByName:@"switchuser_password"];
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

- (void)showMessageToTheUser
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:[[Settings sharedInstance] getStringByName:@"switchuser_messagewhenswitching"]
                                                   delegate:self
                                          cancelButtonTitle:[[Settings sharedInstance] getStringByName:@"switchuser_messagewhenswitchingcancelbutton"]
                                          otherButtonTitles:[[Settings sharedInstance] getStringByName:@"switchuser_messagewhenswitchingokbutton"],nil];
    alert.tag = 2000;
    [alert show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
    if ([self checkForInternet])
        [self showMessageToTheUser];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateLogWithAction:(ActionType)type
{
    PFObject *log = [PFObject objectWithClassName:@"LogFile"];
    switch (type) {
        case ActionTypeLogout:
            log[@"action"] = @"Logout";
            log[@"userName"] = [PFUser currentUser].username;
            break;
        case ActionTypeSwitch_User:
        {
            log[@"action"] = @"Switch_User";
            log[@"userName"] = [PFUser currentUser].username;
            log[@"prevUser"] = self.oldUser.username;
            if ([PFUser currentUser][@"deviceIdentifier"]) {
                log[@"prevDevice"] = [PFUser currentUser][@"deviceIdentifier"];
            }
            break;
        }
        case ActionTypeFailed_Login:
        {
            log[@"action"] = @"Failed_Login";
            log[@"userName"] = self.usernameTextField.text;
            if (self.oldUser)
                log[@"prevUser"] = self.oldUser.username;

            break;
        }
        case ActionTypeFailed_Logout:
        {
            log[@"action"] = @"Failed_Logout";
            log[@"userName"] = [PFUser currentUser].username;
            break;
        }
        default:
            break;
    }

    log[@"appVersion"] = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    log[@"deviceID"] = [Settings sharedInstance].deviceIdentifier;
    log[@"sysVersion"] = [NSString stringWithFormat:@"iOS%@",[[UIDevice currentDevice] systemVersion]];
    log[@"system"] = @"App";
    log[@"time"] = [NSDate date];

    log.ACL = [PFACL ACL];
    [log saveInBackground];
}

- (IBAction)logoutButtonTouchUpInside:(id)sender
{
    UIWindow *tempKeyboardWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    __block MBProgressHUD *hud=[[MBProgressHUD alloc] initWithWindow:tempKeyboardWindow];
    hud.mode=MBProgressHUDModeIndeterminate;
    [tempKeyboardWindow addSubview:hud];
    [hud show:YES];
    self.oldUser = [PFUser currentUser];
    __weak SwitchUserViewController *weakSelf = self;

    [PFUser logInWithUsernameInBackground:self.usernameTextField.text
                                 password:self.passwordTextField.text
                                    block:^(PFUser *user, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [hud hide:NO];
             BOOL good = [weakSelf.oldUser.objectId isEqualToString:user.objectId];
             if (!error && good)
             {
                 [weakSelf updateLogWithAction:ActionTypeLogout];
                 [Settings deleteClips];
                 [Settings deleteContentWorlds];
                 [Settings deleteAllUserFiles];
                 [Settings deleteUser];
                 [[PFUser currentUser] removeObjectForKey:@"deviceIdentifier"];
                 [[PFUser currentUser] save];
                 [PFUser logOut];

                 [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateLessonsListAfterAction
                                                                     object:nil
                                                                   userInfo:nil];

                 weakSelf.usernameTextField.text = @"";
                 weakSelf.passwordTextField.text = @"";

                 MMNavigationController *navController = (MMNavigationController*)self.navigationController;
                 [navController exchangeRootViewController:0];
                 AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                 AppSetupViewController *appSetup = [self.storyboard instantiateInitialViewController];
                 appDelegate.window.rootViewController = appSetup;
                 [appDelegate.window makeKeyAndVisible];
                 [appDelegate setupMainViewController];
             }
             else
             {
                 [weakSelf updateLogWithAction:ActionTypeFailed_Logout];
                 [weakSelf.logoutButton setBackgroundColor:[UIColor redColor]];                 
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                 message:[[Settings sharedInstance] getStringByName:@"usernameandpasswordwrong"]
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];

             }
         });
     }];
}

- (IBAction)cancelButtonDidClicked:(id)sender
{
    [[PFUser currentUser] setObject:[Settings sharedInstance].deviceIdentifier forKey:@"deviceIdentifier"];
    [[PFUser currentUser] save];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)loginButtonDidClicked:(id)sender
{
    [self loginWithUserInformation];
}

@end

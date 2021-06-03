//
//  RegistarationViewController.m
//  MyMentorApp
//
//  Created by Walter Yaron on 12/27/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import "RegistarationViewController.h"
#import "YHRoundBorderedButton.h"
#import "MBProgressHUD.h"
#import "RNFrostedSidebar.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "CocoaSecurity.h"
#import "UIDevice+Hardware.h"
#import "Settings.h"
#import "User.h"
#import "MMNavigationController.h"
#import "AppDelegate.h"

@interface RegistarationViewController () < UITextFieldDelegate,
                                            RNFrostedSidebarDelegate,
                                            UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet YHRoundBorderedButton *loginButton;
@property (weak, nonatomic) IBOutlet YHRoundBorderedButton *cancelButton;

@property (strong, nonatomic) RNFrostedSidebar *sideBar;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *language;

- (IBAction)registerButtonDidPress:(id)sender;
- (IBAction)cancelButtonDidPress:(id)sender;

@end

@implementation RegistarationViewController

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 1)
    {

        NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";

        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:textField.text options:0 range:NSMakeRange(0, [textField.text length])];
        if (regExMatches == 0)
        {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                 message:[[Settings sharedInstance] getStringByName:@"register_email_not_valid"]
                                                                delegate:nil
                                                       cancelButtonTitle:[[Settings sharedInstance] getStringByName:@"register_email_not_valid_cancel"]
                                                       otherButtonTitles:nil];
            [alertView show];

        } else {
        [self.passwordTextField becomeFirstResponder];
        }

    }
    else if (textField.tag == 2)
    {
        if ([textField.text length] < 6) {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                 message:[[Settings sharedInstance] getStringByName:@"register_password_not_valid"]
                                                                delegate:nil
                                                       cancelButtonTitle:[[Settings sharedInstance] getStringByName:@"register_password_not_valid_cancel"]
                                                       otherButtonTitles:nil];
            [alertView show];
        }
        else
        {
            [self registerUser];
        }
    }
    return YES;
}


- (void)setupView
{
    self.title = [[Settings sharedInstance] getStringByName:@"register_title"];
    [self.loginButton setTitle:[[Settings sharedInstance] getStringByName:@"register_register"] forState:UIControlStateNormal];
    [self.cancelButton setTitle:[[Settings sharedInstance] getStringByName:@"register_cancel"] forState:UIControlStateNormal];
    self.usernameLabel.text = [[Settings sharedInstance] getStringByName:@"register_username"];
    self.passwordLabel.text = [[Settings sharedInstance] getStringByName:@"register_password"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.usernameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerUser
{
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";

    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:self.usernameTextField.text options:0 range:NSMakeRange(0, [self.usernameTextField.text length])];
    if (regExMatches == 0)
    {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil
                                                             message:[[Settings sharedInstance] getStringByName:@"register_email_not_valid"]
                                                            delegate:nil
                                                   cancelButtonTitle:[[Settings sharedInstance] getStringByName:@"register_email_not_valid_cancel"]
                                                   otherButtonTitles:nil];
        [alertView show];
        return;
    }

    if ([self.passwordTextField.text length] < 6) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil
                                                             message:[[Settings sharedInstance] getStringByName:@"register_password_not_valid"]
                                                            delegate:nil
                                                   cancelButtonTitle:[[Settings sharedInstance] getStringByName:@"register_password_not_valid_cancel"]
                                                   otherButtonTitles:nil];
        [alertView show];
        return;

    }

    UIWindow *tempKeyboardWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    self.hud=[[MBProgressHUD alloc] initWithWindow:tempKeyboardWindow];
    self.hud.mode=MBProgressHUDModeIndeterminate;
    [tempKeyboardWindow addSubview:self.hud];
    [self.hud show:YES];

    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://mymentorapp.com/api/"]];

    User *user = [[Settings sharedInstance] loadUserFromCoreData];

    NSString *currentLanguage = nil;
    if ([[Settings sharedInstance].currentLanguage isEqualToString:@"he_il"])
        currentLanguage = @"he-IL";
    else
        currentLanguage = @"en-US";


    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_4)
    {
        systemVersion = [systemVersion substringWithRange:NSMakeRange(0, 2)];
    }
    else
    {
        systemVersion = [systemVersion substringWithRange:NSMakeRange(0, 1)];
    }


    NSDictionary *params = @{@"UserName" : self.usernameTextField.text,
                             @"Password" : self.passwordTextField.text,
                             @"CultureName" : currentLanguage,
                             @"WorldContentTypeId" : user.contentWorldId,
                             @"OperatingSystem": [NSString stringWithFormat:@"iOS%@", systemVersion],
                             @"SoftwareVersion": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                             @"DeviceId":[[Settings sharedInstance] deviceIdentifier]};

    NSMutableURLRequest* request = [client requestWithMethod:@"POST" path:@"accountapi" parameters:params];
//    [request setValue:@"" forHTTPHeaderField:@"Accept-Language"];
    __weak RegistarationViewController *weakSelf = self;

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {


        if (operation.responseData) {
            NSError *error = nil;
            NSDictionary *data = [NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:&error];
            if (data) {
                if ([data[@"Code"] boolValue])
                {
                    [self loginToParse];
                }
                else
                {
                    [weakSelf.hud hide:YES];
                    if ([data[@"MesaageCode"] isEqualToString:@"IPHONE_STRING_SIGN_UP_USERNAME_TAKEN_ERROR"])
                    {
                        // username exist
                        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                             message:[[Settings sharedInstance] getStringByName:@"register_user_exist"]
                                                                            delegate:weakSelf
                                                                   cancelButtonTitle:[[Settings sharedInstance] getStringByName:@"register_user_exist_cancel"]
                                                                   otherButtonTitles:nil];
                        [alertView show];

                    }
                    else if ([data[@"MesaageCode"] isEqualToString:@"IPHONE_STRING_SIGN_UP_GENERAL_ERROR"])
                    {
                        // general message
                        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                             message:[[Settings sharedInstance] getStringByName:@"register_general_error"]
                                                                            delegate:weakSelf
                                                                   cancelButtonTitle:[[Settings sharedInstance] getStringByName:@"register_general_error_cancel"]
                                                                   otherButtonTitles:nil];
                        [alertView show];
                    }
                }
            }
        }
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        [weakSelf.hud hide:YES];
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil
                                                             message:[[Settings sharedInstance] getStringByName:@"register_general_error"]
                                                            delegate:weakSelf
                                                   cancelButtonTitle:[[Settings sharedInstance] getStringByName:@"register_general_error_cancel"]
                                                   otherButtonTitles:nil];
        [alertView show];

    }];
    [operation start];
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
    [self.hud hide:YES];
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

- (void)loginToParse
{
    __weak RegistarationViewController *weakSelf = self;
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text
                                 password:self.passwordTextField.text
                                    block:^(PFUser *user, NSError *error)
    {
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
                if ([userStatus[@"status"] isEqualToString:@"app"])
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

- (void)closeView
{
    SWRevealViewController *revealController = [self revealViewController];
    MMNavigationController *navController = (MMNavigationController*)revealController.frontViewController;

    dispatch_async(dispatch_get_main_queue(), ^{
        [navController exchangeRootViewController:0];
        [revealController revealToggle:nil];
        [self.navigationController popViewControllerAnimated:NO];
    });
}

- (IBAction)registerButtonDidPress:(id)sender
{
    // check if username + password + language not empty
    [self registerUser];
}

- (IBAction)cancelButtonDidPress:(id)sender
{

}
@end

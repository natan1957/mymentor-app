//
//  AppSetupViewController.m
//  MyMentorV2
//
//  Created by Walter Yaron on 5/3/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import "AppSetupViewController.h"
#import "Settings.h"
#import "User.h"
#import "FirstViewController.h"
#import "TermsViewController.h"
#import "AppDelegate.h"
#import "ContentWorld.h"
#import "MBProgressHUD.h"


@interface AppSetupViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *contentWorldImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (strong, nonatomic) ContentWorld *contentWorld;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (assign, nonatomic) BOOL internetActive;

@end

@implementation AppSetupViewController

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self performSelector:@selector(checkForInternet) withObject:nil afterDelay:1.f];
}

- (void)showImageViewFromContentWorld
{
    [self.activityView stopAnimating];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *directory = self.contentWorld.worldId;
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:directory];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"splash.jpg"];
    self.contentWorldImageView.image = [UIImage imageWithContentsOfFile:imagePath];
    self.contentWorldImageView.alpha = 0.f;
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.contentWorldImageView.alpha = 1.f;
    }];
    [self performSelector:@selector(gotoMainController) withObject:nil afterDelay:1.f];
}

- (void)gotoMainController
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    SWRevealViewController *revealViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RevealViewController"];
    appDelegate.window.rootViewController = revealViewController;
    [appDelegate.window makeKeyAndVisible];
}

- (void)gotoFirstViewController
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    FirstViewController *firstViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstViewController"];
    firstViewController.delegate = appDelegate;
    appDelegate.window.rootViewController = firstViewController;
    [appDelegate.window makeKeyAndVisible];
}

- (void)gotoTermsViewController
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    TermsViewController *termsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsViewController"];
    termsViewController.delegate = (id)appDelegate;
    appDelegate.window.rootViewController = termsViewController;
    [appDelegate.window makeKeyAndVisible];
}

- (void)checkForInternet
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.internetActive = appDelegate.internetActive;
//    if (!appDelegate.internetActive)
//    {
//        NSString *message;
//        if ([[Settings sharedInstance].currentLanguage isEqualToString:@"he_il"])
//            message = @"אין אינטרנט. כדי לגשת לנתונים, יש לבטל את מצב טיסה או להפעיל רשת אינטרנט אלחוטי";
//        else
//            message = @"No internet. Turn off Airplane Mode of use Wi-Fi to access data";
//
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
//                                                            message:message
//                                                           delegate:self
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//        [alertView show];
//    }
//    else
//    {
        [self updateFlow];
//    }
}

- (void)checkForTemrs
{
    BOOL termsApproved = [[NSUserDefaults standardUserDefaults] boolForKey:kTermsApproved];
    if (termsApproved)
    {

        self.contentWorld = [[Settings sharedInstance] loadContentWorldFromCoreData];
        if (self.contentWorld)
            [self showImageViewFromContentWorld];
        else
            [self gotoFirstViewController];
    }
    else
    {
        [self gotoFirstViewController];
    }
}

- (void)updateFlow
{
    [Settings sharedInstance];
    // check if there is an internet connection
    if (!self.internetActive)
    {
        [self checkForTemrs];
        return;
    }
    [[Settings sharedInstance] loadSettingsFromServer];
    User *localUser = [[Settings sharedInstance] loadUserFromCoreData];
    PFUser *user = [PFUser currentUser];
    [user fetch];

    if ([user isAuthenticated])
    {
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


        NSString *deviceIdentifier = user[@"deviceIdentifier"];
        if (![[Settings sharedInstance].deviceIdentifier isEqualToString:deviceIdentifier])
        {
            [Settings deleteUser];
            [Settings deleteContentWorlds];
            [Settings deleteClips];
            [Settings deleteAllUserFiles];
            [PFUser logOut];
            [self gotoFirstViewController];
            return;
        }

        NSComparisonResult result = [user.updatedAt compare:localUser.updateAt];
        if (result != NSOrderedSame)
        {
            if (![localUser.contentWorldId isEqualToString:user[@"contentType"]])
            {
                [[Settings sharedInstance] saveContentWorldToCoreData:user[@"contentType"] save:NO];

            }

            PFObject *adminData = user[@"adminData"];
            [adminData fetch];
            PFObject *group = adminData[@"group"];

            if (![localUser.groupId isEqualToString:group.objectId])
            {
                [[Settings sharedInstance] saveUserToCoreData];
            }
        }
        self.contentWorld = [[Settings sharedInstance] loadContentWorldFromCoreData];
        if (self.contentWorld)
        {
            [self showImageViewFromContentWorld];
        }
        else
        {
            [self gotoFirstViewController];
        }
    }
    else
    {
        [self checkForTemrs];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self performSelector:@selector(checkForInternet) withObject:nil afterDelay:1.6f];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

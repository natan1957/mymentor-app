//
//  TermsViewController.m
//  MyMentorV2
//
//  Created by Walter Yaron on 12/29/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import "TermsViewController.h"
#import "Settings.h"
#import "YHRoundBorderedButton.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface TermsViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *termsTextView;
@property (weak, nonatomic) YHRoundBorderedButton *approveButton;
@property (weak, nonatomic) YHRoundBorderedButton *notApproveButton;
@property (strong, nonatomic) MBProgressHUD *hud;

- (IBAction)approveButtonDidPressed:(id)sender;
- (IBAction)notApproveButtonDidPressed:(id)sender;

@end

@implementation TermsViewController

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 4000)
    {
        [UIView animateWithDuration:2.f animations:^{
            self.view.alpha = 0.f;
        } completion:^(BOOL finished) {
            exit(1);
        }];
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

- (void)moveToNextStep
{
    if ([self.delegate respondsToSelector:@selector(userDidApprove)])
    {
        [self.delegate userDidApprove];
    }
}

- (void)loadStrings
{
    [self.notApproveButton setTitleColor:[UIColor colorWithRed:25.f/255.f green:148.f/255.f blue:250.f/255.f alpha:1.f] forState:UIControlStateNormal];
    self.termsTextView.editable = YES;
//    self.termsTextView.selectable = YES;
    self.termsTextView.font = [UIFont systemFontOfSize:17.f];
    self.termsTextView.text = [[Settings sharedInstance] getStringByName:@"termsandcondition_info"];
    self.termsTextView.editable = NO;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.termsTextView.selectable = NO;
    }
    [self.approveButton setTitle:[[Settings sharedInstance] getStringByName:@"termsandcondition_approve"] forState:UIControlStateNormal];
    [self.notApproveButton setTitle:[[Settings sharedInstance] getStringByName:@"termsandcondition_cancel"] forState:UIControlStateNormal];
}

- (void)checkForInternet
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.internetActive)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:[[Settings sharedInstance] getStringByName:@"nointernetfound"]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        [self moveToNextStep];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadStrings];
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

- (IBAction)approveButtonDidPressed:(id)sender
{
    [self checkForInternet];
}

- (IBAction)notApproveButtonDidPressed:(id)sender
{
    [Settings deleteUser];
    [Settings deleteAllUserFiles];
    [Settings deleteContentWorlds];
    [self.notApproveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
//    {
//        __weak TermsViewController *weakSelf = self;
//        UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"" message:[self getStringByID:4] preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//                [UIView animateWithDuration:2.f animations:^{
//                    weakSelf.view.alpha = 0.f;
//                } completion:^(BOOL finished) {
//                    exit(1);
//                }];
//        }];
//        [alertViewController addAction:okAction];
//        [self presentViewController:alertViewController animated:YES completion:nil];
//    }
//    else
//    {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[[Settings sharedInstance] getStringByName:@"termsandcondition_description"]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    alertView.tag = 4000;
    [alertView show];
//    }
}
@end

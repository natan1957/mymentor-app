//
//  AppSettingsViewController.m
//  MyMentorV2
//
//  Created by Walter Yaron on 4/26/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import <Parse/Parse.h>
#import "AppSettingsViewController.h"
#import "AppSettingsTableViewController.h"
#import "Settings.h"
#import "MMNavigationController.h"
#import "AppDelegate.h"
#import "VoicePrompts.h"
#import "AppSettings.h"
#import "MBProgressHUD.h"
#import "SwitchUserViewController.h"
#import "RESwitch.h"
#import "RNFrostedSidebar.h"
#import "User.h"
#import "YHRoundBorderedButton.h"

@interface AppSettingsViewController () <   UIPickerViewDataSource,
                                            UIPickerViewDelegate,
                                            RNFrostedSidebarDelegate>

@property (weak, nonatomic) IBOutlet UIView *appSettingsPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIImageView *worldContentImageView;
@property (weak, nonatomic) IBOutlet YHRoundBorderedButton *cancelButton;
@property (weak, nonatomic) IBOutlet YHRoundBorderedButton *doneButton;
@property (strong, nonatomic) NSString *currentLanguage;
@property (strong, nonatomic) NSArray *localPrompts;
@property (strong, nonatomic) NSMutableArray *contentWorlds;
@property (strong, nonatomic) RNFrostedSidebar *sideBar;
@property (assign, nonatomic) PickerViewType pickerViewType;
@property (strong, nonatomic) User *user;

- (IBAction)pickerViewDoneButtonClicked:(id)sender;
- (IBAction)pickerViewCancelButtonClicked:(id)sender;
- (IBAction)menuButtonClicked:(id)sender;

@end

@implementation AppSettingsViewController

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

#pragma mark - UIPickerViewDataSource

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 44.f;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.pickerViewDataSource count];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = self.pickerViewDataSource[row];
    NSAttributedString *attString;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    }
    else
    {
        attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    }

    return attString;
}

- (void)showPickerView
{
    static BOOL showAnimationActive = NO;
    [self.pickerView reloadAllComponents];
    if (!showAnimationActive)
    {
        showAnimationActive = YES;
        self.shadowView.hidden = NO;
        [UIView animateWithDuration:0.4f
                         animations:^
         {
             self.shadowView.alpha = 0.8f;
             self.appSettingsPickerView.frame = CGRectOffset(self.appSettingsPickerView.frame, 0.f, -180.f);
         }
                         completion:^(BOOL finished)
         {
             showAnimationActive = NO;
         }];
    }
}

- (void)hidePickerView
{
    static BOOL hideAnimationActive = NO;

    if (!hideAnimationActive)
    {
        hideAnimationActive = YES;
        [UIView animateWithDuration:0.4f
                         animations:^
         {
              self.shadowView.alpha = 0.0f;
              self.appSettingsPickerView.frame = CGRectOffset(self.appSettingsPickerView.frame, 0.f, 180.f);
         }
                         completion:^(BOOL finished)
         {
             //        self.settingsPickerView.frame = CGRectMake(0.f, 0.f, 0.f, 0.f);
             hideAnimationActive = NO;
             self.shadowView.hidden = YES;
         }];
    }
}

- (void)loadInterfaceDataSource
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[[Settings sharedInstance] getStringByName:@"appsettings_changeinterfacelanguagetext"]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)loadContentWorlds
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.internetActive)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:[[Settings sharedInstance] getStringByName:@"nointernetfound"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.contentWorlds removeAllObjects];
    [self.pickerViewDataSource removeAllObjects];
    self.pickerViewType = PickerViewTypeContentWorlds;
    PFQuery *query = [PFQuery queryWithClassName:@"WorldContentType"];
    if (![self.user.admin boolValue] || !self.user)
    {
        [query whereKey:@"status" equalTo:@"Active"];
    }
    if (self.user.contentTester)
    {
        PFQuery *query1 = [PFQuery queryWithClassName:@"WorldContentType"];
        [query1 whereKey:@"objectId" equalTo:self.user.contentTester];
        query = [PFQuery orQueryWithSubqueries:@[query,query1]];
    }

    __weak AppSettingsViewController *weakSelf = self;
    __block NSInteger selectedRow = 0;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             [objects enumerateObjectsUsingBlock:^(PFObject *obj, NSUInteger idx, BOOL *stop)
              {
                  [weakSelf.contentWorlds addObject:obj];
                  if ([obj.objectId isEqualToString:[Settings sharedInstance].appSettingsContentWorldId])
                  {
                      selectedRow = idx;
                  }
                  if ([weakSelf.currentLanguage isEqualToString:@"he_il"])
                  {
                      [weakSelf.pickerViewDataSource addObject:obj[@"value_he_il"]];
                  }
                  else
                  {
                      [weakSelf.pickerViewDataSource addObject:obj[@"value_en_us"]];
                  }
              }];
             [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
             [weakSelf showPickerView];
             [weakSelf.pickerView selectRow:selectedRow inComponent:0 animated:NO];
         }
     }];
}

- (void)loadReplayLessonDataSource
{
    [self.pickerViewDataSource removeAllObjects];
    [self.pickerViewDataSource addObjectsFromArray:@[[[Settings sharedInstance] getStringByName:@"lessonsettings_listentome"],
                                                     [[Settings sharedInstance] getStringByName:@"lessonsettings_listentous_step1"],
                                                     [[Settings sharedInstance] getStringByName:@"lessonsettings_listentomeagain"],
                                                     [[Settings sharedInstance] getStringByName:@"lessonsettings_nowyou_step1"]]];
    self.pickerViewType = PickerViewTypeReplayLesson;
    [self showPickerView];
    [self.pickerView selectRow:[Settings sharedInstance].appSettingsReplayLessonIndex inComponent:0 animated:NO];
}

- (void)loadSwitchUserView
{
    SwitchUserViewController *switchUserViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SwitchUserViewController"];
    [self.navigationController pushViewController:switchUserViewController animated:YES];
}

- (void)setupMenu
{
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

- (void)updateTexts
{
    self.title = [[Settings sharedInstance] getStringByName:@"appsettings_title"];
    Settings *localSettings = [Settings sharedInstance];
    self.currentLanguage = [localSettings currentLanguage];
}

- (void)setupView
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePickerView)];
    [self.shadowView addGestureRecognizer:tapGesture];
    self.managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];

    self.pickerViewDataSource = [[NSMutableArray alloc] initWithCapacity:1];
    self.contentWorlds = [[NSMutableArray alloc] initWithCapacity:1];
    [self.cancelButton setTitle:[[Settings sharedInstance] getStringByName:@"appsettings_cancel"] forState:UIControlStateNormal];
    [self.doneButton setTitle:[[Settings sharedInstance] getStringByName:@"appsettings_okay"] forState:UIControlStateNormal];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.title = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateTexts];
    [self setupMenu];
    self.user = [[Settings sharedInstance] loadUserFromCoreData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showWorldContentImage
{
    [Settings deleteClips];
    [Settings deleteAllUserFiles];
    NSInteger selectedRow = [self.pickerView selectedRowInComponent:0];
    PFObject *obj = self.contentWorlds[selectedRow];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *directory = obj.objectId;
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:directory];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"splash.jpg"];
    self.worldContentImageView.image = [UIImage imageWithContentsOfFile:imagePath];
    self.worldContentImageView.hidden = NO;
    [self performSelector:@selector(showMainList) withObject:nil afterDelay:1.f];
}

- (void)showMainList
{
    self.worldContentImageView.hidden = YES;
    MMNavigationController *navController = (MMNavigationController*)self.navigationController;
    [navController exchangeRootViewController:0];
}

- (IBAction)pickerViewDoneButtonClicked:(id)sender
{
    AppSettingsTableViewController *tableViewController = (AppSettingsTableViewController*)self.childViewControllers[0];
    switch (self.pickerViewType)
    {
        case PickerViewTypeReplayLesson:
        {
            NSInteger selectedRow = [self.pickerView selectedRowInComponent:0];
            [Settings sharedInstance].appSettingsReplayLessonIndex = selectedRow;
            [[Settings sharedInstance] saveAppSettingsToCoreData];
            [tableViewController updateView];
            [self hidePickerView];
            break;
        }
        case PickerViewTypeContentWorlds:
        {
            NSInteger selectedRow = [self.pickerView selectedRowInComponent:0];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.parentViewController.view animated:YES];
            __weak AppSettingsViewController *weakSelf = self;
            [hud showAnimated:YES
          whileExecutingBlock:^{
              [[Settings sharedInstance] saveContentWorldToCoreData:weakSelf.contentWorlds[selectedRow] save:YES];
            }
              completionBlock:^{
                  [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateLessonsListAfterAction
                                                                      object:nil
                                                                    userInfo:nil];

                  [tableViewController updateView];
                  [weakSelf showWorldContentImage];
                  [weakSelf hidePickerView];
            }];
            break;
        }
        default:
            break;
    }
}

- (IBAction)pickerViewCancelButtonClicked:(id)sender
{
    [self hidePickerView];
}

- (IBAction)menuButtonClicked:(id)sender
{
    [self.sideBar show:2];
}

@end

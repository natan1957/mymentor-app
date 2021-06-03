//
//  AppSettingsTableViewController.m
//  MyMentorV2
//
//  Created by Walter Yaron on 4/26/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import "AppSettingsTableViewController.h"
#import "AppSettingsViewController.h"
#import "MMNavigationController.h"
#import "ContentWorld.h"
#import "AppDelegate.h"
#import "Settings.h"
#import "RESwitch.h"
#import "User.h"

@interface AppSettingsTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *appSettingsCurrentWorldContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *appSettingsArrowDirectionTypeButton;
@property (weak, nonatomic) IBOutlet UISwitch *appSettingsShowHighlightedWordsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *appSettingsNaturalLanguageSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *appSettingsPlayTypeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *appSettingsRepeatLessonStartFromLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *changeUserTableViewCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *appSettingsSaveUserAudioSegmentedControl;
@property (weak, nonatomic) IBOutlet UITableViewCell *saveUserAudioTableViewCell;
@property (weak, nonatomic) IBOutlet UILabel *showHighlightedWordsLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *productionTableViewCell;
@property (weak, nonatomic) IBOutlet UILabel *arrowDirectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *lessonStartFromLabel;
@property (weak, nonatomic) IBOutlet UILabel *worldContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *showNaturalLanguageLabel;
@property (weak, nonatomic) IBOutlet UILabel *changeInterfaceLanguageLabel;
@property (weak, nonatomic) IBOutlet UILabel *uninterruptedPlayLabel;
@property (weak, nonatomic) IBOutlet UILabel *audioSaveLabel;
@property (weak, nonatomic) IBOutlet UILabel *switchUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *environmentLabel;
@property (weak, nonatomic) IBOutlet UISwitch *environmentSwitch;

@property (weak, nonatomic) RESwitch *reswitch1_1;
@property (weak, nonatomic) RESwitch *reswitch1_2;
@property (weak, nonatomic) RESwitch *reswitch1_3;

- (IBAction)appSettingsArrowDirectionValueChanged:(id)sender;
- (IBAction)appSettingsShowHighlightedWordsValueChanged:(UISwitch*)sender;
- (IBAction)appSettingsNaturalLanguageValueChanged:(id)sender;
- (IBAction)appSettingsPlayTypeValueChanged:(id)sender;
- (IBAction)appSettingsSaveUserAudio:(id)sender;
- (IBAction)changeEnvironmentButtonValueChanged:(id)sender;

@end

@implementation AppSettingsTableViewController

#pragma mark - Table view data source

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.row == 0) || (indexPath.row == 1) || (indexPath.row == 4) || (indexPath.row == 6) || (indexPath.row == 7))
    {
        return NO;
    }
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.changeUserTableViewCell.hidden)
    {
        if (indexPath.row == 8)
        {
            return 0;
        }
    }

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AppSettingsViewController *parentView = (AppSettingsViewController*)self.parentViewController;
    switch (indexPath.row)
    {
        case 2:
            [parentView loadReplayLessonDataSource];
            break;
        case 3:
            [parentView loadContentWorlds];
            break;
        case 4:
            break;
        case 5:
            [parentView loadInterfaceDataSource];
            break;
        case 8:
            [parentView loadSwitchUserView];
            break;

        default:
            break;
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadCurrentContentWorldName
{
    AppSettingsViewController *parentView = (AppSettingsViewController*)self.parentViewController;
    NSError *error = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ContentWorld"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"worldId == %@", [Settings sharedInstance].appSettingsContentWorldId];
    [request setPredicate:predicate];
    [request setFetchLimit:1];
    NSArray *data = [parentView.managedObjectContext executeFetchRequest:request error:&error];
    if ([data count])
    {
        ContentWorld *contentWorld = data[0];

        if ([[Settings sharedInstance].currentLanguage isEqual:@"he_il"])
        {
            self.appSettingsCurrentWorldContentLabel.text = contentWorld.name_he_il;
        }
        else
        {
            self.appSettingsCurrentWorldContentLabel.text = contentWorld.name_en_us;
        }
    }
}

- (void)updateTexts
{
    AppSettingsViewController *parentView = (AppSettingsViewController*)self.parentViewController;
    [parentView updateTexts];
    self.showHighlightedWordsLabel.text = [[Settings sharedInstance] getStringByName:@"appsettings_showhighlightedwords"];
    self.arrowDirectionLabel.text = [[Settings sharedInstance] getStringByName:@"appsettings_arrowdirection"];
    self.lessonStartFromLabel.text = [[Settings sharedInstance] getStringByName:@"appsettings_lessonstartfrom"];
    self.worldContentLabel.text = [[Settings sharedInstance] getStringByName:@"appsettings_worldcontent"];
    self.showNaturalLanguageLabel.text = [[Settings sharedInstance] getStringByName:@"appsettings_shownaturallanguage"];
    self.changeInterfaceLanguageLabel.text = [[Settings sharedInstance] getStringByName:@"appsettings_changeinterfacelanguage"];
    self.audioSaveLabel.text = [[Settings sharedInstance] getStringByName:@"appsettings_saveuseraudio"];
    self.switchUserLabel.text = [[Settings sharedInstance] getStringByName:@"appsettings_switchuser"];

    [self loadCurrentContentWorldName];
    switch ([Settings sharedInstance].appSettingsReplayLessonIndex)
    {
        case StepType1:
            self.appSettingsRepeatLessonStartFromLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_listentome"];
            break;
        case StepType2:
            self.appSettingsRepeatLessonStartFromLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_listentous_step1"];
            break;
        case StepType3:
            self.appSettingsRepeatLessonStartFromLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_listentomeagain"];
            break;
        case StepType4:
            self.appSettingsRepeatLessonStartFromLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_nowyou_step1"];
            break;
        default:
            break;
    }
}

- (void)updateLog
{
    PFObject *log = [PFObject objectWithClassName:@"LogFile"];
    log[@"action"] = @"Logout";
    log[@"userName"] = [PFUser currentUser].username;
    log[@"appVersion"] = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    log[@"deviceID"] = [Settings sharedInstance].deviceIdentifier;
    log[@"sysVersion"] = [NSString stringWithFormat:@"iOS%@",[[UIDevice currentDevice] systemVersion]];
    log[@"system"] = @"App";
    log[@"time"] = [NSDate date];

    [log saveInBackground];
}

- (void)logoutUser
{
    [Settings deleteClips];
    [Settings deleteContentWorlds];
    [Settings deleteAllUserFiles];
    [Settings deleteUser];
    [[PFUser currentUser] removeObjectForKey:@"deviceIdentifier"];
    [[PFUser currentUser] save];
    [PFUser logOut];
}

- (void)setupView
{
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.appSettingsShowHighlightedWordsSwitch.layer.cornerRadius = 16.f;
    self.appSettingsNaturalLanguageSwitch.layer.cornerRadius = 16.f;
    self.appSettingsPlayTypeSwitch.layer.cornerRadius = 16.f;
    self.environmentSwitch.layer.cornerRadius = 16.f;

    if ([[UIScreen mainScreen] bounds].size.height == 480.f)
    {
        [self.tableView setContentInset:UIEdgeInsetsMake(0.,0.,280.,0)];
        self.tableView.showsHorizontalScrollIndicator = YES;
    }


    [self performSelector:@selector(appSettingsSaveUserAudio:) withObject:self.appSettingsSaveUserAudioSegmentedControl afterDelay:0.005f];

    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
    }
    else
    {
        RESwitch *switch1;
        if ([[Settings sharedInstance].appSettingsOldLanguage isEqual:@"en_us"])
            switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(247.f, 12.f, 61.f, 26.f)];
        else
            switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(10.f, 12.f, 61.f, 26.f)];

        self.appSettingsShowHighlightedWordsSwitch.hidden = YES;
        [self.view addSubview:switch1];
        self.reswitch1_1 = switch1;
        [self.reswitch1_1 addTarget:self action:@selector(appSettingsShowHighlightedWordsValueChanged:) forControlEvents:UIControlEventValueChanged];

        if ([[Settings sharedInstance].appSettingsOldLanguage isEqual:@"en_us"])
            switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(247.f, 186.f, 61.f, 26.f)];
        else
            switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(10.f, 186.f, 61.f, 26.f)];

        self.appSettingsNaturalLanguageSwitch.hidden = YES;
        [self.view addSubview:switch1];
        self.reswitch1_2 = switch1;
        [self.reswitch1_2 addTarget:self action:@selector(appSettingsNaturalLanguageValueChanged:) forControlEvents:UIControlEventValueChanged];

        if ([[Settings sharedInstance].appSettingsOldLanguage isEqual:@"en_us"])
            switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(247.f, 274.f, 61.f, 26.f)];
        else
            switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(10.f, 274.f, 61.f, 26.f)];

        self.appSettingsPlayTypeSwitch.hidden = YES;
        [self.view addSubview:switch1];
        self.reswitch1_3 = switch1;
        [self.reswitch1_3 addTarget:self action:@selector(appSettingsPlayTypeValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
}

- (void)updateView
{
    [self updateTexts];
    if ([Settings sharedInstance].appSettingsShowHighlightedWords == ShowHighlightedWordsTypeShow)
    {
        self.appSettingsShowHighlightedWordsSwitch.on = YES;
        self.reswitch1_1.on = YES;
    }
    else
    {
        self.appSettingsShowHighlightedWordsSwitch.on = NO;
        self.reswitch1_1.on = NO;
    }

    if ([Settings sharedInstance].appSettingsNaturalLanguage)
    {
        self.appSettingsNaturalLanguageSwitch.on = YES;
        self.reswitch1_2.on = YES;
    }
    else
    {
        self.appSettingsNaturalLanguageSwitch.on = NO;
        self.reswitch1_2.on = NO;
    }

    if ([Settings sharedInstance].environmentProduction)
    {
        self.environmentLabel.text = @"Production";
        self.environmentSwitch.on = YES;
    }
    else
    {
        self.environmentLabel.text = @"Test";
        self.environmentSwitch.on = NO;
    }

    if ([Settings sharedInstance].appSettingsPlayType)
    {
        self.appSettingsPlayTypeSwitch.on = NO;
        self.reswitch1_3.on = NO;
       self.uninterruptedPlayLabel.text = [[Settings sharedInstance] getStringByName:@"appsettings_uninterruptedplay"];
    }
    else
    {
        self.appSettingsPlayTypeSwitch.on = YES;
        self.reswitch1_3.on = YES;
        self.uninterruptedPlayLabel.text =  [[Settings sharedInstance] getStringByName:@"appsettings_uninterruptedplaynotactive"];
    }

    if ([Settings sharedInstance].appSettingsSaveUserAudio)
    {
        self.appSettingsSaveUserAudioSegmentedControl.selectedSegmentIndex = 1;
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        {
            [self.appSettingsSaveUserAudioSegmentedControl setTintColor:[UIColor greenColor]];
        }
        else
        {
            [[self.appSettingsSaveUserAudioSegmentedControl.subviews objectAtIndex:0] setTintColor:[UIColor greenColor]];
            [[self.appSettingsSaveUserAudioSegmentedControl.subviews objectAtIndex:1] setTintColor:[UIColor whiteColor]];
        }
        self.audioSaveLabel.text = [[Settings sharedInstance] getStringByName:@"appsettings_saveuseraudio"];
    }
    else
    {
        self.appSettingsSaveUserAudioSegmentedControl.selectedSegmentIndex = 0;
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        {
            [self.appSettingsSaveUserAudioSegmentedControl setTintColor:[UIColor greenColor]];
        }
        else
        {
            [[self.appSettingsSaveUserAudioSegmentedControl.subviews objectAtIndex:1] setTintColor:[UIColor greenColor]];
            [[self.appSettingsSaveUserAudioSegmentedControl.subviews objectAtIndex:0] setTintColor:[UIColor whiteColor]];
        }
        self.audioSaveLabel.text = [[Settings sharedInstance] getStringByName:@"appsettings_saveteacheranduser"];
    }

    if ([Settings sharedInstance].appSettingsArrowDirectionType == ArrowDirectionTypeRight)
        [self.appSettingsArrowDirectionTypeButton setImage:[UIImage imageNamed:@"playToRight.png"] forState:UIControlStateNormal];
    else
        [self.appSettingsArrowDirectionTypeButton setImage:[UIImage imageNamed:@"playToLeft.png"] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![[PFUser currentUser] isAuthenticated])
    {
        self.changeUserTableViewCell.hidden = YES;
    }
    else
    {
        self.changeUserTableViewCell.hidden = NO;
    }

    User *localUser = [[Settings sharedInstance] loadUserFromCoreData];
    if (!localUser.changeEnvironment)
    {
        self.productionTableViewCell.hidden = YES;
    }
    else
    {
        self.productionTableViewCell.hidden = NO;
    }
    [self updateView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)appSettingsArrowDirectionValueChanged:(id)sender
{
    if ([Settings sharedInstance].appSettingsArrowDirectionType == ArrowDirectionTypeRight)
    {
        [Settings sharedInstance].appSettingsArrowDirectionType = ArrowDirectionTypeLeft;
    }
    else
    {
        [Settings sharedInstance].appSettingsArrowDirectionType = ArrowDirectionTypeRight;
    }

//    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateLessonsListAfterArrowChange
//                                                        object:nil
//                                                      userInfo:nil];

    [self updateView];
    [[Settings sharedInstance] saveAppSettingsToCoreData];
}

- (IBAction)appSettingsShowHighlightedWordsValueChanged:(UISwitch*)sender
{
    if (sender.on)
    {
        [Settings sharedInstance].appSettingsShowHighlightedWords = ShowHighlightedWordsTypeShow;
    }
    else
    {
        [Settings sharedInstance].appSettingsShowHighlightedWords = ShowHighlightedWordsTypeDontShow;
    }
    [[Settings sharedInstance] saveAppSettingsToCoreData];
}

- (IBAction)appSettingsNaturalLanguageValueChanged:(UISwitch*)sender
{
    if (sender.on)
    {
        [Settings sharedInstance].appSettingsNaturalLanguage = YES;
    }
    else
    {
        [Settings sharedInstance].appSettingsNaturalLanguage = NO;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateLessonsListAfterAction
                                                        object:nil
                                                      userInfo:nil];
    [self updateTexts];
    [[Settings sharedInstance] saveAppSettingsToCoreData];
}

- (IBAction)appSettingsPlayTypeValueChanged:(UISwitch*)sender
{
    if (sender.on)
    {
        [Settings sharedInstance].appSettingsPlayType = PlayTypeInterrupted;
        self.uninterruptedPlayLabel.text =  [[Settings sharedInstance] getStringByName:@"lessonsettings_uninterruptedplaynotactive"];

    }
    else
    {
        [Settings sharedInstance].appSettingsPlayType = PlayTypeUninterrupted;
        self.uninterruptedPlayLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_uninterruptedplay"];
    }

    [[Settings sharedInstance] saveAppSettingsToCoreData];
}

- (IBAction)appSettingsSaveUserAudio:(id)sender
{
    UISegmentedControl *control = sender;
    if (control.selectedSegmentIndex)
    {
        [Settings sharedInstance].appSettingsSaveUserAudio = YES;
    }
    else
    {
        [Settings sharedInstance].appSettingsSaveUserAudio = NO;
    }

    [self updateView];
    [[Settings sharedInstance] saveAppSettingsToCoreData];
}

- (IBAction)changeEnvironmentButtonValueChanged:(UISwitch*)sender
{
    [self updateLog];
    [Settings sharedInstance].environmentProduction = !sender.isOn;
    [[Settings sharedInstance] saveAppSettingsToCoreData];
    [self logoutUser];
//    [self updateView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        abort();
    });

}
@end

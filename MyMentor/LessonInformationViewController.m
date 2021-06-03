//
//  LessonInformationViewController.m
//  MyMentorV2
//
//  Created by Walter Yaron on 12/28/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>
#import <Parse/Parse.h>
#import "LessonInformationViewController.h"
#import "Clip.h"
#import "DownloadMMN.h"
#import "FFCircularProgressView.h"
#import "Defines.h"
#import "PlayerViewController.h"
#import "LessonInformationRecordingTableViewCell.h"
#import "AFSoundManager.h"
#import "Settings.h"
#import "DownloadVoicePrompts.h"
#import "MBProgressHUD.h"
#import "LessonSettingsViewController.h"
#import "Lesson.h"
#import "MMNavigationController.h"
#import "RESwitch.h"
#import "LessonAdvanceTableViewController.h"
#import "CocoaSecurity.h"
#import "FirstViewController.h"
#import "AppDelegate.h"

const CGFloat kBackgroundParallexFactor = 0.5f;
const CGFloat kBlurFadeInFactor = 0.005f;
const CGFloat kTextFadeOutFactor = 0.05f;
const CGFloat kCommentCellHeight = 50.0f;

#define OPEN YES
#define CLOSE NO


@interface LessonInformationViewController ()  <LessonInformationRecordingDelegate,
                                                MFMailComposeViewControllerDelegate,
                                                UIAlertViewDelegate,
                                                AFSoundManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lessonNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lessonDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *lessonVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *lessonTeacherNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *lessonStatusButton;
@property (weak, nonatomic) IBOutlet FFCircularProgressView *progressView;
@property (weak, nonatomic) IBOutlet UISwitch *lessonLockedStatusSwitch;
@property (weak, nonatomic) IBOutlet UISlider *lessonFileRecordingSlider;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *advanceButton;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIView *lessonInfoContainer;
@property (weak, nonatomic) IBOutlet UIView *tableViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *lessonNameTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lessonDescriptionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lessonTeacherNameTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lessonVersionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lessonIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *lessonIdTitleLabel;
@property (weak, nonatomic) RESwitch *reswitch1_1;
@property (weak, nonatomic) IBOutlet UILabel *lessonDurationTitleLabel;
@property (strong, nonatomic) DownloadMMN *localDownload;
@property (weak, nonatomic) IBOutlet UILabel *lessonDurationLabel;
@property (strong, nonatomic) Lesson *lesson;
@property (weak, nonatomic) IBOutlet UILabel *deleteTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lessonStatusTitleLabel;
@property (strong, nonatomic) Clip *clip;
@property (strong, nonatomic) SWRevealViewController *childController;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) NSMutableArray *userAudioFiles;
@property (strong, nonatomic) AFSoundManager *player;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) UIImageView *arrowImage1;
@property (strong, nonatomic) UIImageView *arrowImage2;
@property (copy, nonatomic) NSIndexPath *lastSelectedIndexPath;
@property (assign, nonatomic) NSInteger lessonStatus;
@property (assign, nonatomic) BOOL internetActive;
@property (assign, nonatomic) BOOL menuOpen;
@property (assign, nonatomic) BOOL state;

- (IBAction)lessonStatusButtonTouchUpInside:(id)sender;
- (IBAction)lessonFileRecordingSliderValueChanged:(UISlider*)sender;
- (IBAction)lessonLockedStatusValueChanged:(id)sender;
- (IBAction)shareLessonFileRecordingButtonClicked:(id)sender;
- (IBAction)favoriteButtonTouchUpInside:(id)sender;
- (IBAction)lessonSettingsButtonTouchUpInside:(id)sender;
- (IBAction)changeStateButtonDidClicked:(id)sender;

@end

@implementation LessonInformationViewController

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 1000)
        return;

    CGFloat delta = 0.0f;
    CGRect rect = CGRectMake(0.f, 0.f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    if (scrollView.contentOffset.y <= 0.0f) {
        delta = fabs(MIN(0.0f, _mainScrollView.contentOffset.y));
        _lessonInfoContainer.frame = CGRectMake(0.f, CGRectGetMinY(rect) - delta, CGRectGetWidth(rect) + delta, CGRectGetHeight(rect) + delta);
        [_tableView setContentOffset:(CGPoint){0,0} animated:NO];
        self.state = CLOSE;
    } else {
        delta = _mainScrollView.contentOffset.y;
        CGFloat backgroundScrollViewLimit = CGRectGetHeight(self.tableViewContainer.frame) - 60.f;
        if (delta >= backgroundScrollViewLimit) {
            _tableView.contentOffset = CGPointZero;
            _lessonInfoContainer.frame = CGRectMake(0.f, delta, 320.f, CGRectGetHeight(_lessonInfoContainer.frame));
            self.state = OPEN;
        }
        else {
            _lessonInfoContainer.frame = CGRectMake(0.f, delta, 320.f, CGRectGetHeight(_lessonInfoContainer.frame));
            _tableView.contentOffset = CGPointZero;
        }
    }
}

// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0)
{
    if  (scrollView.tag == 1000)
        return;


    CGFloat backgroundScrollViewLimit = CGRectGetHeight(self.tableViewContainer.frame) -60.f;

    if (self.state == OPEN)
    {
        if  (targetContentOffset->y < backgroundScrollViewLimit)
        {
            *targetContentOffset = CGPointZero;
        }
        else
        {
            *targetContentOffset = CGPointMake(0.f, CGRectGetMinY(self.tableViewContainer.frame));
        }
    }
    else
    {
        if  (targetContentOffset->y > 100.f)
        {
            *targetContentOffset = CGPointMake(0.f, CGRectGetMinY(self.tableViewContainer.frame));
        }
        else
        {
            *targetContentOffset = CGPointZero;
        }
    }
}


- (void)setState:(BOOL)state
{
    _state = state;
    if (state == OPEN)
    {
        self.arrowImage1.transform = CGAffineTransformMakeRotation(DegreeToRadian(-90));
        self.arrowImage2.transform = CGAffineTransformMakeRotation(DegreeToRadian(-90));
    }
    else
    {
        self.arrowImage1.transform = CGAffineTransformMakeRotation(DegreeToRadian(90));
        self.arrowImage2.transform = CGAffineTransformMakeRotation(DegreeToRadian(90));
    }
}

#pragma mark - UIALertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 5000)
    {
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
        [Settings sharedInstance].lessonUpdate = YES;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma AFSoundManager

- (void)soundManagerProgress:(NSInteger)percentage
{
    self.lessonFileRecordingSlider.value = percentage * 0.01;
    if (percentage == 100)
    {
        LessonInformationRecordingTableViewCell *cell = (LessonInformationRecordingTableViewCell*)[self.tableView cellForRowAtIndexPath:self.lastSelectedIndexPath];
        [self updatePlayButton:cell.lessonFileRecordingActionButton];

        self.lessonFileRecordingSlider.value = 0.f;
        cell.lessonFileRecordingPlaying = NO;
    }
}

#pragma mark - MFMailCompose Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    controller.mailComposeDelegate = nil;
    [self dismissViewControllerAnimated:YES completion:nil];

    //	switch (result)
    //	{
    //		case MFMailComposeResultSent:
    //			[self sendDidFinish];
    //			break;
    //		case MFMailComposeResultSaved:
    //			[self sendDidFinish];
    //			break;
    //		case MFMailComposeResultCancelled:
    //			[self sendDidCancel];
    //			break;
    //		case MFMailComposeResultFailed:
    //			[self sendDidFailWithError:nil];
    //			break;
    //	}
}

#pragma mark - Lesson Information Cell Delegate

- (void)lessonInformationRecordingButtonDidClicked:(NSIndexPath*)indexPath
{
    LessonInformationRecordingTableViewCell *cell;
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];

    if ((self.lastSelectedIndexPath != indexPath) && self.lastSelectedIndexPath)
    {
        cell = (LessonInformationRecordingTableViewCell*)[self.tableView cellForRowAtIndexPath:self.lastSelectedIndexPath];

        if (cell.lessonFileRecordingPlaying)
        {
            [self.player stop];
            self.lessonFileRecordingSlider.value = 0.f;
            cell.lessonFileRecordingPlaying = NO;
            [self updatePlayButton:cell.lessonFileRecordingActionButton];
        }
        else
        {
            self.lessonFileRecordingSlider.value = 0.f;
        }
    }

    cell = (LessonInformationRecordingTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];

    if (cell.lessonFileRecordingActionButton.tag != DELETEBUTTON)
    {
        if (!cell.lessonFileRecordingPlaying)
        {
            NSDictionary *data = self.userAudioFiles[indexPath.row];
            NSString *fileURLString = data[@"fileURL"];

            if (self.lessonFileRecordingSlider.value != 0)
            {
                [self.player resume];
            }
            else
            {
    //        self.lessonFileRecordingSlider.value = 0.f;
                [self.player startPlayingLocalFileWithName:[NSURL fileURLWithPath:fileURLString]];
            }
            self.lastSelectedIndexPath = indexPath;
            cell.lessonFileRecordingPlaying = YES;
            [cell.lessonFileRecordingActionButton setImage:[UIImage imageNamed:@"btn_CellStop-copy_normal.png"] forState:UIControlStateNormal]; // pause
        }
        else
        {
            [self.player pause];
    //        self.lessonFileRecordingSlider.value = 0.f;
            cell.lessonFileRecordingPlaying = NO;
            [self updatePlayButton:cell.lessonFileRecordingActionButton];
        }
    }
    else
    {
        [self deleteLocalFile:indexPath];
    }
}

#pragma mark - UITableView Datasource

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 22.f)];
    [headerView setBackgroundColor:[UIColor colorWithRed:241.f/255.f green:241.f/255.f blue:241.f/255.f alpha:1.f]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.f, 16.f, 240.f, 22.f)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.f];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.text = [[Settings sharedInstance] getStringByName:@"lessondetails_myrecording"];
    titleLabel.textAlignment = NSTextAlignmentCenter;

    [headerView addSubview:titleLabel];

    self.arrowImage1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Arrow.png"]];
    self.arrowImage1.frame = CGRectMake(5.f, 5.f, 40.f, 40.f);
    [headerView addSubview:self.arrowImage1];

    self.arrowImage2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Arrow.png"]];
    self.arrowImage2.frame = CGRectMake(275.f, 5.f, 40.f, 40.f);
    [headerView addSubview:self.arrowImage2];

    self.arrowImage1.transform = CGAffineTransformMakeRotation(DegreeToRadian(90));
    self.arrowImage2.transform = CGAffineTransformMakeRotation(DegreeToRadian(90));


    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.userAudioFiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LessonInformationRecordingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LessonInformationRecordingCellIdentifier" forIndexPath:indexPath];
    NSDictionary *data = self.userAudioFiles[indexPath.row];

    cell.lessonFileRecordingSizeLabel.text = [NSByteCountFormatter stringFromByteCount:[data[@"fileSize"] longLongValue] countStyle:NSByteCountFormatterCountStyleFile];
    cell.lessonFileRecordingNameLabel.text = data[@"fileName"];
    if ([data[@"type"] integerValue] == DELETEBUTTON)
    {
        [cell.lessonFileRecordingActionButton setImage:[UIImage imageNamed:@"btn_CellDelete_normal.png"] forState:UIControlStateNormal];
        cell.lessonFileRecordingActionButton.tag = DELETEBUTTON;
    }
    else
    {
        [self updatePlayButton:cell.lessonFileRecordingActionButton];
        cell.lessonFileRecordingActionButton.tag = PLAYBUTTON;
    }

    cell.lessonFileRecordingDateLabel.text = [self.formatter stringFromDate:data[@"fileCreationDate"]];
    if ([[Settings sharedInstance].currentLanguage isEqualToString:@"he_il"])
        cell.lessonFileRecordingDurationLabel.text = [NSString stringWithFormat:@"%llu שניות",[data[@"fileDuration"] longLongValue]];
    else
        cell.lessonFileRecordingDurationLabel.text = [NSString stringWithFormat:@"%llu sec",[data[@"fileDuration"] longLongValue]];

    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LessonInformationRecordingTableViewCell *cell = (LessonInformationRecordingTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
//    [lesson setObject:@(ClipDelete) forKey:@"status"];
    NSMutableDictionary *data = self.userAudioFiles[indexPath.row];
    if ([data[@"type"] isEqual:@(PLAYBUTTON)])
    {
        [cell.lessonFileRecordingActionButton setImage:[UIImage imageNamed:@"btn_CellDelete_normal.png"] forState:UIControlStateNormal];
        cell.lessonFileRecordingActionButton.tag = DELETEBUTTON;
        data[@"type"] = @(DELETEBUTTON);
    }
    else
    {
        [self updatePlayButton:cell.lessonFileRecordingActionButton];
        cell.lessonFileRecordingActionButton.tag = PLAYBUTTON;
        data[@"type"] = @(PLAYBUTTON);
    }

    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LessonInformationRecordingTableViewCell *cell = (LessonInformationRecordingTableViewCell*)[self.tableView cellForRowAtIndexPath:self.lastSelectedIndexPath];

    if (cell.lessonFileRecordingActionButton.tag == PLAYBUTTON)
    {
        if (self.lastSelectedIndexPath != indexPath)
        {
            [self updatePlayButton:cell.lessonFileRecordingActionButton];

            if ([self.player isPlaying])
            {
                [self.player pause];
                self.lessonFileRecordingSlider.value = 0.f;
                cell.lessonFileRecordingPlaying = NO;
            }
        }
    }
    self.lastSelectedIndexPath = indexPath;
}

- (void)updateLessonStatus:(NSDictionary*)lessonData
{
    PFObject *lesson = [PFObject objectWithoutDataWithClassName:@"Purchases" objectId:lessonData[@"purchaseId"]];

    if (![lessonData[@"lessonDemo"] boolValue])
    {
        [lesson setObject:@"Lesson_is_active" forKey:@"purchaseStatusCode"];
    }
    else
    {
        [lesson setObject:@"Demo_is_active" forKey:@"purchaseStatusCode"];
    }
    [lesson saveInBackground];
}

- (void)deleteLocalFile:(NSIndexPath*)indexPath
{
    NSDictionary *data = self.userAudioFiles[indexPath.row];

    NSString *identifier = data[@"fileURL"];

    NSError *error = nil;

    NSFileManager *manager = [[NSFileManager alloc] init];
    if ([manager fileExistsAtPath:identifier])
    {
        [manager removeItemAtPath:identifier error:&error];
        if (!error)
        {
            [self.userAudioFiles removeObjectAtIndex:indexPath.row];
            [self.tableView reloadData];
        }
        else
        {
            NSLog(@"%@",[error localizedDescription]);
        }
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

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserverForName:kInternetStatusChanged
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note)
     {
         self.internetActive = [note.object boolValue];
     }];
}

- (void)closeViewController:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)loadClipFromCoreData
{
    NSDictionary *data = self.lessonClip[@"data"];
    NSString *identifier = data[@"identifier"];

    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Clip"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@",identifier];
    [request setPredicate:predicate];
    [request setFetchLimit:1];

    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if ([array count])
    {
        self.clip = array[0];
    }
}

- (void)updateName:(NSString*)name andDescription:(NSString*)description andTeacher:(NSString*)teacherName
{
    self.lessonNameLabel.text = name;

    CGFloat height;

    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        CGRect rect = [name boundingRectWithSize:CGSizeMake(300.f, 300.f)
                                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                     attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:14.f]}
                                                        context:nil];
        height = rect.size.height;
    }
    else
    {
        CGSize size = [name sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14] constrainedToSize:CGSizeMake(300., 300.f)];
        height = size.height;
    }

    self.lessonNameLabel.frame = CGRectMake(self.lessonNameLabel.frame.origin.x,self.lessonNameLabel.frame.origin.y,300.f,height);

    self.lessonDescriptionLabel.text = description;

    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        CGRect rect = [description boundingRectWithSize:CGSizeMake(300.f, 300.f)
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:14.f]}
                                         context:nil];
        height = rect.size.height;

    }
    else
    {
        CGSize size = [description sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14] constrainedToSize:CGSizeMake(300., 300.f)];
        height = size.height;
    }

    self.lessonDescriptionLabel.frame = CGRectMake(self.lessonDescriptionLabel.frame.origin.x,self.lessonDescriptionLabel.frame.origin.y,300.f,height);
    self.lessonTeacherNameLabel.text = teacherName;
}

- (void)updateTexts
{
    NSDictionary *data = self.lessonClip[@"data"];
    NSString *identifier = data[@"identifier"];

    self.deleteTitleLabel.text = [[Settings sharedInstance] getStringByName:@"lessondetails_delete"];
    self.favoriteTitleLabel.text = [[Settings sharedInstance] getStringByName:@"lessondetails_favorite"];
    self.lessonStatusTitleLabel.text = [[Settings sharedInstance] getStringByName:@"lessondetails_lessonstatus"];
    self.lessonNameTitleLabel.text = [[Settings sharedInstance] getStringByName:@"lessondetails_lessonname"];
    self.lessonDescriptionTitleLabel.text = [[Settings sharedInstance] getStringByName:@"lessondetails_descriptionname"];
    self.lessonTeacherNameTitleLabel.text = [[Settings sharedInstance] getStringByName:@"lessondetails_teachertitle"];
    self.lessonDurationTitleLabel.text = [[Settings sharedInstance] getStringByName:@"lessondetails_durationtitle"];
    self.lessonVersionTitleLabel.text = [[Settings sharedInstance] getStringByName:@"lessondetails_versiontitle"];
    self.lessonIdTitleLabel.text = [[Settings sharedInstance] getStringByName:@"lessondetails_lessonidtitle"];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MMM-dd HH:mm"];
    self.lessonVersionLabel.text = [NSString stringWithFormat:@"%@   %@",data[@"version"],[formatter stringFromDate:data[@"updatedAt"]]];
    NSString *duration = data[@"lessonDuration"];
    self.lessonDurationLabel.text = [duration substringToIndex:8];
    self.lessonIdLabel.text = [NSString stringWithFormat:@"%@/%@",data[@"purchaseId"],data[@"lessonId"]];

    [self checkForAudioFiles:identifier];
    [self updatePlayButton:self.lessonStatusButton];

    if ([[Settings sharedInstance].currentLanguage isEqualToString:@"he_il"])
    {
        if (![Settings sharedInstance].appSettingsNaturalLanguage)
        {
            [self updateName:data[@"name_he_il"] andDescription:data[@"lessonDescription_he_il"] andTeacher:data[@"performer_he_il"] ? data[@"performer_he_il"] : data[@"teacherName_he_il"]];
        }
        else
        {
            [self updateName:data[@"name_en_us"] andDescription:data[@"lessonDescription_en_us"] andTeacher:data[@"performer_en_us"] ? data[@"performer_en_us"] : data[@"teacherName_en_us"]];
        }
    }
    else if ([[Settings sharedInstance].currentLanguage isEqualToString:@"en_us"])
    {
        if (![Settings sharedInstance].appSettingsNaturalLanguage)
        {
            [self updateName:data[@"name_en_us"] andDescription:data[@"lessonDescription_en_us"] andTeacher:data[@"performer_en_us"] ? data[@"performer_en_us"] : data[@"teacherName_en_us"]];
        }
        else
        {
            [self updateName:data[@"name_he_il"] andDescription:data[@"lessonDescription_he_il"] andTeacher:data[@"performer_he_il"] ? data[@"performer_he_il"] : data[@"teacherName_he_il"]];
        }
    }
}

- (void)updatePlayButton:(UIButton*)button
{
    if (self.clip)
    {
        if ([self.clip.arrowDirectionType integerValue] == ArrowDirectionTypeLeft)
            [button setImage:[UIImage imageNamed:@"btn_CellPlay_Fliped.png"] forState:UIControlStateNormal];

        else
            [button setImage:[UIImage imageNamed:@"btn_CellPlay_normal.png"] forState:UIControlStateNormal];
    }
}

- (void)setupView
{
    self.internetActive = YES;
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    [self.tableView setContentInset:UIEdgeInsetsMake(0.f, 0.f, 44.f, 0.f)];
    self.lessonLockedStatusSwitch.layer.cornerRadius = 16.0;
    self.player = [[AFSoundManager alloc] init];
    self.player.delegate = self;
    self.userAudioFiles = [[NSMutableArray alloc] initWithCapacity:1];

//    _mainScrollView.alwaysBounceVertical = YES;
    _mainScrollView.bounces = NO;
    _mainScrollView.showsVerticalScrollIndicator = NO;
//    _mainScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(kBarHeight, 0, 0, 0);

    CGFloat height = 504.f;

    if ([[UIScreen mainScreen] bounds].size.height == 480.f)
    {
        height = 416.f;
    }
    if ([[UIScreen mainScreen] bounds].size.height == 568.f)
    {
        height = 504.f;
//        height = 416.f;
    }

    CGRect rect = self.tableViewContainer.frame;
    rect.origin.y = height - 60.f;
    self.tableViewContainer.frame = rect;
    self.mainScrollView.contentSize = CGSizeMake(32.0f, (CGRectGetMinY(self.tableViewContainer.frame)*2.)+60.f);

    UIImage *backImage;
    if ([self.navigationController.viewControllers[0] isKindOfClass:[FavoriteViewController class]])
    {
        backImage = [UIImage imageNamed:@"btn_HeaderFav_selected.png"];
    }
    else
    {
        backImage = [UIImage imageNamed:@"btn_HeaderMenu_normal.png"];
    }

    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(closeViewController:)];
    }
    else
    {
        UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(closeViewController:)];
        self.navigationItem.leftBarButtonItem = back;
        RESwitch *switch1;
        if ([[Settings sharedInstance].appSettingsOldLanguage isEqual:@"he_il"])
            switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(250.f, 14.f, 61.f, 26.f)];
        else
            switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(10.f, 14.f, 61.f, 26.f)];
        switch1.tag = 10;
        self.lessonLockedStatusSwitch.hidden = YES;
        [self.lessonInfoContainer addSubview:switch1];
        self.reswitch1_1 = switch1;
        [self.reswitch1_1 addTarget:self action:@selector(lessonLockedStatusValueChanged:) forControlEvents:UIControlEventValueChanged];
    }

    [self loadClipFromCoreData];

    if (self.clip)
    {
        self.favoriteButton.enabled = YES;
        self.lessonLockedStatusSwitch.enabled = YES;
        [self updateFavoriteButton];
        [self updateLockButton];
        NSDictionary *data = self.lessonClip[@"data"];
        NSDate *serverDate = data[@"updatedByMyMentor"];
        NSDate *currentDate = self.clip.updatedByMyMentor;

        NSComparisonResult result = [currentDate compare:serverDate];
        if (result == NSOrderedSame)
        {

            [self updatePlayButton:self.lessonStatusButton];
            self.lessonStatus = PLAYBUTTON;
        }
        else
        {
            [self.lessonStatusButton setImage:[UIImage imageNamed:@"btn_CellReload_normal.png"] forState:UIControlStateNormal];
            self.lessonStatus = UPDATEBUTTON;
        }
    }
    else
    {
        [self.lessonStatusButton setImage:[UIImage imageNamed:@"btn_CellDownload_normal.png"] forState:UIControlStateNormal];
        self.lessonStatus = DOWNLOADBUTTON;
        self.advanceButton.enabled = NO;
    }
}

-(void) updateClipToCoreData
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        NSDictionary *data = self.lessonClip[@"data"];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Clip" inManagedObjectContext:[self managedObjectContext]];
        [request setEntity:entity];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", data[@"identifier"]];
        [request setPredicate:predicate];

        NSError *error;
        NSArray *array = [[self managedObjectContext] executeFetchRequest:request error:&error];
        if (array != nil)
        {
            NSUInteger count = [array count]; // May be 0 if the object has been deleted.
            if (count)
            {
                [array enumerateObjectsUsingBlock:^(Clip *obj, NSUInteger idx, BOOL *stop)
                {
                    [obj updateClipToCoreData:data];
                    NSError *error = nil;
                    [[self managedObjectContext] save:&error];
                    if (error)
                    {
                        NSLog(@"%@",error.description);
                    }
                }];
            }
            //
            [Settings sharedInstance].lessonUpdate = YES;
        }
        else
        {
            // Deal with error.
        }
        [self updateView];
    });
}

-(void) saveNewClipToCoreData
{
    NSMutableDictionary *data = self.lessonClip[@"data"];
    data[@"arrowDirectionType"] = @([Settings sharedInstance].appSettingsArrowDirectionType);
    NSManagedObjectContext *context = [self managedObjectContext];
    Clip *clipDB = [NSEntityDescription insertNewObjectForEntityForName:@"Clip" inManagedObjectContext:context];
    [clipDB saveNewClipToCoreData:data];
    NSError *error = nil;
    [context save:&error];
    if (error)
    {
        NSLog(@"%@",error.description);
    }

    [Settings sharedInstance].lessonUpdate = YES;
    [self updateView];
}

- (void)updateView
{
    self.favoriteButton.enabled = YES;
    self.lessonLockedStatusSwitch.enabled = YES;
    [self updateFavoriteButton];
    [self updateLockButton];
    self.advanceButton.enabled = YES;
    [self loadClipFromCoreData];
}

- (void)performAction
{
    NSDictionary *data = self.lessonClip[@"data"];
    BOOL hasVoicePrompts = data[@"voicePrompts"] != nil;

    self.localDownload = [[DownloadMMN alloc] init];
    __weak LessonInformationViewController *weakSelf = self;
    self.progressView.hidden = NO;
    [self.localDownload setDownloadProgressBlock:^(long long totalBytesRead, long long totalBytesExpectedToRead)
     {
         float currentProgress = ((float)totalBytesRead) / totalBytesExpectedToRead;
         if (hasVoicePrompts)
             currentProgress /= 2;

         weakSelf.progressView.progress = currentProgress;
     }];

    [self.localDownload downloadWithFilename:data[@"fileName"] andURL:data[@"fileURL"] withSuccess:^(BOOL done)
     {
         if (hasVoicePrompts)
         {
             [weakSelf downloadVoicePrompts];
         }
         else
         {
             if (weakSelf.lessonStatus == DOWNLOADBUTTON)
             {
                 [weakSelf saveNewClipToCoreData];
             }
             if (weakSelf.lessonStatus == UPDATEBUTTON)
             {
                 [weakSelf updateClipToCoreData];
             }
             [weakSelf updatePlayButton:weakSelf.lessonStatusButton];
             [weakSelf updateLessonStatus:data];
             weakSelf.progressView.hidden = YES;
             weakSelf.lessonStatus = PLAYBUTTON;
         }
     }
                       withFailure:^(NSError *error)
     {
         
     }];
}

- (void)downloadVoicePrompts
{
    NSMutableDictionary *data = self.lessonClip[@"data"];

    DownloadVoicePrompts *downloadPrompts = [[DownloadVoicePrompts alloc] init];

    __weak LessonInformationViewController *weakSelf = self;

    //    [cell showProgressBar];

    PFObject *voicePrompts = data[@"voicePrompts"];

    [downloadPrompts downloadVoicePrompts:voicePrompts
                            progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations)
     {
         float currentProgress = ((float)numberOfFinishedOperations) / totalNumberOfOperations;
         currentProgress /= 2;
         weakSelf.progressView.progress = currentProgress + 0.5f;
     }
                          completionBlock:^(BOOL done)
     {
         if (done)
         {

             [[Settings sharedInstance] saveVoicePromptsToCoreData:voicePrompts];
             if (weakSelf.lessonStatus == DOWNLOADBUTTON)
             {
                 [weakSelf saveNewClipToCoreData];
             }
             if (weakSelf.lessonStatus == UPDATEBUTTON)
             {
                 [weakSelf updateClipToCoreData];
             }
             [weakSelf updatePlayButton:weakSelf.lessonStatusButton];
             [weakSelf updateLessonStatus:data];
             weakSelf.lessonStatus = PLAYBUTTON;
             weakSelf.progressView.hidden = YES;
         }
     }];
}

- (void)updateLockButton
{
    if ([self.clip.locked boolValue])
    {
        self.lessonLockedStatusSwitch.on = YES;
        self.reswitch1_1.on = YES;
    }
    else
    {
        self.lessonLockedStatusSwitch.on = NO;
        self.reswitch1_1.on = NO;
    }
}

- (void)updateFavoriteButton
{
    if ([self.clip.favorite boolValue])
    {
        [self.favoriteButton setImage:[UIImage imageNamed:@"btn_blue_HeaderFav_selected.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.favoriteButton setImage:[UIImage imageNamed:@"btn_blue_HeaderFav_normal.png"] forState:UIControlStateNormal];
    }
}

- (void)showAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[[Settings sharedInstance] getStringByName:@"nointernetfound"]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (BOOL)checkResult:(OSStatus)result operation:(const char *)operation
{
	if (result == noErr) return NO;
	char errorString[20];
	// see if it appears to be a 4-char-code
	*(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(result);
	if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4]))
    {
		errorString[0] = errorString[5] = '\'';
		errorString[6] = '\0';
	}
    else
		// no, format it as an integer
		sprintf(errorString, "%d", (int)result);

	fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
    return YES;
}

- (void)checkForAudioFiles:(NSString*)lessonName
{
    [self.userAudioFiles removeAllObjects];
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSFileManager *manager = [[NSFileManager alloc] init];
    NSArray *contents = [manager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    for (NSString* item in contents)
    {
        if ([item rangeOfString:lessonName].location == 0)
        {
            if ([[item pathExtension] isEqualToString:@"m4a"])
            {
                error = nil;
                ExtAudioFileRef             _audioFile;

                NSURL *fileURL = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:item]];

                CFURLRef _sourceURL = CFBridgingRetain(fileURL);
                if ([self checkResult:ExtAudioFileOpenURL(_sourceURL,&_audioFile)
                        operation:"Failed to open audio file for reading"])
                {
                    break;
                }

                AudioStreamBasicDescription _fileFormat;
                UInt32 size = sizeof(_fileFormat);

                [self checkResult:ExtAudioFileGetProperty(_audioFile,kExtAudioFileProperty_FileDataFormat, &size, &_fileFormat)
                           operation:"Failed to get audio stream basic description of input file"];

                Float32                     _totalDuration;
                SInt64                      _totalFrames;

                size = sizeof(_totalFrames);
                [self checkResult:ExtAudioFileGetProperty(_audioFile,kExtAudioFileProperty_FileLengthFrames, &size, &_totalFrames)
                           operation:"Failed to get total frames of input file"];
                _totalFrames = MAX(1, _totalFrames);

                // Total duration
                _totalDuration = _totalFrames / _fileFormat.mSampleRate;

                NSDictionary *fileAttributes = [manager attributesOfItemAtPath:[documentsDirectory stringByAppendingPathComponent:item] error:&error];

                NSString *fileCreationDate = fileAttributes[@"NSFileCreationDate"];
                NSNumber *fileSize = fileAttributes[@"NSFileSize"];
                NSString *filename = [item stringByDeletingPathExtension];

                NSUInteger sectionNumber,sentenceNumber,paragtaphNumber;

                StepType stepType = [[filename substringWithRange:NSMakeRange([filename length]-1, 1)] integerValue]-1;
                ItemType itemType = [[filename substringWithRange:NSMakeRange([filename length]-2, 1)] integerValue];
                sectionNumber = [[filename substringWithRange:NSMakeRange([filename length]-3, 1)] integerValue]+1;
                sentenceNumber = [[filename substringWithRange:NSMakeRange([filename length]-4, 1)] integerValue]+1;
                paragtaphNumber = [[filename substringWithRange:NSMakeRange([filename length]-5, 1)] integerValue]+1;

                NSString *fileNameToShow = @"";
                NSArray *nameArray;
                NSString *studentName = @"";
                NSString *teacherName = @"";
                NSArray *teacherNameArray;

                if ([[Settings sharedInstance].currentLanguage isEqualToString:@"he_il"])
                {
                    nameArray = [self.clip.name_he_il componentsSeparatedByString:@","];
                    studentName = @"תלמיד";
                    switch (stepType)
                    {
                        case StepType2:
                            teacherNameArray = [self.clip.teacherName_he_il componentsSeparatedByString:@" "];
                            if ([teacherNameArray count])
                            {
                                teacherName = [NSString stringWithFormat:@"+%@",teacherNameArray[0]];
                            }
                            else
                            {
                                teacherName = @"והמורה+";
                            }
                            break;
                        case StepType4:
                            
                        default:
                            break;
                    }

                    if ([[PFUser currentUser] isAuthenticated])
                    {
                        studentName = [NSString stringWithFormat:@"%@%@",[PFUser currentUser][@"firstName_he_il"],teacherName];
                    }
                    else
                    {
                        studentName = [NSString stringWithFormat:@"%@%@",studentName,teacherName];
                    }

                    switch (itemType)
                    {
                        case ItemTypeSection:
                        {
                            fileNameToShow = [NSString stringWithFormat:@"%ld.%ld.%ld",(unsigned long)paragtaphNumber,(unsigned long)sentenceNumber,(unsigned long)sectionNumber];
                            break;
                        }
                        case ItemTypeSentences:
                        {
                            fileNameToShow = [NSString stringWithFormat:@"%ld.%ld",(unsigned long)paragtaphNumber,(unsigned long)sentenceNumber];
                            break;
                        }
                        case ItemTypeParagraph:
                        {
                            fileNameToShow = [NSString stringWithFormat:@"%ld",(unsigned long)paragtaphNumber];
                            break;
                        }
                        case ItemTypeChapter:
                        {
//                                fileNameToShow = [NSString stringWithFormat:@"%@ כל השיעור",stepString];
                            break;
                        }
                        default:
                            break;
                    }
                }
                else
                {
                    nameArray = [self.clip.name_en_us componentsSeparatedByString:@", "];
                    studentName = @"student";
                    switch (stepType)
                    {
                        case StepType2:
                        {
                            teacherNameArray = [self.clip.teacherName_en_us componentsSeparatedByString:@" "];
                            if ([teacherNameArray count])
                            {
                                teacherName = [NSString stringWithFormat:@"+%@",teacherNameArray[0]];
                            }
                            else
                            {
                                teacherName = @"+and teacher";
                            }

                            break;
                        }
                        case StepType4:

                        default:
                            break;
                    }

                    if ([[PFUser currentUser] isAuthenticated])
                    {
                        studentName = [NSString stringWithFormat:@"%@%@",[PFUser currentUser][@"firstName_en_us"],teacherName];
                    }
                    else
                    {
                        studentName = [NSString stringWithFormat:@"%@%@",studentName,teacherName];
                    }

                    switch (itemType)
                    {
                        case ItemTypeSection:
                        {
                            fileNameToShow = [NSString stringWithFormat:@"%ld.%ld.%ld",(unsigned long)paragtaphNumber,(unsigned long)sentenceNumber,(unsigned long)sectionNumber];
                            break;
                        }
                        case ItemTypeSentences:
                        {
                            fileNameToShow = [NSString stringWithFormat:@"%ld.%ld",(unsigned long)paragtaphNumber,(unsigned long)sentenceNumber];
                            break;
                        }
                        case ItemTypeParagraph:
                        {
                            fileNameToShow = [NSString stringWithFormat:@"%ld",(unsigned long)paragtaphNumber];
                            break;
                        }
                        case ItemTypeChapter:
                        {
//                                fileNameToShow = [NSString stringWithFormat:@"%@ all lesson",stepString];
                            break;
                        }
                        default:
                            break;
                    }
                }

//                NSString *nameToShow = [NSString stringWithFormat:@"%@,%@,%@,%@",
//                                        [nameArray[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
//                                        [nameArray[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
//                                        studentName,
//                                        fileNameToShow];

                NSString *nameToShow = [NSString stringWithFormat:@"%@",
                                        [nameArray[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];


                NSMutableDictionary *data = [@{@"fileSize" : fileSize,
                                       @"fileCreationDate" : fileCreationDate,
                                       @"fileDuration" : @(_totalDuration),
                                       @"fileName" : nameToShow,
                                       @"fileURL" : [documentsDirectory stringByAppendingPathComponent:item],
                                       @"type" : @(PLAYBUTTON)} mutableCopy];
                [self.userAudioFiles addObject:data];
            }
        }
    }

    self.userAudioFiles = [[self.userAudioFiles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
    {
         NSDate *lesson1 = obj1[@"fileCreationDate"];
         NSDate *lesson2 = obj2[@"fileCreationDate"];

         if ([lesson1 compare:lesson2] == NSOrderedAscending)
             return NSOrderedDescending;

         if ([lesson1 compare:lesson2] == NSOrderedDescending)
             return NSOrderedAscending;

         return NSOrderedSame;

    }] mutableCopy];

    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.player stop];
    self.lessonFileRecordingSlider.value = 0.f;
    [self.localDownload cancelDownload];
    self.localDownload = nil;
    self.title = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateTexts];
    self.title = [[Settings sharedInstance] getStringByName:@"lessondetails_title"];
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

- (IBAction)backButtonDidPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)favoriteButtonTouchUpInside:(id)sender
{
    self.clip.favorite = @(![self.clip.favorite boolValue]);
    [self updateFavoriteButton];
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }

    [Settings sharedInstance].lessonUpdate = YES;
}

- (IBAction)lessonSettingsButtonTouchUpInside:(id)sender
{
    SWRevealViewController *revealViewController = self.revealViewController;

    if (!self.menuOpen)
    {
        UINavigationController *navController1 = [self.storyboard instantiateViewControllerWithIdentifier:@"LessonSettingsStoryBoardIdentifier"];
        LessonSettingsViewController *lessonSettingViewController = (LessonSettingsViewController*)navController1.viewControllers[0];

        UINavigationController *navController2 = [self.storyboard instantiateViewControllerWithIdentifier:@"LessonAdvanceSettingsStoryBoardIdentifier"];
        LessonAdvanceTableViewController *lessonAdvanceTableSettings = (LessonAdvanceTableViewController*)navController2.viewControllers[0];

        self.childController = [[SWRevealViewController alloc] init];
        self.childController.frontViewController = navController1;
        self.childController.rightViewController = navController2;
        revealViewController.rightViewController = self.childController;

        lessonSettingViewController.clip = self.clip;
        lessonAdvanceTableSettings.clip = self.clip;
        self.menuOpen = YES;
        self.view.userInteractionEnabled = NO;
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
        {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }

        [self.revealViewController rightRevealToggle:nil];
    }
    else
    {
        UINavigationController *navController = (UINavigationController*)self.childController.frontViewController;
        LessonSettingsViewController *lessonSettingViewController = (LessonSettingsViewController*)navController.viewControllers[0];
        [lessonSettingViewController updateLessonSettingsToCoreData];
        self.childController = nil;
        self.menuOpen = NO;
        self.view.userInteractionEnabled = YES;
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
        {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
        [self updateTexts];
        [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
    }
}

- (IBAction)changeStateButtonDidClicked:(id)sender
{
    if (_state == OPEN) {
        [self.mainScrollView setContentOffset:CGPointZero animated:YES];
    }
    else
    {
        [self.mainScrollView setContentOffset:CGPointMake(0.f, CGRectGetMinY(self.tableViewContainer.frame)) animated:YES];
    }
}

- (void)showPlayerView
{
    PlayerViewController *playerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayerViewController"];
    NSDictionary *data = self.lessonClip[@"data"];
    playerViewController.fileName = data[@"identifier"];
    playerViewController.lessonName = data[@"name"];
    playerViewController.lessonDictionary = data;
    playerViewController.managedObjectContext = self.managedObjectContext;
    if (self.HUD)
    {
        [self.HUD hide:YES];
    }

    [self.navigationController pushViewController:playerViewController animated:YES];
}

-(void)deleteDataAndShowMessage:(NSString*)message
{
    [Settings deleteAllUserFiles];
    [Settings deleteClips];
    [Settings deleteUser];
    [Settings deleteContentWorlds];
    [PFUser logOut];
    [self.HUD hide:YES];

    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil
                                                         message:message
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    alertView.tag = 5000;
    [alertView show];
}

- (IBAction)lessonStatusButtonTouchUpInside:(id)sender
{
    switch (self.lessonStatus)
    {
        case PLAYBUTTON:
        {
            self.HUD = nil;
            if ([[PFUser currentUser] isAuthenticated])
            {
                self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                __weak LessonInformationViewController *weakSelf = self;
                [self.HUD show:YES];
                [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error)
                 {
                     PFUser *currentUser =  [PFUser currentUser];
                     PFObject *adminData = currentUser[@"adminData"];
                     [adminData fetch];
                     PFObject *userStatus = adminData[@"userStatus"];
                     [userStatus fetch];

                     if (!([userStatus[@"status"] isEqualToString:@"active"]) && !([userStatus[@"status"] isEqualToString:@"checking"]) && !([userStatus[@"status"] isEqualToString:@"app"]))
                     {
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

                         [weakSelf deleteDataAndShowMessage:message];
                         return;
                     }

                     NSString *deviceIdentifier = currentUser[@"deviceIdentifier"];
                     if (![[Settings sharedInstance].deviceIdentifier isEqualToString:deviceIdentifier])
                     {
                         [weakSelf deleteDataAndShowMessage:[[Settings sharedInstance] getStringByName:@"otherusermakelogin"]];
                         return;
                     }
                     else
                     {
                         [weakSelf showPlayerView];
                     }
                 }];
            }
            else
            {
                [self showPlayerView];
            }
            break;
        }
        case UPDATEBUTTON:
        case DOWNLOADBUTTON:
        {
            if (self.internetActive)
            {
                [self performAction];
            }
            else
            {
                [self showAlert];
            }

            break;
        }
//        case DELETEBUTTON:
//        {
//            if (self.internetActive)
//            {
//                [self deleteClip:indexPath];
//            }
//            else
//            {
//                [self showAlert];
//            }
//            break;
//        }

        default:
            break;
    }
}

- (IBAction)lessonFileRecordingSliderValueChanged:(UISlider*)sender
{
//    if ([self.player isPlaying])
//    {
        [self.player moveToSection:sender.value];
//    }
}

- (IBAction)lessonLockedStatusValueChanged:(id)sender
{
    self.clip.locked = @(![self.clip.locked boolValue]);
    [self updateLockButton];
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }

    [Settings sharedInstance].lessonUpdate = YES;
}

- (IBAction)shareLessonFileRecordingButtonClicked:(id)sender
{
    if (!self.lastSelectedIndexPath)
    {
        // show message
        // need to select file to share
        return;
    }

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
	if (!mailController)
    {
        [hud hide:YES];
		// e.g. no mail account registered (will show alert)
		return;
	}
    mailController.mailComposeDelegate = self;

    NSString *tmpFileName = self.userAudioFiles[self.lastSelectedIndexPath.row][@"fileName"];
    NSString *subject = [NSString stringWithFormat:@"MyMentor-%@",tmpFileName];
    [mailController setSubject:subject];

    BOOL showEmail = [self.clip.lessonIncludingSupport boolValue];
    __weak LessonInformationViewController *weakSelf = self;

    [hud showAnimated:YES
        whileExecutingBlock:^
    {
        if (showEmail)
        {
//            PFObject *teacher = [PFObject objectWithoutDataWithClassName:@"_User" objectId:weakSelf.clip.teacherId];
//            PFQuery *query = [PFUser query];
            PFUser *teacher = [PFQuery getUserObjectWithId:weakSelf.clip.teacherId];
//            [teacher fetchIfNeeded];
            [mailController setToRecipients:@[teacher[@"email"]]];
        }

        NSString *selectedFilename = weakSelf.userAudioFiles[weakSelf.lastSelectedIndexPath.row][@"fileURL"];
        NSString *fileName = weakSelf.userAudioFiles[weakSelf.lastSelectedIndexPath.row][@"fileName"];
//        NSString *fileName = [tmpFileName stringByAppendingFormat:@" %@ %@",weakSelf.clip.category2_en_us,weakSelf.clip.category3_en_us];

        NSData *fileData = [NSData dataWithContentsOfFile:selectedFilename];
        [mailController addAttachmentData:fileData
                                 mimeType:@"audio/mp4"
                                 fileName:fileName];
        }
        completionBlock:^{
          dispatch_async(dispatch_get_main_queue(), ^{
              [weakSelf presentViewController:mailController animated:YES completion:nil];
          });
        }];
}

@end

//
//  LessonAdvanceTableViewController.m
//  MyMentorV2
//
//  Created by Walter Yaron on 7/7/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LessonAdvanceTableViewController.h"
#import "Defines.h"
#import "Settings.h"
#import "VoicePrompts.h"
#import "AppDelegate.h"
#import "RESwitch.h"

@interface LessonAdvanceTableViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *lessonSettingsShowHighlightedWords;
@property (weak, nonatomic) IBOutlet UIButton *arrowDirectionButton;
@property (weak, nonatomic) IBOutlet UILabel *lessonSettingsRepeatLessonStartFromLabel;
@property (weak, nonatomic) IBOutlet UILabel *lessonSettinsVoicePromptLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *lessonSettingsSaveAudioOptionSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *showHighlightedWordsLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrowDirectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *lessonStartFromLabel;
@property (weak, nonatomic) IBOutlet UILabel *voicePromptsLabel;
@property (weak, nonatomic) IBOutlet UILabel *saveAudioLabel;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) RESwitch *reswitch1_1;

- (IBAction)showHighlightedWordsValueChanged:(UISwitch*)sender;
- (IBAction)arrowDirectionButtonClicked:(UIButton*)sender;
- (IBAction)saveUserAudioValueChanged:(id)sender;

@end

@implementation LessonAdvanceTableViewController

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 4)
    {
        return NO;
    }
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == 1)
    {
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row)
    {
        case 2:
        {
            [self.parent loadReplayLessonDataSource];
            break;
        }
        case 3:
        {
            [self.parent loadVoicePromptsDataSource];
            break;
        }
        default:
            break;
    }
}

- (void)setupView
{
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    self.lessonSettingsShowHighlightedWords.layer.cornerRadius = 16.f;

    self.showHighlightedWordsLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_showhighlightedwords"];
    self.arrowDirectionLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_arrowdirection"];
    self.lessonStartFromLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_lessonstartfrom"];
    self.voicePromptsLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_voiceprompts"];
    self.saveAudioLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_saveuseraudio"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self performSelector:@selector(saveUserAudioValueChanged:) withObject:self.lessonSettingsSaveAudioOptionSegmentedControl afterDelay:0.005f];

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        RESwitch *switch1;
        if ([[Settings sharedInstance].appSettingsOldLanguage isEqual:@"en_us"])
            switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(254.f, 8.f, 61.f, 26.f)];
        else
            switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(54.f, 8.f, 61.f, 26.f)];

        self.lessonSettingsShowHighlightedWords.hidden = YES;
        [self.view addSubview:switch1];
        self.reswitch1_1 = switch1;
        [self.reswitch1_1 addTarget:self action:@selector(showHighlightedWordsValueChanged:) forControlEvents:UIControlEventValueChanged];
    }

    [self updateView];
}

- (void)updateView
{
    if ([self.clip.showHighlightedWords integerValue] == ShowHighlightedWordsTypeDontShow)
    {
        self.lessonSettingsShowHighlightedWords.on = NO;
        self.reswitch1_1.on = NO;
    }
    else
    {
        self.lessonSettingsShowHighlightedWords.on = YES;
        self.reswitch1_1.on = YES;
    }

    switch ([self.clip.repeatLessonStartFrom integerValue])
    {
        case StepType1:
            self.lessonSettingsRepeatLessonStartFromLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_listentome"];
            break;
        case StepType2:
            self.lessonSettingsRepeatLessonStartFromLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_listentous_step1"];
            break;
        case StepType3:
            self.lessonSettingsRepeatLessonStartFromLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_listentomeagain"];
            break;
        case StepType4:
            self.lessonSettingsRepeatLessonStartFromLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_nowyou_step1"];
            break;
        default:
            break;
    }

    self.lessonSettingsSaveAudioOptionSegmentedControl.selectedSegmentIndex = [self.clip.saveUserAudio integerValue];
    if (self.lessonSettingsSaveAudioOptionSegmentedControl.selectedSegmentIndex)
    {
        self.saveAudioLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_saveuseraudio"];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        {
            [self.lessonSettingsSaveAudioOptionSegmentedControl setTintColor:[UIColor greenColor]];
        }
        else
        {
            [[self.lessonSettingsSaveAudioOptionSegmentedControl.subviews objectAtIndex:0] setTintColor:[UIColor greenColor]];
            [[self.lessonSettingsSaveAudioOptionSegmentedControl.subviews objectAtIndex:1] setTintColor:[UIColor whiteColor]];
        }
    }
    else
    {
        self.saveAudioLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_saveteacheranduser"];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        {
            [self.lessonSettingsSaveAudioOptionSegmentedControl setTintColor:[UIColor greenColor]];
        }
        else
        {
            [[self.lessonSettingsSaveAudioOptionSegmentedControl.subviews objectAtIndex:1] setTintColor:[UIColor greenColor]];
            [[self.lessonSettingsSaveAudioOptionSegmentedControl.subviews objectAtIndex:0] setTintColor:[UIColor whiteColor]];
        }
    }

    if ([self.clip.arrowDirectionType integerValue] == ArrowDirectionTypeRight)
        [self.arrowDirectionButton setImage:[UIImage imageNamed:@"playToRight.png"] forState:UIControlStateNormal];
    else
        [self.arrowDirectionButton setImage:[UIImage imageNamed:@"playToLeft.png"] forState:UIControlStateNormal];

    NSError *error = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VoicePrompts"];

    NSArray *items = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ([items count])
    {
        [items enumerateObjectsUsingBlock:^(VoicePrompts *obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj.voiceId isEqual:self.clip.defaultVoicePromptsId])
             {
                 self.lessonSettinsVoicePromptLabel.text = obj.voiceType;
                 *stop = YES;
             }
         }];
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

- (IBAction)showHighlightedWordsValueChanged:(UISwitch*)sender
{
    if (sender.on)
    {
        self.clip.showHighlightedWords = @(ShowHighlightedWordsTypeShow);
    }
    else
    {
        self.clip.showHighlightedWords = @(ShowHighlightedWordsTypeDontShow);
    }
}

- (IBAction)arrowDirectionButtonClicked:(UIButton*)sender
{
    if ([self.clip.arrowDirectionType integerValue] == ArrowDirectionTypeLeft)
    {
        self.clip.arrowDirectionType = @(ArrowDirectionTypeRight);
    }
    else
    {
        self.clip.arrowDirectionType = @(ArrowDirectionTypeLeft);
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateNaturalLanguageUI
                                                        object:nil
                                                      userInfo:nil];
    [self updateView];
}

- (IBAction)saveUserAudioValueChanged:(id)sender
{
    UISegmentedControl *control = sender;

    if (control.selectedSegmentIndex == 1)
    {
        self.clip.saveUserAudio = @YES;
    }
    else
    {
        self.clip.saveUserAudio = @NO;
    }
    [self updateView];
}

@end

//
//  LessonAdvanceSettingsViewController.m
//  MyMentorV2
//
//  Created by Walter Yaron on 7/7/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import "LessonAdvanceSettingsViewController.h"
#import "Settings.h"
#import "YHRoundBorderedButton.h"
#import "MBProgressHUD.h"
#import "LessonAdvanceTableViewController.h"
#import "AppDelegate.h"

@interface LessonAdvanceSettingsViewController ()


//@property (weak, nonatomic) IBOutlet UILabel *applicationVersionLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *lessonSettingsPickerView;
@property (weak, nonatomic) IBOutlet YHRoundBorderedButton *cancelButton;
@property (weak, nonatomic) IBOutlet YHRoundBorderedButton *doneButton;
@property (strong, nonatomic) NSMutableArray *pickerViewDataSource;
@property (assign, nonatomic) PickerViewType pickerViewType;
@property (assign, nonatomic) StepType repeatLessonStartFrom;
@property (copy, nonatomic) NSString *localDefaultVoicePromptsId;
@property (strong, nonatomic) LessonAdvanceTableViewController *lessonAdvanceSettingsTableViewController;
@property (assign, nonatomic) BOOL pickerViewActive;

- (IBAction)pickerViewCancelButtonClicked:(YHRoundBorderedButton*)sender;
- (IBAction)pickerViewDoneButtonClicked:(YHRoundBorderedButton*)sender;

@end

@implementation LessonAdvanceSettingsViewController

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

    if (self.pickerViewActive)
        return;

    if (!showAnimationActive)
    {
        showAnimationActive = YES;
        [self.pickerView reloadAllComponents];
        [UIView animateWithDuration:0.4f
                         animations:^
         {
             self.lessonSettingsPickerView.frame = CGRectOffset(self.lessonSettingsPickerView.frame, 0.f, -180.f);
             self.shadowView.hidden = NO;
         }
                         completion:^(BOOL finished)
         {
             //        self.settingsPickerView.frame = CGRectMake(0.f, 0.f, 0.f, 0.f);
             showAnimationActive = NO;
             self.pickerViewActive = YES;
         }];
    }
}

- (void)hideAll
{
    [self hidePickerView];
}

- (void)hidePickerView
{
    static BOOL hideAnimationActive = NO;
    if (!self.pickerViewActive)
        return;

    if (!hideAnimationActive)
    {
        hideAnimationActive = YES;
        [UIView animateWithDuration:0.4f
                         animations:^
         {
             self.lessonSettingsPickerView.frame = CGRectOffset(self.lessonSettingsPickerView.frame, 0.f, 180.f);
             self.shadowView.hidden = YES;
         }
                         completion:^(BOOL finished)
         {
             //        self.settingsPickerView.frame = CGRectMake(0.f, 0.f, 0.f, 0.f);
             hideAnimationActive = NO;
             self.pickerViewActive = NO;
         }];
    }
}

- (void)loadVoicePromptsDataSource
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
    [MBProgressHUD showHUDAddedTo:self.parentViewController.view animated:YES];
    NSString *teacherId = self.clip.teacherId;
    [[Settings sharedInstance] loadVoicePromptsFromServer:teacherId];

}

- (void)loadReplayLessonDataSource
{
    [self.pickerViewDataSource removeAllObjects];
    [self.pickerViewDataSource addObjectsFromArray:@[[[Settings sharedInstance] getStringByName:@"lessonsettings_listentome"],
                                                     [[Settings sharedInstance] getStringByName:@"lessonsettings_listentous_step1"],
                                                     [[Settings sharedInstance] getStringByName:@"lessonsettings_listentomeagain"],
                                                     [[Settings sharedInstance] getStringByName:@"lessonsettings_nowyou_step1"]]];
    self.pickerViewType = PickerViewTypeReplayLesson;
    [self.pickerView reloadAllComponents];
    [self showPickerView];
    [self.pickerView selectRow:self.repeatLessonStartFrom inComponent:0 animated:NO];
}

- (void)prepareVoicePromptsDataSource
{
    [self.pickerViewDataSource removeAllObjects];
    NSArray *serverPrompts = [[Settings sharedInstance] serverPrompts];
    self.pickerViewType = PickerViewTypeVoicePrompts;
    __block NSInteger selectedRow = 0;
    [serverPrompts enumerateObjectsUsingBlock:^(PFObject *obj, NSUInteger idx, BOOL *stop)
     {
         [self.pickerViewDataSource addObject:obj[@"VoiceType"]];
         if ([self.localDefaultVoicePromptsId isEqualToString:obj.objectId])
         {
             selectedRow = idx;
         }
     }];

    [self.pickerView reloadAllComponents];
    [MBProgressHUD hideAllHUDsForView:self.parentViewController.view animated:YES];
    [self showPickerView];
    [self.pickerView selectRow:selectedRow inComponent:0 animated:NO];
}

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareVoicePromptsDataSource) name:kVoicePromptsLoadStatus object:nil];
}

- (void)setupView
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideAll)];
    [self.shadowView addGestureRecognizer:tapGesture];
    self.pickerViewDataSource = [[NSMutableArray alloc] initWithCapacity:1];
    self.repeatLessonStartFrom  = [self.clip.repeatLessonStartFrom integerValue];
    self.localDefaultVoicePromptsId = self.clip.defaultVoicePromptsId;
    self.title = [[Settings sharedInstance] getStringByName:@"lessonsettings_title"];
    [self.cancelButton setTitle:[[Settings sharedInstance] getStringByName:@"lessonadvancedsettings_cancel"] forState:UIControlStateNormal];
    [self.doneButton   setTitle:[[Settings sharedInstance] getStringByName:@"lessonadvancedsettings_okay"] forState:UIControlStateNormal];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerObservers];
    [self setupView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"LessonAdvanceSettingsTableViewSegue"])
    {
        self.lessonAdvanceSettingsTableViewController = segue.destinationViewController;
        self.lessonAdvanceSettingsTableViewController.clip = self.clip;
        self.lessonAdvanceSettingsTableViewController.parent = self;
    }
}

- (IBAction)pickerViewDoneButtonClicked:(id)sender
{
    switch (self.pickerViewType)
    {
        case PickerViewTypeVoicePrompts:
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.parentViewController.view animated:YES];
            NSInteger selectedRow = [self.pickerView selectedRowInComponent:0];
            PFObject *obj = [Settings sharedInstance].serverPrompts[selectedRow];
            self.localDefaultVoicePromptsId = obj.objectId;
            self.clip.defaultVoicePromptsId = obj.objectId;

            [hud showAnimated:YES
          whileExecutingBlock:^{
              [[Settings sharedInstance] saveVoicePrompts:selectedRow];
          }
              completionBlock:^{
                  [self hidePickerView];
                  [self.lessonAdvanceSettingsTableViewController updateView];
              }];
            break;
        }
        case PickerViewTypeReplayLesson:
        {
            NSInteger selectedRow = [self.pickerView selectedRowInComponent:0];
            [Settings sharedInstance].lessonSettingsReplayLessonIndex = selectedRow;
            self.repeatLessonStartFrom = selectedRow;
            self.clip.repeatLessonStartFrom = @(selectedRow);
            [self.lessonAdvanceSettingsTableViewController updateView];
            [self hidePickerView];
            break;
        }
        default:
            break;
    }
}

- (IBAction)pickerViewCancelButtonClicked:(YHRoundBorderedButton*)sender
{
    [self hidePickerView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kVoicePromptsLoadStatus
                                                  object:nil];
}


@end

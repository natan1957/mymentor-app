//
//  SettingsViewController.m
//  MyMentor
//
//  Created by Walter Yaron on 5/1/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LessonSettingsViewController.h"
#import "LessonAdvanceSettingsViewController.h"
#import "Settings.h"
#import "PlayerViewController.h"
#import "AppDelegate.h"
#import "Clip.h"
#import "LessonInformationViewController.h"
#import "RESwitch.h"
#import "YHRoundBorderedButton.h"

@interface LessonSettingsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *switch1_1;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel1_1;
@property (weak, nonatomic) IBOutlet UISwitch *switch1_2;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel1_2;
@property (weak, nonatomic) IBOutlet UISwitch *switch1_3;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel1_3;
@property (weak, nonatomic) IBOutlet UISwitch *switch1_4;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel1_4;
@property (weak, nonatomic) IBOutlet UISwitch *switch1_5;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel1_5;
@property (weak, nonatomic) IBOutlet UISwitch *switch1_6;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel1_6;
@property (weak, nonatomic) IBOutlet UISwitch *switch2_1;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel2_1;
@property (weak, nonatomic) IBOutlet UISwitch *switch2_2;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel2_2;
@property (weak, nonatomic) IBOutlet UISwitch *switch2_3;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel2_3;
@property (weak, nonatomic) IBOutlet UISwitch *switch2_4;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel2_4;
@property (weak, nonatomic) IBOutlet UIView *section1;
@property (weak, nonatomic) IBOutlet UIView *section2;
@property (weak, nonatomic) IBOutlet UISwitch *lessonSettingsPlayType;
@property (weak, nonatomic) IBOutlet UIView *lessonSettingsPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *lessonRepeatCountButton;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UILabel *audioSetupTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *playlistSetupTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *uninterruptedPlayLabel;
@property (weak, nonatomic) IBOutlet YHRoundBorderedButton *cancelButton;
@property (weak, nonatomic) IBOutlet YHRoundBorderedButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *uninterruptedPlayTimesLabel;
@property (weak, nonatomic) RESwitch *reswitch1_1;
@property (weak, nonatomic) RESwitch *reswitch1_2;
@property (weak, nonatomic) RESwitch *reswitch1_3;
@property (weak, nonatomic) RESwitch *reswitch1_4;
@property (weak, nonatomic) RESwitch *reswitch1_5;
@property (weak, nonatomic) RESwitch *reswitch1_6;
@property (weak, nonatomic) RESwitch *reswitch2_1;
@property (weak, nonatomic) RESwitch *reswitch2_2;
@property (weak, nonatomic) RESwitch *reswitch2_3;
@property (weak, nonatomic) RESwitch *reswitch2_4;
@property (weak, nonatomic) RESwitch *relessonSettingsPlayType;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *switchGroup;
@property (copy, nonatomic) NSString *localDefaultVoicePromptsId;
@property (assign, nonatomic) NSInteger showHighlightedWords;
@property (assign, nonatomic) ArrowDirectionType arrowDirectionType;
@property (assign, nonatomic) PlayType playType;
@property (assign, nonatomic) PickerViewType pickerViewType;
@property (assign, nonatomic) BOOL menuOpen;
@property (assign, nonatomic) BOOL pickerViewActive;

- (IBAction)pickerViewCancelButtonClicked:(YHRoundBorderedButton*)sender;
- (IBAction)pickerViewDoneButtonClicked:(YHRoundBorderedButton*)sender;
- (IBAction)advanceButtonDidPressed:(id)sender;
- (IBAction)playUninterruptedButtonValueChanged:(id)sender;
- (IBAction)lessonRepeatCountTouchUpInside:(id)sender;

@end

@implementation LessonSettingsViewController

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
    return 4;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSAttributedString *attString;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        attString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld",(long)row+1] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    }
    else
    {
        attString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld",(long)row+1] attributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    }

    return attString;
}

- (void)setupView
{
    self.managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickerViewCancelButtonClicked:)];
    [self.shadowView addGestureRecognizer:tapGesture];

    self.lessonSettingsPlayType.layer.cornerRadius = 16.0;


    [self.lessonRepeatCountButton setTitle:[NSString stringWithFormat:@"%ld",(long)[self.clip.lessonRepeatCount integerValue]] forState:UIControlStateNormal];

    if ([[Settings sharedInstance].currentLanguage isEqual:@"he_il"])
    {
        self.audioSetupTitleLabel.textAlignment = NSTextAlignmentRight;
        self.playlistSetupTitleLabel.textAlignment = NSTextAlignmentRight;
    }
    else
    {
        self.audioSetupTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.playlistSetupTitleLabel.textAlignment = NSTextAlignmentLeft;
    }

    self.title = [[Settings sharedInstance] getStringByName:@"lessonsettings_title"];
    self.infoLabel1_1.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_listentome"];
    self.infoLabel1_2.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_listentous_step1"];
    self.infoLabel1_3.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_listentomeagain"];
    self.infoLabel1_4.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_nowyou_step1"];
    self.infoLabel1_5.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_listentous_step2"];
    self.infoLabel1_6.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_nowyou_step2"];
    self.infoLabel2_1.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_sections"];
    self.infoLabel2_2.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_sentences"];
    self.infoLabel2_3.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_paragraphs"];
    self.infoLabel2_4.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_chapter"];

    NSMutableAttributedString *attributeString1 = [[NSMutableAttributedString alloc] initWithString:[[Settings sharedInstance] getStringByName:@"lessonsettings_audiosetuptitle"]];
    [attributeString1 addAttribute:NSUnderlineStyleAttributeName
                            value:[NSNumber numberWithInt:1]
                            range:(NSRange){0,[attributeString1 length]}];

    [attributeString1 addAttribute:NSFontAttributeName
                             value:[UIFont fontWithName:@"Helvetica-Bold" size:17.]
                             range:(NSRange){0,[attributeString1 length]}];


    self.audioSetupTitleLabel.attributedText = attributeString1;

    NSMutableAttributedString *attributeString2 = [[NSMutableAttributedString alloc] initWithString:[[Settings sharedInstance] getStringByName:@"lessonsettings_playlistsetuptitle"]];
    [attributeString2 addAttribute:NSUnderlineStyleAttributeName
                             value:[NSNumber numberWithInt:1]
                             range:(NSRange){0,[attributeString2 length]}];

    [attributeString2 addAttribute:NSFontAttributeName
                             value:[UIFont fontWithName:@"Helvetica-Bold" size:17.]
                             range:(NSRange){0,[attributeString2 length]}];

    self.playlistSetupTitleLabel.attributedText = attributeString2;

    self.uninterruptedPlayLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_uninterruptedplay"];
    self.uninterruptedPlayTimesLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_uninterruptedplaytimes"];
    [self.cancelButton setTitle:[[Settings sharedInstance] getStringByName:@"lessonsettings_cancel"] forState:UIControlStateNormal];
    [self.doneButton setTitle:[[Settings sharedInstance] getStringByName:@"lessonsettings_okay"] forState:UIControlStateNormal];
    [self.lessonRepeatCountButton.layer setCornerRadius:10.f];
    [self.lessonRepeatCountButton.layer setMasksToBounds:YES];

}

- (void)setupSwitchs
{
    self.playType = [self.clip.playType integerValue];

    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.switchGroup = @[self.switch1_1,self.switch1_2,self.switch1_3,self.switch1_4,self.switch1_5,self.switch1_6,
                             self.switch2_1,self.switch2_2,self.switch2_3,self.switch2_4];
        [self updateLessonSettingsUI];

        [self.switchGroup enumerateObjectsUsingBlock:^(UISwitch *obj, NSUInteger idx, BOOL *stop)
         {
             [obj addTarget:self action:@selector(switchViewChanged:) forControlEvents:UIControlEventValueChanged];
             obj.layer.cornerRadius = 16.0;
         }];
    }
    else
    {
//        NSInteger step = 0;
//        NSInteger start = 0;
//        NSInteger direction =0;
//        if ([[Settings sharedInstance].appSettingsOldLanguage isEqualToString:@"he_il"])
//        {
//            start = 10;
//            direction = 1;
//        }
//        else
//        {
//            start = 13;
//            direction = -1;
//        }


        RESwitch *switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(248.f, 45.f, 61.f, 26.f)];

        self.switch1_1.hidden = YES;
        [self.section1 addSubview:switch1];
        if ([[Settings sharedInstance].appSettingsOldLanguage isEqualToString:@"he_il"])
        {
            switch1.tag = 10;
            self.reswitch1_1 = switch1;
        }
        else
        {
            switch1.tag = 13;
            self.reswitch1_4 = switch1;
        }
        switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(181.f, 45.f, 61.f, 26.f)];
        switch1.tag = 12;
        self.switch1_2.hidden = YES;
        [self.section1 addSubview:switch1];
        if ([[Settings sharedInstance].appSettingsOldLanguage isEqualToString:@"he_il"])
        {
            switch1.tag = 11;
            self.reswitch1_2 = switch1;
        }
        else
        {
            switch1.tag = 12;
            self.reswitch1_3 = switch1;
        }

        switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(114.f, 45.f, 61.f, 26.f)];
        self.switch1_3.hidden = YES;
        [self.section1 addSubview:switch1];
        if ([[Settings sharedInstance].appSettingsOldLanguage isEqualToString:@"he_il"])
        {
            switch1.tag = 12;
            self.reswitch1_3 = switch1;
        }
        else
        {
            switch1.tag = 11;
            self.reswitch1_2 = switch1;
        }

        switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(47.f, 45.f, 61.f, 26.f)];
        self.switch1_4.hidden = YES;
        [self.section1 addSubview:switch1];

        if ([[Settings sharedInstance].appSettingsOldLanguage isEqualToString:@"he_il"])
        {
            switch1.tag = 13;
            self.reswitch1_4 = switch1;
        }
        else
        {
            switch1.tag = 10;
            self.reswitch1_1 = switch1;
        }

        switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(181.f, 114.f, 61.f, 26.f)];
        if ([[Settings sharedInstance].appSettingsOldLanguage isEqualToString:@"he_il"])
            switch1.frame = CGRectMake(181.f, 114.f, 61.f, 26.f);
        else
            switch1.frame = CGRectMake(114.f, 114.f, 61.f, 26.f);

        switch1.tag = 14;
        self.switch1_5.hidden = YES;
        [self.section1 addSubview:switch1];
        self.reswitch1_5 = switch1;

        switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(47.f, 114.f, 61.f, 26.f)];
        if ([[Settings sharedInstance].appSettingsOldLanguage isEqualToString:@"he_il"])
            switch1.frame = CGRectMake(47.f, 114.f, 61.f, 26.f);
        else
            switch1.frame = CGRectMake(248.f, 114.f, 61.f, 26.f);


        switch1.tag = 15;
        self.switch1_6.hidden = YES;
        [self.section1 addSubview:switch1];
        self.reswitch1_6 = switch1;

        switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(248.f, 45.f, 61.f, 26.f)];
        self.switch2_1.hidden = YES;
        [self.section2 addSubview:switch1];
        if ([[Settings sharedInstance].appSettingsOldLanguage isEqualToString:@"he_il"])
        {
            switch1.tag = 20;
            self.reswitch2_1 = switch1;
        }
        else
        {
            switch1.tag = 23;
            self.reswitch2_4 = switch1;
        }

        switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(181.f, 45.f, 61.f, 26.f)];
        self.switch2_2.hidden = YES;
        [self.section2 addSubview:switch1];
        if ([[Settings sharedInstance].appSettingsOldLanguage isEqualToString:@"he_il"])
        {
            switch1.tag = 21;
            self.reswitch2_2 = switch1;
        }
        else
        {
            switch1.tag = 22;
            self.reswitch2_3 = switch1;
        }

        switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(114.f, 45.f, 61.f, 26.f)];

        self.switch2_3.hidden = YES;
        [self.section2 addSubview:switch1];
        if ([[Settings sharedInstance].appSettingsOldLanguage isEqualToString:@"he_il"])
        {
            switch1.tag = 22;
            self.reswitch2_3 = switch1;
        }
        else
        {
            switch1.tag = 21;
            self.reswitch2_2 = switch1;
        }

        switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(47.f, 45.f, 61.f, 26.f)];
        self.switch2_4.hidden = YES;
        [self.section2 addSubview:switch1];
        if ([[Settings sharedInstance].appSettingsOldLanguage isEqualToString:@"he_il"])
        {
            switch1.tag = 23;
            self.reswitch2_4 = switch1;
        }
        else
        {
            switch1.tag = 20;
            self.reswitch2_1 = switch1;
        }

        switch1 = [[RESwitch alloc] initWithFrame:CGRectMake(0.f, self.lessonSettingsPlayType.frame.origin.y, 61.f, 26.f)];
        if ([[Settings sharedInstance].appSettingsOldLanguage isEqualToString:@"he_il"])
            switch1.frame = CGRectMake(247.f, self.lessonSettingsPlayType.frame.origin.y, 61.f, 26.f);
        else
            switch1.frame = CGRectMake(51.f, self.lessonSettingsPlayType.frame.origin.y, 61.f, 26.f);

        switch1.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.lessonSettingsPlayType.hidden = YES;
        [self.view addSubview:switch1];
        [self.view sendSubviewToBack:switch1];
        self.relessonSettingsPlayType = switch1;
        [self.relessonSettingsPlayType addTarget:self action:@selector(playUninterruptedreButtonValueChanged:) forControlEvents:UIControlEventValueChanged];

        if (self.playType == PlayTypeUninterrupted)
        {
            self.relessonSettingsPlayType.on = NO;
            self.lessonRepeatCountButton.enabled = YES;
            [self.lessonRepeatCountButton setBackgroundColor:[UIColor whiteColor]];
        }
        else
        {
            self.relessonSettingsPlayType.on = YES;
            self.lessonRepeatCountButton.enabled = NO;
            [self.lessonRepeatCountButton setBackgroundColor:[UIColor darkGrayColor]];
        }

        self.switchGroup = @[_reswitch1_1,_reswitch1_2,_reswitch1_3,_reswitch1_4,_reswitch1_5,_reswitch1_6,
                             _reswitch2_1,_reswitch2_2,_reswitch2_3,_reswitch2_4];

        [self updateLessonSettingsUI];

        [self.switchGroup enumerateObjectsUsingBlock:^(UISwitch *obj, NSUInteger idx, BOOL *stop)
         {
             [obj addTarget:self action:@selector(reswitchViewChanged:) forControlEvents:UIControlEventValueChanged];
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

- (void)updateLessonSettingsUI
{
    if (self.playType == PlayTypeUninterrupted)
    {
        self.lessonSettingsPlayType.on = NO;
        self.lessonRepeatCountButton.enabled = YES;
        [self.lessonRepeatCountButton setBackgroundColor:[UIColor whiteColor]];
        self.uninterruptedPlayLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_uninterruptedplay"];
    }
    else
    {
        self.lessonSettingsPlayType.on = YES;
        self.lessonRepeatCountButton.enabled = NO;
        [self.lessonRepeatCountButton setBackgroundColor:[UIColor darkGrayColor]];
        self.uninterruptedPlayLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_uninterruptedplaynotactive"];
    }

    [self.switchGroup enumerateObjectsUsingBlock:^(UISwitch *obj, NSUInteger idx, BOOL *stop)
     {
         NSInteger status = 0;
         switch (obj.tag)
         {
             case 10:
                 status = [self.clip.lessonSwitch1_1 integerValue];
                 break;
             case 11:
                 status = [self.clip.lessonSwitch1_2 integerValue];
                 break;
             case 12:
                 status = [self.clip.lessonSwitch1_3 integerValue];
                 break;
             case 13:
                 status = [self.clip.lessonSwitch1_4 integerValue];
                 break;
             case 14:
                 status = [self.clip.lessonSwitch1_5 integerValue];
                 break;
             case 15:
                 status = [self.clip.lessonSwitch1_6 integerValue];
                 break;
             case 20:
                 status = [self.clip.lessonSwitch2_1 integerValue];
                 break;
             case 21:
                 status = [self.clip.lessonSwitch2_2 integerValue];
                 break;
             case 22:
                 status = [self.clip.lessonSwitch2_3 integerValue];
                 break;
             case 23:
                 status = [self.clip.lessonSwitch2_4 integerValue];
                 break;
             default:
                 break;
         }

         [obj setOn:(status & 1)];
         [obj setEnabled:!((status >> 1) & 1)];

         if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_7_0)
         {
             if (!obj.enabled)
             {
                 if ([obj isKindOfClass:[RESwitch class]])
                 {
                     [(RESwitch*)obj setKnobImage:[UIImage imageNamed:@"button_knob_lock.png"]];
                 }
             }
         }
     }];

    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        if (self.switch1_2.on)
        {
            self.switch1_5.userInteractionEnabled = YES;
//            self.switch1_5.on = YES;
        }
        else
        {
            self.switch1_5.userInteractionEnabled = NO;
            self.switch1_5.on = NO;
        }

        if (self.switch1_4.on)
        {
            self.switch1_6.userInteractionEnabled = YES;
//            self.switch1_6.on = YES;
        }
        else
        {
            self.switch1_6.userInteractionEnabled = NO;
            self.switch1_6.on = NO;
        }
    }
    else
    {
        if (self.reswitch1_2.on)
        {
            self.reswitch1_5.userInteractionEnabled = YES;
//            self.reswitch1_5.on = YES;
        }
        else
        {
            self.reswitch1_5.userInteractionEnabled = NO;
            self.reswitch1_5.on = NO;
        }

        if (self.reswitch1_4.on)
        {
            self.reswitch1_6.userInteractionEnabled = YES;
//            self.reswitch1_6.on = YES;
        }
        else
        {
            self.reswitch1_6.userInteractionEnabled = NO;
            self.reswitch1_6.on = NO;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateLessonSettingsUI];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
    [self setupSwitchs];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateLessonSettingsToCoreData
{
    NSError *error = nil;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.clip.lessonSwitch1_1 = @((int)self.switch1_1.on + (!self.switch1_1.enabled << 1));
        self.clip.lessonSwitch1_2 = @((int)self.switch1_2.on + (!self.switch1_2.enabled << 1));
        self.clip.lessonSwitch1_3 = @((int)self.switch1_3.on + (!self.switch1_3.enabled << 1));
        self.clip.lessonSwitch1_4 = @((int)self.switch1_4.on + (!self.switch1_4.enabled << 1));
        self.clip.lessonSwitch1_5 = @((int)self.switch1_5.on + (!self.switch1_5.enabled << 1));
        self.clip.lessonSwitch1_6 = @((int)self.switch1_6.on + (!self.switch1_6.enabled << 1));
        self.clip.lessonSwitch2_1 = @((int)self.switch2_1.on + (!self.switch2_1.enabled << 1));
        self.clip.lessonSwitch2_2 = @((int)self.switch2_2.on + (!self.switch2_2.enabled << 1));
        self.clip.lessonSwitch2_3 = @((int)self.switch2_3.on + (!self.switch2_3.enabled << 1));
        self.clip.lessonSwitch2_4 = @((int)self.switch2_4.on + (!self.switch2_4.enabled << 1));
    }
    else
    {
        self.clip.lessonSwitch1_1 = @((int)self.reswitch1_1.on + (!self.reswitch1_1.enabled << 1));
        self.clip.lessonSwitch1_2 = @((int)self.reswitch1_2.on + (!self.reswitch1_2.enabled << 1));
        self.clip.lessonSwitch1_3 = @((int)self.reswitch1_3.on + (!self.reswitch1_3.enabled << 1));
        self.clip.lessonSwitch1_4 = @((int)self.reswitch1_4.on + (!self.reswitch1_4.enabled << 1));
        self.clip.lessonSwitch1_5 = @((int)self.reswitch1_5.on + (!self.reswitch1_5.enabled << 1));
        self.clip.lessonSwitch1_6 = @((int)self.reswitch1_6.on + (!self.reswitch1_6.enabled << 1));
        self.clip.lessonSwitch2_1 = @((int)self.reswitch2_1.on + (!self.reswitch2_1.enabled << 1));
        self.clip.lessonSwitch2_2 = @((int)self.reswitch2_2.on + (!self.reswitch2_2.enabled << 1));
        self.clip.lessonSwitch2_3 = @((int)self.reswitch2_3.on + (!self.reswitch2_3.enabled << 1));
        self.clip.lessonSwitch2_4 = @((int)self.reswitch2_4.on + (!self.reswitch2_4.enabled << 1));
    }

    [self.managedObjectContext save:&error];
    if (error)
    {
        NSLog(@"%@",error.description);
    }
}

- (void)reswitchViewChanged:(RESwitch *)switchView
{
    if (switchView.tag >= 10 && switchView.tag < 20)
    {
        if (!self.reswitch1_1.isOn & !self.reswitch1_2.isOn & !self.reswitch1_3.isOn & !self.reswitch1_4.isOn)
        {
            [switchView setOn:!switchView.isOn animated:NO];
            return;
        }
    }
    else
    {
        if (!self.reswitch2_1.isOn & !self.reswitch2_2.isOn & !self.reswitch2_3.isOn & !self.reswitch2_4.isOn)
        {
            [switchView setOn:!switchView.isOn animated:NO];
            return;
        }
    }

    if (switchView.tag == 11)
    {
        if (switchView.on)
        {
            self.reswitch1_5.userInteractionEnabled = YES;
            self.reswitch1_5.on = YES;
        }
        else
        {
            self.reswitch1_5.userInteractionEnabled = NO;
            self.reswitch1_5.on = NO;
        }

        if ([self.delegate respondsToSelector:@selector(lessonSettingsDidUpdate:withStatus:)])
        {
            [self.delegate lessonSettingsDidUpdate:self.reswitch1_5.tag withStatus:self.reswitch1_5.isOn];
        }
    }

    if (switchView.tag == 13)
    {
        if (switchView.on)
        {
            _reswitch1_6.userInteractionEnabled = YES;
            _reswitch1_6.on = YES;
        }
        else
        {
            _reswitch1_6.userInteractionEnabled = NO;
            _reswitch1_6.on = NO;
        }

        if ([self.delegate respondsToSelector:@selector(lessonSettingsDidUpdate:withStatus:)])
        {
            [self.delegate lessonSettingsDidUpdate:self.reswitch1_6.tag withStatus:self.reswitch1_6.isOn];
        }
    }

    if ([self.delegate respondsToSelector:@selector(lessonSettingsDidUpdate:withStatus:)])
    {
        [self.delegate lessonSettingsDidUpdate:switchView.tag withStatus:switchView.isOn];
    }
    [self updateLessonSettingsToCoreData];
}

- (void)switchViewChanged:(UISwitch *)switchView
{
    if (switchView.tag >= 10 && switchView.tag < 20)
    {
        if (!self.switch1_1.isOn && !self.switch1_2.isOn && !self.switch1_3.isOn && !self.switch1_4.isOn)
        {
            [switchView setOn:!switchView.isOn animated:NO];
            return;
        }
    }
    else
    {
        if (!self.switch2_1.isOn && !self.switch2_2.isOn && !self.switch2_3.isOn && !self.switch2_4.isOn)
        {
            [switchView setOn:!switchView.isOn animated:NO];
            return;
        }
    }

    if (switchView.tag == 11)
    {
        if (switchView.on)
        {
            self.switch1_5.userInteractionEnabled = YES;
            self.switch1_5.on = YES;
        }
        else
        {
            self.switch1_5.userInteractionEnabled = NO;
            self.switch1_5.on = NO;
        }

        if ([self.delegate respondsToSelector:@selector(lessonSettingsDidUpdate:withStatus:)])
        {
            [self.delegate lessonSettingsDidUpdate:self.switch1_5.tag withStatus:self.switch1_5.isOn];
        }
    }

    if (switchView.tag == 13)
    {
        if (switchView.on)
        {
            self.switch1_6.userInteractionEnabled = YES;
            self.switch1_6.on = YES;
        }
        else
        {
            self.switch1_6.userInteractionEnabled = NO;
            self.switch1_6.on = NO;
        }
        
        if ([self.delegate respondsToSelector:@selector(lessonSettingsDidUpdate:withStatus:)])
        {
            [self.delegate lessonSettingsDidUpdate:self.switch1_6.tag withStatus:self.switch1_6.isOn];
        }
    }

    if ([self.delegate respondsToSelector:@selector(lessonSettingsDidUpdate:withStatus:)])
    {
        [self.delegate lessonSettingsDidUpdate:switchView.tag withStatus:switchView.isOn];
    }
    [self updateLessonSettingsToCoreData];
}

- (void)showPickerView
{
    static BOOL showAnimationActive = NO;
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
             self.lessonSettingsPickerView.frame = CGRectOffset(self.lessonSettingsPickerView.frame, 0.f, 180.f);
             self.shadowView.hidden = YES;
         }
                         completion:^(BOOL finished)
         {
             //        self.settingsPickerView.frame = CGRectMake(0.f, 0.f, 0.f, 0.f);
             hideAnimationActive = NO;

         }];
    }
}

- (IBAction)advanceButtonDidPressed:(id)sender
{
    SWRevealViewController *revealController = [self revealViewController];
    if (!self.menuOpen)
    {
        [revealController.revealViewController setFrontViewPosition:FrontViewPositionLeftSideMost animated:YES];
        self.menuOpen = YES;
        self.section1.userInteractionEnabled = NO;
        self.section2.userInteractionEnabled = NO;
        self.relessonSettingsPlayType.userInteractionEnabled = NO;
        self.lessonSettingsPlayType.userInteractionEnabled = NO;
    }
    else
    {
        [revealController.revealViewController setFrontViewPosition:FrontViewPositionLeftSide animated:YES];
        self.menuOpen = NO;
        self.section1.userInteractionEnabled = YES;
        self.section2.userInteractionEnabled = YES;
        self.relessonSettingsPlayType.userInteractionEnabled = YES;
        self.lessonSettingsPlayType.userInteractionEnabled = YES;
    }

    [revealController rightRevealToggle:nil];

}

- (void)playUninterruptedreButtonValueChanged:(id)sender
{
    if (self.playType == PlayTypeInterrupted)
    {
        self.playType = PlayTypeUninterrupted;
        self.relessonSettingsPlayType.on = NO;
        self.lessonRepeatCountButton.enabled = YES;
        self.uninterruptedPlayLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_uninterruptedplay"];
        self.clip.playType = @(PlayTypeUninterrupted);
    }
    else
    {
        self.playType = PlayTypeInterrupted;
        self.relessonSettingsPlayType.on = YES;
        self.lessonRepeatCountButton.enabled = NO;
        self.uninterruptedPlayLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_uninterruptedplaynotactive"];
        self.clip.playType = @(PlayTypeInterrupted);
    }
    [self updateLessonSettingsToCoreData];
    [self updateLessonSettingsUI];
}

- (IBAction)playUninterruptedButtonValueChanged:(id)sender
{
    if (self.playType == PlayTypeInterrupted)
    {
        self.playType = PlayTypeUninterrupted;
        self.lessonSettingsPlayType.on = NO;
        self.lessonRepeatCountButton.enabled = YES;
        self.uninterruptedPlayLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_uninterruptedplay"];
        self.clip.playType = @(PlayTypeUninterrupted);
    }
    else
    {
        self.playType = PlayTypeInterrupted;
        self.lessonSettingsPlayType.on = YES;
        self.lessonRepeatCountButton.enabled = NO;
        self.uninterruptedPlayLabel.text = [[Settings sharedInstance] getStringByName:@"lessonsettings_uninterruptedplaynotactive"];
        self.clip.playType = @(PlayTypeInterrupted);
    }
    [self updateLessonSettingsToCoreData];
    [self updateLessonSettingsUI];
}

- (IBAction)lessonRepeatCountTouchUpInside:(id)sender
{
    if (!self.pickerViewActive)
    {
        [self.pickerView selectRow:[self.clip.lessonRepeatCount integerValue]-1 inComponent:0 animated:NO];
        [self showPickerView];
        self.pickerViewActive = YES;
    }
}

- (IBAction)pickerViewDoneButtonClicked:(id)sender
{
    NSInteger selectedRow = [self.pickerView selectedRowInComponent:0];
    self.clip.lessonRepeatCount = @(selectedRow+1);
    [self.lessonRepeatCountButton setTitle:[NSString stringWithFormat:@"%ld",(long)[self.clip.lessonRepeatCount integerValue]] forState:UIControlStateNormal];
    [self hidePickerView];
    self.pickerViewActive = NO;
    [self updateLessonSettingsToCoreData];
}

- (IBAction)pickerViewCancelButtonClicked:(YHRoundBorderedButton*)sender
{
    [self hidePickerView];
    self.pickerViewActive = NO;
}

@end

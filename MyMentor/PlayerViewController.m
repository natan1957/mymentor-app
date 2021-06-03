//
//  PlayerViewController.m
//  MyMentor
//
//  Created by Walter Yaron on 4/27/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import <DTCoreText/DTCoreText.h>
#import <DTFoundation/DTFoundation.h>
#import "DTAttributedCustomTextView.h"
#import <QuartzCore/QuartzCore.h>
#import "PlayerViewController.h"
#import "audioPlayer.h"
#import "userAudio.h"
#import "MBProgressHUD.h"
#import "LessonSettingsViewController.h"
#import "Defines.h"
#import "Playlist.h"
#import "SIAlertView.h"
#import "UIDevice+Hardware.h"
//#import "DTLazyImageView.h"
#import "Settings.h"
#import "User.h"
#import "UserGroupImageViewController.h"
#import "MMNavigationController.h"
#import "LessonAdvanceTableViewController.h"
#import "CocoaSecurity.h"
#import "Base64.h"
#import "YHRoundBorderedButton.h"
#import "AlertBackgroundWindow.h"
#import "CustomCornersView.h"

@interface PlayerViewController () <LessonDelegate,
                                    LesseonSettingsViewDelegate,
                                    UIScrollViewDelegate,
                                    UIAlertViewDelegate,
                                    DTAttributedTextContentViewDelegate,
                                    UIGestureRecognizerDelegate,
                                    DTLazyImageViewDelegate,
                                    AlertBackgroundDelegate>

@property (weak, nonatomic) IBOutlet UIView *playerMenuView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *lessonSettingsControls;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet DTAttributedCustomTextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIImageView *menuBackgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *glowImage;
@property (weak, nonatomic) IBOutlet UILabel *hdmiLabel;
@property (weak, nonatomic) IBOutlet UIButton *lessonTextSettingsOption1;
@property (weak, nonatomic) IBOutlet UIButton *lessonTextSettingsOption2;
@property (weak, nonatomic) IBOutlet UIButton *lessonTextSettingsOption3;
@property (weak, nonatomic) IBOutlet UIButton *lessonTextSettingsOption4;
@property (weak, nonatomic) IBOutlet UIImageView *lessonTextSettingsLevel1ImageView;
@property (weak, nonatomic) IBOutlet UIButton *lessonPlaySettingsOption1;
@property (weak, nonatomic) IBOutlet UIButton *lessonPlaySettingsOption2;
@property (weak, nonatomic) IBOutlet UIButton *lessonPlaySettingsOption3;
@property (weak, nonatomic) IBOutlet UIButton *lessonPlaySettingsOption4;
@property (weak, nonatomic) IBOutlet UIImageView *lessonTextSettingsLevel2ImageView;
@property (weak, nonatomic) IBOutlet UIView *lessonTextSettingsHelperView;
@property (weak, nonatomic) IBOutlet UIButton *lessonTextSettingsFontSizeButton;
@property (weak, nonatomic) IBOutlet UILabel *fontSizeInfoLabel;
@property (weak, nonatomic) IBOutlet YHRoundBorderedButton *cancelButton;
@property (weak, nonatomic) IBOutlet YHRoundBorderedButton *doneButton;
@property (strong, nonatomic) IBOutlet CustomCornersView *lessonSettingsFontSizeView;
@property (strong, nonatomic) IBOutlet UIView *lessonTextSettingsView;
@property (strong, nonatomic) AlertBackgroundWindow *alertView;
@property (strong, nonatomic) NSMutableAttributedString *lessonString;
@property (strong, nonatomic) NSMutableAttributedString *sectionString;
@property (strong, nonatomic) NSData *lessonData;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) LessonMetadata *currentSection;
@property (strong, nonatomic) LessonMetadata *lastWord;
@property (strong, nonatomic) NSTimer *blinkingTimer;
@property (strong, nonatomic) NSTimer *blinkingTimerMic;
@property (strong, nonatomic) UIImageView *mic;
@property (strong, nonatomic) Clip *lessonClip;
@property (strong, nonatomic) SWRevealViewController *childController;
@property (strong, nonatomic) AppAudio *appAudio;
@property (strong, nonatomic) UserGroupImageViewController *userGroupImageViewController;
//@property (strong, nonatomic) ItemType lastUpdate;
@property (assign, nonatomic) ItemType itemType;
@property (assign, nonatomic) BOOL toggle;
@property (assign, nonatomic) BOOL menuStatus;
@property (assign, nonatomic) BOOL menuAnimationActive;
@property (assign, nonatomic) BOOL toggleMic;
@property (assign, nonatomic) BOOL alertOnScreen;
@property (assign, nonatomic) BOOL fontViewActive;
@property (assign, nonatomic) BOOL menuOpen;
@property (assign, nonatomic) ShowHighlightedWordsType showHighlightedWords;
@property (assign, nonatomic) NSInteger lessonSettingsStartFontSize;
@property (assign, nonatomic) CGFloat lessonSettingsOldFontSize;
@property (assign, nonatomic) CGFloat lastPlaceX;
@property (assign, nonatomic) ArrowDirectionType arrowDirectionType;

- (IBAction)lessonSettingsButtonTouchUpInside:(id)sender;
- (IBAction)pressPlay:(id)sender;
- (IBAction)pressForward:(id)sender;
- (IBAction)pressBackward:(id)sender;
- (IBAction)pressNext:(id)sender;
- (IBAction)pressPrevious:(id)sender;
- (IBAction)pressRecord:(id)sender;
- (IBAction)volumeButtonDidPressed:(id)sender;
- (IBAction)pressSlider:(UISlider*)sender;
- (IBAction)lessonTextSettingsButtonClicked:(id)sender;
- (IBAction)lessonTypeButtonClicked:(id)sender;
- (IBAction)fontSizeButtonTouchUpInside:(id)sender;
- (IBAction)fontSizeViewCancelButtonClicked:(id)sender;
- (IBAction)fontSizeViewDoneButtonClicked:(id)sender;
- (IBAction)pressIncreaseTextSize:(id)sender;
- (IBAction)pressDecreaseTextSize:(id)sender;

@end

@implementation PlayerViewController

#pragma mark - AlertBackgroundView Delegate

- (void)alertBackgroundDidReciveTap
{
    [self hideLessonTextSettingsView];
}

- (void)lessonSettingsDidUpdate:(NSInteger)index withStatus:(BOOL)status
{
    if (index >= 20) {
//        self.lastUpdate = index - 20;
    }

    [self.lesson updateLessonSettings:index withStatus:status];
}

#pragma mark - Lesson Settings Delegate

- (void)lessonShowDemoMessage
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:[[Settings sharedInstance] getStringByName:@"playlesson_demomode"]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        alertView.tag = DEMO_ACTIVE;
        [alertView show];
    });
}

- (void)updateLessonSettings
{
    self.lesson.playType = [self.lessonClip.playType integerValue];
    self.lesson.repeatCount = [self.lessonClip.lessonRepeatCount integerValue];
    self.arrowDirectionType = [self.lessonClip.arrowDirectionType integerValue];
    self.lesson.saveUserAudioFiles = [self.lessonClip.saveUserAudio boolValue];

    NSInteger found = 0;

    if (([self.lessonClip.lessonSwitch2_1 integerValue] & 1) == 1)
    {
        found = 1;
    }
    else if (([self.lessonClip.lessonSwitch2_2 integerValue] & 1) == 1)
    {
        found = 1;
    }
    else if (([self.lessonClip.lessonSwitch2_3 integerValue] & 1) == 1)
    {
        found = 1;
    }
    else if (([self.lessonClip.lessonSwitch2_4 integerValue] & 1) == 1)
    {
        found = 1;
    }

    [self.lessonPlaySettingsOption1 setBackgroundImage:[UIImage imageNamed:@"btn_bg_off.png"] forState:UIControlStateNormal];
    [self.lessonPlaySettingsOption2 setBackgroundImage:[UIImage imageNamed:@"btn_bg_off.png"] forState:UIControlStateNormal];
    [self.lessonPlaySettingsOption3 setBackgroundImage:[UIImage imageNamed:@"btn_bg_off.png"] forState:UIControlStateNormal];
    [self.lessonPlaySettingsOption4 setBackgroundImage:[UIImage imageNamed:@"btn_bg_off.png"] forState:UIControlStateNormal];

    if (found == 1)
    {
        if ([[Settings sharedInstance].currentLanguage isEqualToString:@"he_il"])
        {
            if ((([self.lessonClip.lessonSwitch2_1 integerValue] & 1) == 1) && (([self.lessonClip.lessonSwitch2_2 integerValue] & 1) == 0) && (([self.lessonClip.lessonSwitch2_3 integerValue] & 1) == 0) && (([self.lessonClip.lessonSwitch2_4 integerValue] & 1) == 0))
            {
                self.itemType = ItemTypeSection;
                [self.lessonPlaySettingsOption4 setBackgroundImage:[UIImage imageNamed:@"btn_bg_on.png"] forState:UIControlStateNormal];
            }
            else if ((([self.lessonClip.lessonSwitch2_1 integerValue] & 1) == 0) && (([self.lessonClip.lessonSwitch2_2 integerValue] & 1) == 1) && (([self.lessonClip.lessonSwitch2_3 integerValue] & 1) == 0) && (([self.lessonClip.lessonSwitch2_4 integerValue] & 1) == 0))
            {
                self.itemType = ItemTypeSentences;
                [self.lessonPlaySettingsOption3 setBackgroundImage:[UIImage imageNamed:@"btn_bg_on.png"] forState:UIControlStateNormal];
            }
            else if ((([self.lessonClip.lessonSwitch2_1 integerValue] & 1) == 0) && (([self.lessonClip.lessonSwitch2_2 integerValue] & 1) == 0) && (([self.lessonClip.lessonSwitch2_3 integerValue] & 1) == 1) && (([self.lessonClip.lessonSwitch2_4 integerValue] & 1) == 0))
            {
                self.itemType = ItemTypeParagraph;
                [self.lessonPlaySettingsOption2 setBackgroundImage:[UIImage imageNamed:@"btn_bg_on.png"] forState:UIControlStateNormal];
            }
            else if ((([self.lessonClip.lessonSwitch2_1 integerValue] & 1) == 0) && (([self.lessonClip.lessonSwitch2_2 integerValue] & 1) == 0) && (([self.lessonClip.lessonSwitch2_3 integerValue] & 1) == 0) && (([self.lessonClip.lessonSwitch2_4 integerValue] & 1) == 1))
            {
                self.itemType = ItemTypeChapter;
                [self.lessonPlaySettingsOption1 setBackgroundImage:[UIImage imageNamed:@"btn_bg_on.png"] forState:UIControlStateNormal];
            }
        }
        else
        {
            if ((([self.lessonClip.lessonSwitch2_1 integerValue] & 1) == 1) && (([self.lessonClip.lessonSwitch2_2 integerValue] & 1) == 0) && (([self.lessonClip.lessonSwitch2_3 integerValue] & 0) == 0) && (([self.lessonClip.lessonSwitch2_4 integerValue] & 1) == 0))
            {
                self.itemType = ItemTypeSection;
                [self.lessonPlaySettingsOption4 setBackgroundImage:[UIImage imageNamed:@"btn_bg_on.png"] forState:UIControlStateNormal];
            }
            else if ((([self.lessonClip.lessonSwitch2_1 integerValue] & 1) == 0) && (([self.lessonClip.lessonSwitch2_2 integerValue] & 1) == 1) && (([self.lessonClip.lessonSwitch2_3 integerValue] & 1) == 0) && (([self.lessonClip.lessonSwitch2_4 integerValue] & 1) == 0))
            {
                self.itemType = ItemTypeSentences;
                [self.lessonPlaySettingsOption3 setBackgroundImage:[UIImage imageNamed:@"btn_bg_on.png"] forState:UIControlStateNormal];
            }
            else if ((([self.lessonClip.lessonSwitch2_1 integerValue] & 1) == 0) && (([self.lessonClip.lessonSwitch2_2 integerValue] & 1) == 0) && (([self.lessonClip.lessonSwitch2_3 integerValue] & 1) == 1) && (([self.lessonClip.lessonSwitch2_4 integerValue] & 1) == 0))
            {
                self.itemType = ItemTypeParagraph;
                [self.lessonPlaySettingsOption2 setBackgroundImage:[UIImage imageNamed:@"btn_bg_on.png"] forState:UIControlStateNormal];
            }
            else if ((([self.lessonClip.lessonSwitch2_1 integerValue] & 1) == 0) && (([self.lessonClip.lessonSwitch2_2 integerValue] & 1) == 0) && (([self.lessonClip.lessonSwitch2_3 integerValue] & 1) == 0) && (([self.lessonClip.lessonSwitch2_4 integerValue] & 1) == 1))
            {
                self.itemType = ItemTypeChapter;
                [self.lessonPlaySettingsOption1 setBackgroundImage:[UIImage imageNamed:@"btn_bg_on.png"] forState:UIControlStateNormal];
            }
        }
    }

    [self showPlayButton];
}

#pragma mark Initialization Methods #pragma mark -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.lesson isPlaying])
    {
        self.textView.lastScrollDate = [NSDate date];
        self.textView.userDidScroll = YES;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.lesson isPlaying])
    {
        self.textView.lastScrollDate = [NSDate date];
        self.textView.userDidScroll = YES;
        [self.textView userFinishToDrag];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.textView.lastOffsety = scrollView.contentOffset.y;
}

- (void)lessonItemFinish:(BOOL)showSaveUserAudioFiles
{
    [self showAlertView:showSaveUserAudioFiles];
}

- (void)lessonEnd:(BOOL)showSaveUserAudioFiles
{
    [self clearLessonColor];
    [self showPlayButton];
    if (self.lesson.playType == PlayTypeInterrupted)
    {
        [self showLessonEndAlertView:showSaveUserAudioFiles];
    }
    else
    {
        self.view.userInteractionEnabled = NO;
        self.appAudio = [[AppAudio alloc] init];
        [self.appAudio play:AppAudioEndOfLesson withItem:nil];
        [self performSelector:@selector(endLesson:) withObject:nil afterDelay:3.f];
    }
}

- (void)lessonClearWords
{
    [self clearLessonWord];
}

- (void)setCurrentSection:(LessonMetadata *)currentSection
{
    _currentSection = currentSection;
}

- (void)lessonShowWord:(LessonMetadata*)word insideSection:(LessonMetadata*)item
{
    if (!word && !item)
    {
        self.lastWord = word;
        self.currentSection = item;
        return;
    }

    if (self.lastWord != word || self.currentSection != item)
    {
        NSRange itemRangeSection = NSMakeRange(item.charStartIndex, item.charEndIndex);
        if ([self.lesson getStepType] == StepType4)
        {
            if (self.showHighlightedWords == ShowHighlightedWordsTypeShow)
                [self updateLessonSection:itemRangeSection];
        }
        else
        {
            [self updateLessonSection:itemRangeSection];
        }
        self.currentSection = item;

        NSRange itemRangeWord = NSMakeRange(word.charStartIndex, word.charEndIndex);
        [self.textView scrollRangeToVisible:itemRangeWord reset:YES];

        if ([self.lesson getStepType] == StepType4)
        {
            if (self.showHighlightedWords == ShowHighlightedWordsTypeShow)
            {
                [self updateLessonWord:itemRangeWord];
            }
        }
        else
        {
            [self updateLessonWord:itemRangeWord];
        }
        self.lastWord = word;
    }
}

- (void)lessonShowItem:(LessonMetadata*)item
{
    if (item)
    {
        NSRange itemRange = NSMakeRange(item.charStartIndex, item.charEndIndex);
        [self.textView scrollRangeToVisible:itemRange reset:YES];
        [self updateLessonColor:itemRange];
        self.currentSection = item;
    }
}

- (void)updateHTML
{
    if (self.currentSection)
    {
        self.currentSection = [self.lesson getCurrentItem];
        NSRange itemRangeSection = NSMakeRange(self.currentSection.charStartIndex, self.currentSection.charEndIndex);
        [self updateLessonSection:itemRangeSection];

        if ((self.showHighlightedWords == ShowHighlightedWordsTypeShow) && self.lastWord)
        {
            self.lastWord = [self.lesson getCurrentWordInfo];
            NSRange itemRangeWord = NSMakeRange(self.lastWord.charStartIndex, self.lastWord.charEndIndex);
            [self updateLessonWord:itemRangeWord];
        }
    }
}

- (void)lessonShowFinish:(NSUInteger)type
{

}

- (void)lessonStartRecording:(BOOL)enableButton
{
    if (enableButton)
    {
        [self showRecordButton];
    }
    else
    {
        [self showRecordButtonOverPlay];
    }

    [self.recordButton setUserInteractionEnabled:enableButton];
    if (!self.blinkingTimer)
    {
        self.toggle = NO;
        self.glowImage.alpha = 1.0f;
        self.blinkingTimer = [NSTimer scheduledTimerWithTimeInterval:0.8f
                                                              target:self
                                                            selector:@selector(toggleButtonImage:)
                                                            userInfo:nil
                                                             repeats:YES];
    }
}

- (void)lessonEndRecording
{
    if (self.blinkingTimer)
    {
        [self.blinkingTimer invalidate];
        self.blinkingTimer = nil;
        [self hideRecordButtonFromPlay];
        [self hideRecordButton];
    }
}

- (void)hideRecordButtonFromPlay
{
    self.glowImage.hidden = YES;
}

- (void)showRecordButtonOverPlay
{
    self.glowImage.hidden = NO;
}

- (void)showPlayButton
{
    if (self.arrowDirectionType == ArrowDirectionTypeLeft)
        [self.playButton setImage:[UIImage imageNamed:@"playFliped.png"] forState:UIControlStateNormal];
    else
        [self.playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
}

- (void)showRecordButton
{
    self.menuBackgroundImage.hidden = NO;
    self.recordButton.hidden = NO;
    self.glowImage.hidden = NO;
    CGFloat height = 0.f;

    if ([UIScreen mainScreen].bounds.size.height == 480.f)
    {
        height = 316.f;
    }

    if ([UIScreen mainScreen].bounds.size.height == 568.f)
    {
        height = 404.f;
    }

    [UIView animateWithDuration:0.3f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
    {
        self.recordButton.frame = CGRectMake(130.f, 0.f, 60.f, 40.f);
        self.glowImage.frame = CGRectMake(130.f, 0.f, 60.f,40.f);
        self.playerMenuView.frame = CGRectMake(0.f, height, 320.f, 100.f);
    }
                     completion:^(BOOL finished)
    {

    }];
}

- (void)hideRecordButton
{
    CGFloat height = 0.f;

    if ([UIScreen mainScreen].bounds.size.height == 480.f)
    {
        height = 356.f;
    }

    if ([UIScreen mainScreen].bounds.size.height == 568.f)
    {
        height = 444.f;
    }

    __weak PlayerViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(),^
    {
       [UIView animateWithDuration:0.3f
                             delay:0.f
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^
        {
            weakSelf.recordButton.frame = CGRectMake(130.f, 16.f, 60.f, 40.f);
            weakSelf.glowImage.frame = CGRectMake(130.f, 10.f, 60.f, 40.f);
            weakSelf.playerMenuView.frame = CGRectMake(0.f, height, 320.f, 60.f);
        }
                        completion:^(BOOL finished)
        {
            weakSelf.menuBackgroundImage.hidden = YES;
            weakSelf.recordButton.hidden = YES;
            weakSelf.glowImage.hidden = YES;
            [weakSelf.recordButton setUserInteractionEnabled:NO];
        }];
    });
}

- (void)toggleButtonImage:(NSTimer*)timer
{
    if(self.toggle)
    {
        [UIView animateWithDuration:0.6f
                              delay:0.1f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^
        {
            self.glowImage.alpha = 1.0f;
        }
                         completion:^(BOOL finished)
        {

        }];
    }
    else
    {
        [UIView animateWithDuration:0.6f
                              delay:0.1f
                            options:UIViewAnimationOptionCurveEaseIn
                          animations:^
        {
            self.glowImage.alpha = 0.0f;
        }
                         completion:^(BOOL finished)
        {

        }];
    }
    self.toggle = !self.toggle;
}

- (void)showLessonTextSettingsView:(CGPoint)center
{
    self.lessonTextSettingsView.hidden = NO;
    self.lessonTextSettingsView.center = CGPointMake(160.f, center.y);
    self.textView.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.alertView.alpha = 1.f;
                         self.lessonTextSettingsView.alpha = 1.f;
    }
                     completion:^(BOOL finished)
    {

    }];
}

- (void)hideLessonTextSettingsView
{
    [UIView animateWithDuration:0.4f
                          delay:0.2f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^
    {
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
            self.textView.contentInset = UIEdgeInsetsMake(0.f, 0.f, 20.f, 0.f);
        else
            self.textView.contentInset = UIEdgeInsetsMake(0.f, 0.f, 40.f, 0.f);
        
        self.lessonTextSettingsView.alpha = 0.f;
        self.alertView.alpha = 0.f;
    }
                     completion:^(BOOL finished)
    {
        self.lessonTextSettingsView.hidden = YES;
        self.textView.userInteractionEnabled = YES;
    }];
}

- (void)showFontSizeView
{
    static BOOL showAnimationActive = NO;
    if (self.fontViewActive)
        return;

    if (!showAnimationActive)
    {
        showAnimationActive = YES;
        [UIView animateWithDuration:0.4f
                         animations:^
         {
             self.alertView.alpha = 1.f;
             self.lessonSettingsFontSizeView.frame = CGRectOffset(self.lessonSettingsFontSizeView.frame, 0.f, -160.f);
         }
                         completion:^(BOOL finished)
         {
             showAnimationActive = NO;
             self.fontViewActive = YES;
         }];
    }
}

- (void)hideFontSizeView
{
    static BOOL hideAnimationActive = NO;
    if (!self.fontViewActive)
        return;

    if (!hideAnimationActive)
    {
        hideAnimationActive = YES;
        [UIView animateWithDuration:0.4f
                         animations:^
         {
             self.alertView.alpha = 0.f;
             self.lessonSettingsFontSizeView.frame = CGRectOffset(self.lessonSettingsFontSizeView.frame, 0.f, 160.f);
         }
                         completion:^(BOOL finished)
         {
             hideAnimationActive = NO;
             self.fontViewActive = NO;
         }];
    }
}

- (void)textViewTap:(UITapGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateRecognized)
	{
        if (![[UIDevice currentDevice] isCurrentDeviceHardwareBetterThan:IPOD_TOUCH_3G])
        {
            if (![self.lesson checkForMic])
            {
                [self showMessage];
                return;
            }
        }

		CGPoint location = [gesture locationInView:_textView];
		NSUInteger tappedIndex = [_textView closestCursorIndexToPoint:location];

		NSString *plainText = [_textView.attributedString string];

		__block NSRange wordRange = NSMakeRange(0, 0);

		[plainText enumerateSubstringsInRange:NSMakeRange(0, [plainText length])
                                      options:NSStringEnumerationByWords
                                   usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
        {
			if (NSLocationInRange(tappedIndex, enclosingRange))
			{
				*stop = YES;
				wordRange = substringRange;
			}
		}];

        [self.lesson gotoItemByIndex:tappedIndex withForceType:self.itemType];
        [self.playButton setImage:[UIImage imageNamed:@"menu_pause_button.png"] forState:UIControlStateNormal];
        self.lesson.playing = YES;
	}
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        [self pause];
        CGPoint center = [gesture locationOfTouch:0 inView:self.view];
        if (center.y < 90.f)
            center.y += 120.f;

        [self showLessonTextSettingsView:center];
    }
}

#pragma mark -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)updateHDMILabel:(NSNotification*)note
{
    self.hdmiLabel.hidden = ![note.object boolValue];
}

- (void)updateMicStatus:(NSNotification*)note
{
     if (![note.object boolValue])
     {
         if (!self.alertOnScreen)
         {
             if (![[UIDevice currentDevice] isCurrentDeviceHardwareBetterThan:IPOD_TOUCH_3G])
             {
                 dispatch_async(dispatch_get_main_queue(), ^
                 {
                     self.alertOnScreen = YES;
                     [self showMessage];

                     if (self.lesson.isPlaying)
                     {
                         [self lessonEndRecording];
                         [self.lesson pause];
                         [self showPlayButton];
                     }
                 });
             }
         }
     }
}

- (void)updateSpeakerStatus:(NSNotification*)note
{
    [self showPlayButton];
    [self.lesson pause];
}

- (void)updateVolumeMenuStatus:(NSNotification*)note
{
     if ([note.object boolValue])
     {
         [self showMenu];
     }
     else
     {
         [self hideMenu];
     }
}

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHDMILabel:) name:kHDMIActive object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMicStatus:) name:kMicStatusChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSpeakerStatus:) name:kSpeakerStatusChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVolumeMenuStatus:) name:kVolumeMenuStatusChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)showMessage
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"שגיאה"
                                                        message:@"לא קיים מיקרופון\nאנא חבר אוזניות בכדי לתרגל"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == DEMO_ACTIVE) {
        [self.lesson playLessonFromStart];
        [self showPlayButton];
        [self clearLessonColor];
        [self.textView scrollRectToVisible:CGRectMake(0.f, 0.f, 1.f, 1.f) animated:YES];
    }
    else
        self.alertOnScreen = NO;
}

- (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;

    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }

    return topController;
}


- (void)showGroupImageView
{
    self.navigationItem.hidesBackButton = YES;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }

    NSString *imagePath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    [self loadLessonSettingsFromCoreData];
    User *user = [[Settings sharedInstance] loadUserFromCoreData];
    if ([self.lessonClip.teacherGroupId isEqualToString:user.groupId])
    {
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:user.groupId];
        imagePath = [documentsDirectory stringByAppendingPathComponent:@"group.jpg"];
    }
    else if ([self.lessonClip.teacherParentGroupId isEqualToString:user.parentGroupId])
    {
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:user.parentGroupId];
        imagePath = [documentsDirectory stringByAppendingPathComponent:@"parentgroup.jpg"];
    }
    else
    {
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:user.contentWorldId];
        imagePath = [documentsDirectory stringByAppendingPathComponent:@"splash.jpg"];
    }

    self.userGroupImageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UserGroupImageViewController"];
    self.userGroupImageViewController.image = [UIImage imageWithContentsOfFile:imagePath];

    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
    {
        self.userGroupImageViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    else
    {
        [self topMostController].modalPresentationStyle = UIModalPresentationCurrentContext;
    }
    [[self topMostController] presentViewController:self.userGroupImageViewController animated:NO completion:nil];
    [self performSelector:@selector(setupView) withObject:nil afterDelay:3.f];
}

-(void)closeViewController:(id)sender
{
    if (self.lesson)
    {
        if (self.lessonClip)
        {
            [self.lesson saveCurrentItems:NO withStep2:NO];
        }
    }
    [self.alertView removeFromSuperview];
    [self.lessonSettingsFontSizeView removeFromSuperview];
    [self.lessonTextSettingsView removeFromSuperview];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)setupView
{
    self.lessonTextSettingsView.layer.masksToBounds = YES;
    UIImage *backImage;
    if ([self.navigationController.viewControllers[0] isKindOfClass:[FavoriteViewController class]])
    {
        backImage = [UIImage imageNamed:@"btn_HeaderFav_selected.png"];
    }
    else
    {
        backImage = [UIImage imageNamed:@"btn_HeaderMenu_normal.png"];
    }

    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(closeViewController:)];
    self.navigationItem.leftBarButtonItem = back;

    self.navigationItem.hidesBackButton = NO;

    [self.userGroupImageViewController fadeout:^{
        [self dismissViewControllerAnimated:NO completion:nil];
    }];

    self.title = self.lessonName;
    [self.lessonSettingsFontSizeView createRadiusUpperCorner];

    self.lessonSettingsFontSizeView.backgroundColor = [UIColor colorWithRed:23.f/255.f green:49.f/255.f blue:62.f/255.f alpha:0.85f];
    self.lessonSettingsFontSizeView.layer.shadowOffset = CGSizeZero;
    self.lessonSettingsFontSizeView.layer.shadowRadius = 8.;
    self.lessonSettingsFontSizeView.layer.shadowOpacity = 0.5;

    self.alertView = [[AlertBackgroundWindow alloc] initWithFrame:self.parentViewController.view.frame];
    self.alertView.alpha = 0.f;
    self.alertView.light = 1;
    self.alertView.delegate = self;
    self.alertView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.6f];
    [self.parentViewController.view addSubview:self.alertView];
    [self.parentViewController.view addSubview:self.lessonTextSettingsView];
    self.lessonSettingsFontSizeView.frame = (CGRect) {.origin.x = 0. , .origin.y = CGRectGetHeight(self.parentViewController.view.frame) , .size = self.lessonSettingsFontSizeView.frame.size};
    [self.parentViewController.view addSubview:self.lessonSettingsFontSizeView];

    [self.lessonTextSettingsOption1 setImage:[UIImage imageNamed:@"btn_A4_on.png"] forState:UIControlStateNormal];



    // Settings
    self.menuView.layer.cornerRadius = 5.f;
    self.menuView.layer.masksToBounds = YES;
    self.mic = [[UIImageView alloc] initWithFrame:CGRectMake(4.f, 0.f, 32.f, 32.f)];
    self.mic.image = [UIImage imageNamed:@"mic_button.png"];
    [self.menuView addSubview:self.mic];

    self.textView.delegate = self;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.textView.contentInset = UIEdgeInsetsMake(0.f, 0.f, 20.f, 0.f);
        [self.textView setScrollIndicatorInsets:UIEdgeInsetsMake(0.f, 0.f, 20.f, 0.f)];
    }
    else
    {
        self.textView.contentInset = UIEdgeInsetsMake(0.f, 0.f, 40.f, 0.f);
        [self.textView setScrollIndicatorInsets:UIEdgeInsetsMake(0.f, 0.f, 40.f, 0.f)];
    }

    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textView.showsVerticalScrollIndicator = YES;
    self.textView.showsHorizontalScrollIndicator = NO;
    self.textView.alwaysBounceVertical = YES;
    self.volumeSlider.transform = CGAffineTransformMakeRotation(DegreeToRadian(-90));

    [self.cancelButton setTitle:[[Settings sharedInstance] getStringByName:@"playlesson_cancel"] forState:UIControlStateNormal];
    [self.doneButton setTitle:[[Settings sharedInstance] getStringByName:@"playlesson_okay"] forState:UIControlStateNormal];

    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textViewTap:)];
	[_textView addGestureRecognizer:tap1];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 1; //seconds
    longPress.delegate = self;
    [self.textView addGestureRecognizer:longPress];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *jsonFilePath = [documentsDirectory stringByAppendingPathComponent:[self.fileName stringByAppendingString:@".json"]];
    [self loadNikudAndTeamim];
    [self loadJSON:jsonFilePath];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.lastWord = nil;
    self.currentSection = nil;
    [self hideMenu];
    [self.lesson pause];
    self.lesson = nil;
    [self showPlayButton];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    [self registerObservers];
    self.navigationItem.hidesBackButton = YES;
    [self performSelector:@selector(showGroupImageView) withObject:nil afterDelay:0.4f];
}

- (void)addButtonToView:(UIButton*)button
{
    button.frame = CGRectMake(self.lastPlaceX, 7.f, 54.f, 34.f);
    button.hidden = NO;
    self.lastPlaceX += 60.f;
}

- (void)centerHelperView:(NSInteger)numberOfButtons
{
    if (numberOfButtons)
    {
        self.lessonTextSettingsHelperView.frame = CGRectMake(0.f, 0.f, (60.f*numberOfButtons)-6, 48.f);
        CGRect rect = self.lessonTextSettingsHelperView.frame;
        rect.size.width = (60.f*numberOfButtons)+ 18;
        self.lessonTextSettingsLevel1ImageView.frame = rect;
        self.lessonTextSettingsLevel1ImageView.center = CGPointMake(130.f, 24.f);
        self.lessonTextSettingsHelperView.center = CGPointMake(130.f, 24.f);
    }
    else
    {
        CGRect rect = self.lessonTextSettingsView.frame;
        rect.size.height = 44.f*3;
        self.lessonTextSettingsView.frame = rect;
    }
}

- (void)setupLessonTextSettingsPopupView
{
    UIImage *image = [UIImage imageNamed:@"SmallMenu_BG.png"];
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 12.0f, 0.0f, 12.0f);
    self.lessonTextSettingsLevel1ImageView.image = [image resizableImageWithCapInsets:insets];
    self.lessonTextSettingsLevel2ImageView.image = [image resizableImageWithCapInsets:insets];
    self.lastPlaceX = 0.f;

    if (![self.lessonClip.lessonNikudActive boolValue] && ![self.lessonClip.lessonTeamimActive boolValue])
    {
        self.lessonTextSettingsLevel1ImageView.hidden = YES;
        [self centerHelperView:0];
    }
    else if ([self.lessonClip.lessonNikudActive boolValue] && ![self.lessonClip.lessonTeamimActive boolValue])
    {
        [self addButtonToView:self.lessonTextSettingsOption1];
        [self addButtonToView:self.lessonTextSettingsOption2];
        [self centerHelperView:2];
    }
    else if (![self.lessonClip.lessonNikudActive boolValue] && [self.lessonClip.lessonTeamimActive boolValue])
    {
        [self addButtonToView:self.lessonTextSettingsOption1];
        [self addButtonToView:self.lessonTextSettingsOption3];
        [self centerHelperView:2];
    }
    else if ([self.lessonClip.lessonNikudActive boolValue] && [self.lessonClip.lessonTeamimActive boolValue])
    {
        [self addButtonToView:self.lessonTextSettingsOption1];
        [self addButtonToView:self.lessonTextSettingsOption2];
        [self addButtonToView:self.lessonTextSettingsOption3];
        [self addButtonToView:self.lessonTextSettingsOption4];
        [self centerHelperView:4];
    }

    [self.lessonPlaySettingsOption1 setTitle:[[Settings sharedInstance] getStringByName:@"playlesson_all"] forState:UIControlStateNormal];
    [self.lessonPlaySettingsOption2 setTitle:[[Settings sharedInstance] getStringByName:@"playlesson_paragraph"] forState:UIControlStateNormal];
    [self.lessonPlaySettingsOption3 setTitle:[[Settings sharedInstance] getStringByName:@"playlesson_sentence"] forState:UIControlStateNormal];
    [self.lessonPlaySettingsOption4 setTitle:[[Settings sharedInstance] getStringByName:@"playlesson_section"] forState:UIControlStateNormal];

    if ([[Settings sharedInstance].currentLanguage isEqualToString:@"he_il"])
    {
        [self.lessonTextSettingsFontSizeButton setImage:[UIImage imageNamed:@"btn_AA_heb.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.lessonTextSettingsFontSizeButton setImage:[UIImage imageNamed:@"btn_AA.png"] forState:UIControlStateNormal];
    }
}

- (void)updateLessonSettingsFromCoreData
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Clip"];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", self.lessonDictionary[@"identifier"]];
    [request setPredicate:predicate];

    [request setFetchLimit:1];

    NSError *error = nil;

    NSArray *items = [self.managedObjectContext executeFetchRequest:request error:&error];

    if ([items count])
    {
        self.lessonClip = items[0];
    }
}

- (void)loadLessonSettingsFromCoreData
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Clip"];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", self.lessonDictionary[@"identifier"]];
    [request setPredicate:predicate];

    [request setFetchLimit:1];

    NSError *error = nil;

    NSArray *items = [self.managedObjectContext executeFetchRequest:request error:&error];

    if ([items count])
    {
        self.lessonClip = items[0];

        if (self.lessonClip.lessonFontSize)
        {
            self.lessonSettingsStartFontSize = [self.lessonClip.lessonFontSize integerValue];
        }
        if (self.lessonClip.showHighlightedWords)
        {
            ShowHighlightedWordsType tmpShowHighlightedWordType = [self.lessonClip.showHighlightedWords integerValue];
            self.showHighlightedWords = tmpShowHighlightedWordType;
        }

        self.arrowDirectionType = [self.lessonClip.arrowDirectionType integerValue];;
        [self showPlayButton];

        if (self.lessonClip.defaultVoicePromptsId)
        {
            [[Settings sharedInstance] loadVoicePromptsFromCoreData:self.lessonClip.defaultVoicePromptsId];
        }
        [self setupLessonTextSettingsPopupView];
    }
}

-(void) updateTextFontSize:(CGFloat)fontSize
{
    [self.lessonString beginEditing];
    __weak typeof(&*self)weakSelf = self;
    [self.lessonString enumerateAttribute:NSFontAttributeName
                                  inRange:NSMakeRange(0, [self.lessonString length])
                                  options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                               usingBlock:^(id value, NSRange range, BOOL *stop)
    {
        CTFontRef font = (__bridge_retained CTFontRef)value;
        CTFontRef newfont = CTFontCreateCopyWithAttributes(font, CTFontGetSize(font) + fontSize, NULL, NULL);
        [weakSelf.lessonString removeAttribute:NSFontAttributeName range:range];
        [weakSelf.lessonString addAttribute:NSFontAttributeName value:CFBridgingRelease(newfont) range:range];
        CFRelease(font);
    }];
    [self.lessonString endEditing];
    self.textView.attributedString = self.lessonString;
    self.sectionString = self.lessonString;
    [self.textView relayoutText];
//    [self checkX];
}

-(void) generateText:(NSString*)filePath
{
    CGSize maxImageSize = CGSizeMake(self.view.bounds.size.width - 20.0, self.view.bounds.size.height - 20.0);

	// example for setting a willFlushCallback, that gets called before elements are written to the generated attributed string
//	void (^callBackBlock)(DTHTMLElement *element) = ^(DTHTMLElement *element) {
//
//		// the block is being called for an entire paragraph, so we check the individual elements
//
//		for (DTHTMLElement *oneChildElement in element.childNodes)
//		{
//			// if an element is larger than twice the font size put it in it's own block
//			if (oneChildElement.displayStyle == DTHTMLElementDisplayStyleInline && oneChildElement.textAttachment.displaySize.height > 2.0 * oneChildElement.fontDescriptor.pointSize)
//			{
//				oneChildElement.displayStyle = DTHTMLElementDisplayStyleBlock;
//				oneChildElement.paragraphStyle.minimumLineHeight = element.textAttachment.displaySize.height;
//				oneChildElement.paragraphStyle.maximumLineHeight = element.textAttachment.displaySize.height;
//			}
//		}
//	};


//    CGFloat fontSizeMultiplier = 1.2;
//    NSString * fontName = @"Arial";
//    NSMutableDictionary* options = nil;

//    options = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:fontSizeMultiplier], NSTextSizeMultiplierDocumentOption,
//               fontName, DTDefaultFontFamily,
//               @"purple", DTDefaultLinkColor,
//               @"red", DTDefaultLinkHighlightColor,
//               nil];
//[options setObject:[NSNumber numberWithBool:YES] forKey:DTUseiOS6Attributes];

    BOOL useiOS6Feature = NO;

    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        useiOS6Feature = YES;
    }


	NSDictionary *options = @{ NSTextSizeMultiplierDocumentOption: @(1.0),
                               DTMaxImageSize :[NSValue valueWithCGSize:maxImageSize],
                               DTDefaultFontFamily : @"Times New Roman",
                               DTDefaultLinkColor : @"purple",
                               DTDefaultLinkHighlightColor : @"red",
                               DTDefaultTextColor : [UIColor blackColor],
//                               DTWillFlushBlockCallBack : callBackBlock,
                               DTUseiOS6Attributes : @(useiOS6Feature),
                               NSBaseURLDocumentOption : [NSURL fileURLWithPath:filePath] };

    DTHTMLAttributedStringBuilder *attrString = [[DTHTMLAttributedStringBuilder alloc] initWithHTML:self.lessonData
                                                                                            options:options
                                                                                 documentAttributes:NULL];


//    NSDictionary *attributes = [[attrString generatedAttributedString] attributesAtIndex:0 effectiveRange:NULL];
//    DTCoreTextFontDescriptor *fontDescriptor = [attributes fontDescriptor];

//    NSMutableAttributedString *tmp = [[attrString generatedAttributedString] mutableCopy];
//    [tmp enumerateAttributesInRange:NSMakeRange(0, [tmp length])
//                            options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
//                         usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
//    {
//        if (range.length == 1)
//        {
//            [tmp deleteCharactersInRange:NSMakeRange(range.location,1)];
//        }
//    }];
//
//    [tmp enumerateAttributesInRange:NSMakeRange(0, [tmp length])
//                            options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
//                         usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
//     {
////         NSLog(@"%@ %lu %lu",attrs,(unsigned long)range.location,(unsigned long)range.length);
//     }];


    self.textView.attributedString = nil;
    self.lessonData = nil;
    self.textView.attributedString = [attrString generatedAttributedString];
    self.lessonString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedString];
    self.sectionString = [[NSMutableAttributedString alloc] initWithAttributedString:self.lessonString];
    [self.HUD hide:YES];
    [self updateHTML];
    if (self.lessonSettingsStartFontSize != 0)
    {
        [self updateTextFontSize:self.lessonSettingsStartFontSize];
    }
//    else
//    {
//        [self performSelector:@selector(checkX) withObject:nil afterDelay:0.4f];
//    }
}

//- (void)checkX
//{
//    return;
//    if (self.textView.contentSize.height < self.textView.frame.size.height)
//    {
//        CGSize size = self.textView.contentSize;
//
//        CGFloat delta = 1;
////        (self.textView.frame.size.height - size.height)+1;
//
//        size.height = self.textView.frame.size.height+delta;
//        self.textView.contentSize = size;
//    }
//}

-(void) loadHTML:(NSString*)txtFilePath
{
    dispatch_queue_t queue = dispatch_queue_create("com.natan.mymentor.loadhtml", NULL);
    dispatch_async(queue, ^{
        NSString *html = [NSString stringWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:NULL];
        self.lessonData = [[NSData alloc] initWithData:[html dataUsingEncoding:NSUTF8StringEncoding]];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self generateText:txtFilePath];
        });
    });
}

-(void)loadJSON:(NSString*)jsonFilePath
{
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonFilePath options:0 error:NULL];
    CocoaSecurityResult * sha = [CocoaSecurity sha384:self.lessonClip.lessonFingerPrint];
    NSData *aesKey = [sha.data subdataWithRange:NSMakeRange(0, 32)];
    NSData *aesIv = [sha.data subdataWithRange:NSMakeRange(32, 16)];
    CocoaSecurityResult *result = [CocoaSecurity aesDecryptWithData:jsonData key:aesKey iv:aesIv];

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:result.data
                                                         options:kNilOptions
                                                           error:&error];
    self.lesson = [[Lesson alloc] init];
    self.lesson.delegate = self;
    [self.lesson createLesson:json andClip:self.lessonClip];
}

- (void)loadNikud
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *txtFilePath = [documentsDirectory stringByAppendingPathComponent:[self.fileName stringByAppendingString:@"_onlyNikud.html"]];

    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.labelText = @"מכין שיעור";
    [self loadHTML:txtFilePath];
    [self.lesson switchPlaylist:LessonTypeNikud];
}

- (void)loadTeamim
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *txtFilePath = [documentsDirectory stringByAppendingPathComponent:[self.fileName stringByAppendingString:@"_onlyTeamim.html"]];

    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.labelText = @"מכין שיעור";
    [self loadHTML:txtFilePath];
    [self.lesson switchPlaylist:LessonTypeTeamim];
}

- (void)loadClearText
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *txtFilePath = [documentsDirectory stringByAppendingPathComponent:[self.fileName stringByAppendingString:@"_clearText.html"]];

    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.labelText = @"מכין שיעור";
    [self loadHTML:txtFilePath];
    [self.lesson switchPlaylist:LessonTypeClearText];
}

- (void)loadNikudAndTeamim
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *txtFilePath = [documentsDirectory stringByAppendingPathComponent:[self.fileName stringByAppendingString:@".html"]];

    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.labelText = @"מכין שיעור";
    [self loadHTML:txtFilePath];
    [self.lesson switchPlaylist:LessonTypeNikudAndTeamim];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clearLessonColor
{
    self.textView.attributedString = self.lessonString;
//    [self checkX];
}


- (void)clearLessonSection
{
    self.textView.attributedString = self.lessonString;
    self.sectionString = self.lessonString;
//    [self checkX];
}

- (void)updateLessonSection:(NSRange)itemRange
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:self.lessonString];
    if (itemRange.length > text.length)
    {
        itemRange.length = text.length;
    }

    [text beginEditing];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        [text enumerateAttribute:NSForegroundColorAttributeName
                         inRange:itemRange
                         options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                      usingBlock:^(id value, NSRange range, BOOL *stop)
         {
             [text removeAttribute:NSForegroundColorAttributeName range:range];
             [text addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:range];
         }];

    }
    else
    {
        [text enumerateAttribute:(id)kCTForegroundColorAttributeName
                         inRange:itemRange
                         options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                      usingBlock:^(id value, NSRange range, BOOL *stop)
         {
             [text removeAttribute:(id)kCTForegroundColorAttributeName range:range];
             [text addAttribute:(id)kCTForegroundColorAttributeName value:(__bridge id)[UIColor greenColor].CGColor range:range];
         }];
    }
    [text endEditing];

    self.textView.attributedString = text;
//    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
//    {
//        [self updateTextFontSize:self.lessonSettingsStartFontSize];
//    }

    self.sectionString = text;
//    [self checkX];
}

- (void)clearLessonWord
{
    NSRange itemRangeSection = NSMakeRange(self.currentSection.charStartIndex, self.currentSection.charEndIndex);
    [self updateLessonSection:itemRangeSection];
}

- (void)updateLessonWord:(NSRange)itemRange
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:self.sectionString];

    if (itemRange.length > text.length)
    {
        itemRange.length = text.length;
    }

    [text beginEditing];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        [text enumerateAttribute:NSForegroundColorAttributeName
                         inRange:itemRange
                         options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                      usingBlock:^(id value, NSRange range, BOOL *stop)
         {
             [text removeAttribute:NSForegroundColorAttributeName range:range];
             [text addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
         }];
    }
    else
    {
        [text enumerateAttribute:(id)kCTForegroundColorAttributeName
                         inRange:itemRange
                         options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                      usingBlock:^(id value, NSRange range, BOOL *stop)
         {
             [text removeAttribute:(id)kCTForegroundColorAttributeName range:range];
             [text addAttribute:(id)kCTForegroundColorAttributeName value:(id)[UIColor redColor].CGColor range:range];
         }];
    }
    [text endEditing];
    self.textView.attributedString = text;
}

- (void)toggleMicState
{
    if(self.toggleMic)
    {
        [UIView animateWithDuration:0.6f
                              delay:0.1f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^
         {
             self.mic.alpha = 1.0f;
         }
                         completion:^(BOOL finished)
         {

         }];
    }
    else
    {
        [UIView animateWithDuration:0.6f
                              delay:0.1f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^
         {
             self.mic.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {

         }];
    }
    self.toggleMic = !self.toggleMic;
}

- (void)updateLessonColor:(NSRange)itemRange
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:self.lessonString];

    if (itemRange.length > text.length)
    {
        itemRange.length = text.length;
    }

    [text beginEditing];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        [text addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:itemRange];
    }
    else
    {
        [text addAttribute:(id)kCTForegroundColorAttributeName value:(id)[UIColor greenColor].CGColor range:itemRange];
    }
    [text endEditing];
    self.textView.attributedString = text;
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame
{
	NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:NULL];

	NSURL *URL = [attributes objectForKey:DTLinkAttribute];
	NSString *identifier = [attributes objectForKey:DTGUIDAttribute];


	DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
	button.URL = URL;
	button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
	button.GUID = identifier;

	// get image with normal link text
	UIImage *normalImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDefault];
	[button setImage:normalImage forState:UIControlStateNormal];

	// get image for highlighted link text
	UIImage *highlightImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDrawLinksHighlighted];
	[button setImage:highlightImage forState:UIControlStateHighlighted];

	// use normal push action for opening URL
	[button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];

	// demonstrate combination with long press
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)];
	[button addGestureRecognizer:longPress];

	return button;
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame
{
    if ([attachment isKindOfClass:[DTImageTextAttachment class]])
	{
		// if the attachment has a hyperlinkURL then this is currently ignored
		DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
		imageView.delegate = self;

		// sets the image if there is one
		imageView.image = [(DTImageTextAttachment *)attachment image];

		// url for deferred loading
		imageView.url = attachment.contentURL;

		// if there is a hyperlink then add a link button on top of this image
		if (attachment.hyperLinkURL)
		{
			// NOTE: this is a hack, you probably want to use your own image view and touch handling
			// also, this treats an image with a hyperlink by itself because we don't have the GUID of the link parts
			imageView.userInteractionEnabled = YES;

			DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:imageView.bounds];
			button.URL = attachment.hyperLinkURL;
			button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
			button.GUID = attachment.hyperLinkGUID;

			// use normal push action for opening URL
			[button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];

			// demonstrate combination with long press
			UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)];
			[button addGestureRecognizer:longPress];

			[imageView addSubview:button];
		}

		return imageView;
	}
	return nil;
}

- (BOOL)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView shouldDrawBackgroundForTextBlock:(DTTextBlock *)textBlock frame:(CGRect)frame context:(CGContextRef)context forLayoutFrame:(DTCoreTextLayoutFrame *)layoutFrame
{
	UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(frame,1,1) cornerRadius:10];

	CGColorRef color = [textBlock.backgroundColor CGColor];
	if (color)
	{
		CGContextSetFillColorWithColor(context, color);
		CGContextAddPath(context, [roundedRect CGPath]);
		CGContextFillPath(context);

		CGContextAddPath(context, [roundedRect CGPath]);
		CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
		CGContextStrokePath(context);
		return NO;
	}

	return YES; // draw standard background
}

#pragma mark - DTLazyImageViewDelegate

- (void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size {
	NSURL *url = lazyImageView.url;
	CGSize imageSize = size;

	NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];

	BOOL didUpdate = NO;

	// update all attachments that matchin this URL (possibly multiple images with same size)
    for (DTTextAttachment *oneAttachment in [_textView.attributedTextContentView.layoutFrame textAttachmentsWithPredicate:pred])
	{
		// update attachments that have no original size, that also sets the display size
		if (CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero))
		{
			oneAttachment.originalSize = imageSize;

			didUpdate = YES;
		}
	}

	if (didUpdate)
	{
		// layout might have changed due to image sizes
		[_textView relayoutText];
	}
}

-(void) showRecordingOn
{
    [self.recordButton setBackgroundColor:[UIColor redColor]];
}

-(void) showRecordingOff
{
    [self.recordButton setBackgroundColor:[UIColor clearColor]];
}

- (void)showLessonEndAlertView:(BOOL)showSaveUserAudioFiles
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:nil];
    __weak __typeof(&*self)weakSelf = self;
    __block BOOL saveUserAudio = NO;

    if (showSaveUserAudioFiles)
    {
        [alertView addButtonWithTitle:nil
                                 type:SIAlertViewButtonTypeSave
                         appAudioType:AppNoAudio
                              handler:^(SIAlertView *alertView)
         {
             saveUserAudio = YES;
         }];
    }

    [alertView addButtonWithTitle:nil
                             type:SIAlertViewButtonTypeCancel
                     appAudioType:AppAudioCancel
                          handler:^(SIAlertView *alertView)
     {
         [weakSelf.lesson saveCurrentItems:saveUserAudio withStep2:[self.lessonClip.saveUserAudio boolValue]];
         [weakSelf.lesson playCurrentStep:3];
     }];
    [alertView addButtonWithTitle:nil
                             type:SIAlertViewButtonTypeDestructive
                     appAudioType:AppAudioEndOfLesson
                          handler:^(SIAlertView *alertView)
     {
         [weakSelf.lesson saveCurrentItems:saveUserAudio withStep2:[self.lessonClip.saveUserAudio boolValue]];
         [weakSelf endLesson:nil];
     }];
    alertView.titleColor = [UIColor blueColor];
    alertView.cornerRadius = 10;
    alertView.buttonFont = [UIFont boldSystemFontOfSize:15];
    alertView.transitionStyle = SIAlertViewTransitionStyleFade;
    [alertView show:YES];
}

- (void)showAlertView:(BOOL)saveUserAudioFiles
{
    [[Settings sharedInstance] setIdletimer:YES];
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:nil];
    __weak __typeof(&*self)weakSelf = self;
    __block BOOL saveUserAudio = NO;

    if (saveUserAudioFiles)
    {
        [alertView addButtonWithTitle:nil
                                 type:SIAlertViewButtonTypeSave
                         appAudioType:AppNoAudio
                              handler:^(SIAlertView *alertView)
         {
             saveUserAudio = YES;
         }];
    }

    [alertView addButtonWithTitle:nil
                             type:SIAlertViewButtonTypeCancel
                     appAudioType:AppAudioCancel
                          handler:^(SIAlertView *alertView)
    {
        [weakSelf.lesson saveCurrentItems:saveUserAudio withStep2:[self.lessonClip.saveUserAudio boolValue]];
        [weakSelf.lesson playCurrentStep:1];
    }];
    [alertView addButtonWithTitle:nil
                             type:SIAlertViewButtonTypeDefault
                     appAudioType:AppAudioOK
                          handler:^(SIAlertView *alertView)
    {
        [weakSelf.lesson saveCurrentItems:saveUserAudio withStep2:[self.lessonClip.saveUserAudio boolValue]];
        [weakSelf.lesson playCurrentStep:0];
    }];

    [alertView addButtonWithTitle:nil
                             type:SIAlertViewButtonTypeDestructive
                     appAudioType:AppAudioEndOfLesson
                          handler:^(SIAlertView *alertView)
    {
        [weakSelf.lesson saveCurrentItems:saveUserAudio withStep2:[self.lessonClip.saveUserAudio boolValue]];
        [weakSelf endLesson:nil];
    }];
    alertView.titleColor = [UIColor blueColor];
    alertView.cornerRadius = 10;
    alertView.buttonFont = [UIFont boldSystemFontOfSize:15];
    alertView.transitionStyle = SIAlertViewTransitionStyleFade;
    [alertView show:YES];
    [[Settings sharedInstance] setIdletimer:NO];
}

- (void)showMenu
{
    if (self.menuAnimationActive)
        return;

    if (self.menuStatus)
        return;

    BOOL headset = [[AudioPlayer sharedInstance] headsetActive];
    BOOL bluetooth = [[AudioPlayer sharedInstance] bluetoothActive];
    BOOL hdmi = [[AudioPlayer sharedInstance] hdmiActive];

    if (!headset && !bluetooth && !hdmi)
        return;

    self.mic.hidden = YES;
    self.menuStatus = YES;
    self.menuView.hidden = NO;
    self.menuAnimationActive = YES;
    [UIView animateWithDuration:0.2f
                          delay:0.f
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseIn
                     animations:^
    {
        self.menuView.frame = CGRectOffset(self.menuView.frame, +40.f, 0.f);
    }
                     completion:^(BOOL finished)
    {
        if (!headset && !bluetooth && !hdmi)
        {
            self.volumeSlider.userInteractionEnabled = NO;
        }
        else
        {
            self.volumeSlider.userInteractionEnabled = YES;
        }
        self.menuAnimationActive = NO;
    }];
}

- (void)hideMenu
{
    if (self.menuAnimationActive)
        return;

    if (!self.menuStatus)
        return;

    self.menuStatus = NO;
    self.menuAnimationActive = YES;
    [UIView animateWithDuration:0.2f
                          delay:0.f
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseIn
                     animations:^
     {
         self.menuView.frame = CGRectOffset(self.menuView.frame, -40.f, 0.f);
     }
                     completion:^(BOOL finished)
     {
         self.menuView.hidden = YES;
        self.menuAnimationActive = NO;

         self.blinkingTimerMic = nil;
     }];
}

- (void)pause
{
    if ([self.lesson isPlaying])
    {
        [self.lesson pause];
        [self showPlayButton];
    }
}

- (void)clearLessonTextSettingsButtons
{
    [self.lessonTextSettingsOption1 setImage:[UIImage imageNamed:@"btn_A4_off.png"] forState:UIControlStateNormal];
    [self.lessonTextSettingsOption2 setImage:[UIImage imageNamed:@"btn_A2_off.png"] forState:UIControlStateNormal];
    [self.lessonTextSettingsOption3 setImage:[UIImage imageNamed:@"btn_A3_off.png"] forState:UIControlStateNormal];
    [self.lessonTextSettingsOption4 setImage:[UIImage imageNamed:@"btn_A1_off.png"] forState:UIControlStateNormal];
}

#pragma mark - IBAction

- (void)endLesson:(id)sender
{
    self.lastWord = nil;
    self.currentSection = nil;
    [self hideMenu];
    [self.lesson pause];
    self.lesson = nil;
    [self showPlayButton];
    [self.alertView removeFromSuperview];
    [self.lessonSettingsFontSizeView removeFromSuperview];
    [self.lessonTextSettingsView removeFromSuperview];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)lessonSettingsButtonTouchUpInside:(id)sender
{
    SWRevealViewController *revealViewController = self.revealViewController;

    if (!self.menuOpen)
    {
        [self pause];
        UINavigationController *navController1 = [self.storyboard instantiateViewControllerWithIdentifier:@"LessonSettingsStoryBoardIdentifier"];
        LessonSettingsViewController *lessonSettingViewController = (LessonSettingsViewController*)navController1.viewControllers[0];
        UINavigationController *navController2 = [self.storyboard instantiateViewControllerWithIdentifier:@"LessonAdvanceSettingsStoryBoardIdentifier"];
        LessonAdvanceTableViewController *lessonAdvanceTableSettings = (LessonAdvanceTableViewController*)navController2.viewControllers[0];


        lessonSettingViewController.delegate = self;
        self.childController = [[SWRevealViewController alloc] init];
        self.childController.frontViewController = navController1;
        self.childController.rightViewController = navController2;
        revealViewController.rightViewController = self.childController;

        [self loadLessonSettingsFromCoreData];
        lessonSettingViewController.clip = self.lessonClip;
        lessonAdvanceTableSettings.clip = self.lessonClip;
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
        [self updateLessonSettingsFromCoreData];
        [self updateLessonSettings];
        self.menuOpen = NO;
        self.view.userInteractionEnabled = YES;
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
        {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
        [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
    }
}

- (IBAction)pressPlay:(id)sender
{
    if ([self.lesson isPlaying])
    {
        [self.lesson pause];
        [self showPlayButton];
    }
    else
    {
        if (![[UIDevice currentDevice] isCurrentDeviceHardwareBetterThan:IPOD_TOUCH_3G])
        {
            if (![self.lesson checkForMic])
            {
                [self showMessage];
                return;
            }
        }

        [self.lesson play];
        [self.playButton setImage:[UIImage imageNamed:@"menu_pause_button.png"] forState:UIControlStateNormal];
    }    
}

- (IBAction)pressForward:(id)sender
{
    self.lastWord = nil;
    self.currentSection = nil;
    [self.playButton setImage:[UIImage imageNamed:@"menu_pause_button.png"] forState:UIControlStateNormal];


    if (self.arrowDirectionType == ArrowDirectionTypeLeft)
        [self.lesson playPreviousStep];
    else
        [self.lesson playNextStep];
}

- (IBAction)pressBackward:(id)sender
{
    self.lastWord = nil;
    self.currentSection = nil;
    [self.playButton setImage:[UIImage imageNamed:@"menu_pause_button.png"] forState:UIControlStateNormal];

    if (self.arrowDirectionType == ArrowDirectionTypeLeft)
        [self.lesson playNextStep];
    else
        [self.lesson playPreviousStep];
}

- (IBAction)pressNext:(id)sender
{
    self.lastWord = nil;
    self.currentSection = nil;
    [self.playButton setImage:[UIImage imageNamed:@"menu_pause_button.png"] forState:UIControlStateNormal];

    if (self.arrowDirectionType == ArrowDirectionTypeLeft)
        [self.lesson playPreviousItem];
    else
        [self.lesson playNextItem];
}

- (IBAction)pressPrevious:(id)sender
{
    self.lastWord = nil;
    self.currentSection = nil;
    [self.playButton setImage:[UIImage imageNamed:@"menu_pause_button.png"] forState:UIControlStateNormal];

    if (self.arrowDirectionType == ArrowDirectionTypeLeft)
        [self.lesson playNextItem];
    else
        [self.lesson playPreviousItem];
}

- (IBAction)pressRecord:(id)sender
{
    [self.playButton setUserInteractionEnabled:YES];
    [self.lesson externalStopRecording];
}

- (IBAction)volumeButtonDidPressed:(id)sender
{
    if (!self.blinkingTimerMic)
    {
        self.mic.hidden = NO;
        self.blinkingTimerMic = [NSTimer scheduledTimerWithTimeInterval:0.8f
                                                                 target:self
                                                               selector:@selector(toggleMicState)
                                                               userInfo:nil
                                                                repeats:YES];
    }
}

- (IBAction)pressSlider:(UISlider*)sender
{
    [self.lesson changeVolume:sender.value];
}

- (IBAction)lessonTextSettingsButtonClicked:(UIButton*)sender
{
    [self clearLessonTextSettingsButtons];
    switch (sender.tag)
    {
        case 20:
            [sender setImage:[UIImage imageNamed:@"btn_A4_on.png"] forState:UIControlStateNormal];
            [self loadNikudAndTeamim];
            break;
        case 21:
            [sender setImage:[UIImage imageNamed:@"btn_A2_on.png"] forState:UIControlStateNormal];
            [self loadNikud];
            break;
        case 22:
            [sender setImage:[UIImage imageNamed:@"btn_A3_on.png"] forState:UIControlStateNormal];
            [self loadTeamim];
            break;
        case 23:
            [sender setImage:[UIImage imageNamed:@"btn_A1_on.png"] forState:UIControlStateNormal];
            [self loadClearText];
            break;
        default:
            break;
    }
    [self hideLessonTextSettingsView];
}

- (IBAction)lessonTypeButtonClicked:(UIButton*)sender
{
    [self.lessonPlaySettingsOption1 setBackgroundImage:[UIImage imageNamed:@"btn_bg_off.png"] forState:UIControlStateNormal];
    [self.lessonPlaySettingsOption2 setBackgroundImage:[UIImage imageNamed:@"btn_bg_off.png"] forState:UIControlStateNormal];
    [self.lessonPlaySettingsOption3 setBackgroundImage:[UIImage imageNamed:@"btn_bg_off.png"] forState:UIControlStateNormal];
    [self.lessonPlaySettingsOption4 setBackgroundImage:[UIImage imageNamed:@"btn_bg_off.png"] forState:UIControlStateNormal];


    if ([[Settings sharedInstance].currentLanguage isEqual:@"he_il"])
    {
        switch (sender.tag)
        {
            case 30:
                self.itemType = ItemTypeSection;
                break;
            case 31:
                self.itemType = ItemTypeSentences;
                break;
            case 32:
                self.itemType = ItemTypeParagraph;
                break;
            case 33:
                self.itemType = ItemTypeChapter;
                break;
            default:
                break;
        }
    }
    else
    {
        switch (sender.tag)
        {
            case 30:
                self.itemType = ItemTypeChapter;
                break;
            case 31:
                self.itemType = ItemTypeParagraph;
                break;
            case 32:
                self.itemType = ItemTypeSentences;
                break;
            case 33:
                self.itemType = ItemTypeSection;
                break;
            default:
                break;
        }
    }

    switch (self.itemType)
    {
        case ItemTypeSection:
        {
            if ([self.lessonClip.lessonSwitch2_1 integerValue] > 1)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                return;
            }
            else
            {
                self.lessonClip.lessonSwitch2_1 = @((int)[self.lessonClip.lessonSwitch2_1 integerValue] | 1);
                if ([self.lessonClip.lessonSwitch2_2 integerValue] < 2)
                {
                    self.lessonClip.lessonSwitch2_2 = @((int)[self.lessonClip.lessonSwitch2_2 integerValue] & 2);
                }
                if ([self.lessonClip.lessonSwitch2_3 integerValue] < 2)
                {
                    self.lessonClip.lessonSwitch2_3 = @((int)[self.lessonClip.lessonSwitch2_3 integerValue] & 2);
                }
                if ([self.lessonClip.lessonSwitch2_4 integerValue] < 2)
                {
                    self.lessonClip.lessonSwitch2_4 = @((int)[self.lessonClip.lessonSwitch2_4 integerValue] & 2);
                }
            }
            break;
        }
        case ItemTypeSentences:
        {
            if ([self.lessonClip.lessonSwitch2_2 integerValue] > 1)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                return;
            }
            else
            {
                self.lessonClip.lessonSwitch2_2 = @((int)[self.lessonClip.lessonSwitch2_2 integerValue] | 1);
                if ([self.lessonClip.lessonSwitch2_1 integerValue] < 2)
                {
                    self.lessonClip.lessonSwitch2_1 = @((int)[self.lessonClip.lessonSwitch2_1 integerValue] & 2);
                }
                if ([self.lessonClip.lessonSwitch2_3 integerValue] < 2)
                {
                    self.lessonClip.lessonSwitch2_3 = @((int)[self.lessonClip.lessonSwitch2_3 integerValue] & 2);
                }
                if ([self.lessonClip.lessonSwitch2_4 integerValue] < 2)
                {
                    self.lessonClip.lessonSwitch2_4 = @((int)[self.lessonClip.lessonSwitch2_4 integerValue] & 2);
                }
            }
            break;
        }
        case ItemTypeParagraph:
        {
            if ([self.lessonClip.lessonSwitch2_3 integerValue] > 1)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                return;
            }
            else
            {
                self.lessonClip.lessonSwitch2_3 = @((int)[self.lessonClip.lessonSwitch2_3 integerValue] | 1);
                if ([self.lessonClip.lessonSwitch2_1 integerValue] < 2)
                {
                    self.lessonClip.lessonSwitch2_1 = @((int)[self.lessonClip.lessonSwitch2_1 integerValue] & 2);
                }
                if ([self.lessonClip.lessonSwitch2_2 integerValue] < 2)
                {
                    self.lessonClip.lessonSwitch2_2 = @((int)[self.lessonClip.lessonSwitch2_2 integerValue] & 2);
                }
                if ([self.lessonClip.lessonSwitch2_4 integerValue] < 2)
                {
                    self.lessonClip.lessonSwitch2_4 = @((int)[self.lessonClip.lessonSwitch2_4 integerValue] & 2);
                }
            }
            break;
        }
        case ItemTypeChapter:
        {
            if ([self.lessonClip.lessonSwitch2_3 integerValue] > 1)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                return;
            }
            else
            {
                self.lessonClip.lessonSwitch2_4 = @((int)[self.lessonClip.lessonSwitch2_4 integerValue] | 1);
                if ([self.lessonClip.lessonSwitch2_1 integerValue] < 2)
                {
                    self.lessonClip.lessonSwitch2_1 = @((int)[self.lessonClip.lessonSwitch2_1 integerValue] & 2);
                }
                if ([self.lessonClip.lessonSwitch2_2 integerValue] < 2)
                {
                    self.lessonClip.lessonSwitch2_2 = @((int)[self.lessonClip.lessonSwitch2_2 integerValue] & 2);
                }
                if ([self.lessonClip.lessonSwitch2_3 integerValue] < 2)
                {
                    self.lessonClip.lessonSwitch2_3 = @((int)[self.lessonClip.lessonSwitch2_3 integerValue] & 2);
                }
            }
            break;
        }
        default:
            break;
    }
    [sender setBackgroundImage:[UIImage imageNamed:@"btn_bg_on.png"] forState:UIControlStateNormal];

    [self hideLessonTextSettingsView];
    NSArray *lessonTextSettings = @[self.lessonClip.lessonSwitch2_1,
                                    self.lessonClip.lessonSwitch2_2,
                                    self.lessonClip.lessonSwitch2_3,
                                    self.lessonClip.lessonSwitch2_4];
    [self.lesson updateLessonTextSettings:lessonTextSettings];

    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error)
    {
        NSLog(@"%@",[error localizedDescription]);
    }

}

- (IBAction)fontSizeButtonTouchUpInside:(id)sender
{
    [self hideLessonTextSettingsView];
    self.lessonSettingsStartFontSize = [self.lessonClip.lessonFontSize integerValue];
    self.lessonSettingsOldFontSize = self.lessonSettingsStartFontSize;
    self.fontSizeInfoLabel.text = [NSString stringWithFormat:@"%ld",(long)self.lessonSettingsStartFontSize];
    [self showFontSizeView];
}

- (IBAction)fontSizeViewDoneButtonClicked:(id)sender
{
    self.lessonClip.lessonFontSize= @(self.lessonSettingsStartFontSize);
    [self hideFontSizeView];
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error)
    {
        NSLog(@"%@",[error localizedDescription]);
    }
}

- (IBAction)fontSizeViewCancelButtonClicked:(id)sender
{
    self.lessonClip.lessonFontSize = @(self.lessonSettingsOldFontSize);
    [self updateTextFontSize:(self.lessonSettingsOldFontSize - self.lessonSettingsStartFontSize)];
    [self hideFontSizeView];
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error)
    {
        NSLog(@"%@",[error localizedDescription]);
    }
}

- (IBAction)pressIncreaseTextSize:(id)sender
{
    self.lessonSettingsStartFontSize++;
    self.fontSizeInfoLabel.text = [NSString stringWithFormat:@"%ld",(long)self.lessonSettingsStartFontSize];
    self.lessonClip.lessonFontSize= @(self.lessonSettingsStartFontSize);
    [self updateTextFontSize:+1];
}

- (IBAction)pressDecreaseTextSize:(id)sender
{
    self.lessonSettingsStartFontSize--;
    self.fontSizeInfoLabel.text = [NSString stringWithFormat:@"%ld",(long)self.lessonSettingsStartFontSize];
    self.lessonClip.lessonFontSize= @(self.lessonSettingsStartFontSize);
    [self updateTextFontSize:-1];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kSpeakerStatusChange
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kVolumeMenuStatusChanged
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kMicStatusChange
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kHDMIActive
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];

}

@end

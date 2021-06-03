//
//  Lesson.m
//  MyMentor
//
//  Created by Walter Yaron on 5/24/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import "Lesson.h"
#import "Playlist.h"
#import "AudioPlayer.h"
#import "UserAudio.h"
#import "AppAudio.h"
#import "Clip.h"
#import "Settings.h"

@interface Lesson () <AudioPlayerDelegate,UserAudioDelegate,AppAudioDelegate>

@property (strong, nonatomic) Playlist *playlist;
@property (strong, nonatomic) Playlist *playlistNikud;
@property (strong, nonatomic) Playlist *playlistTeamim;
@property (strong, nonatomic) Playlist *playlistNikudAndTeamim;
@property (strong, nonatomic) Playlist *playlistClearText;
@property (strong, nonatomic) AudioPlayer *audioPlayer;
@property (strong, nonatomic) UserAudio *userAudio;
@property (strong, nonatomic) AppAudio *appaudio;
@property (strong, nonatomic) LessonMetadata *lastItem;
@property (strong, nonatomic) NSString *lessonID;
@property (strong, nonatomic) NSMutableArray *steps;
@property (strong, nonatomic) NSString *userFileStep2;
@property (strong, nonatomic) NSString *userFileStep4;
@property (strong, nonatomic) NSMutableArray *activeSteps;
@property (strong, nonatomic) NSMutableArray *activeSections;
@property (assign, nonatomic) NSInteger currentItemNumber;
@property (assign, nonatomic) NSInteger currentWordNumber;
@property (assign, nonatomic) LessonType currentLessonType;
@property (assign, nonatomic) CGFloat currentVolume;
@property (assign, nonatomic) NSInteger currentRepeatCount;
@property (assign, nonatomic) BOOL firstTime;
@property (assign, nonatomic) BOOL step2_1On;
@property (assign, nonatomic) BOOL step2_2On;
@property (assign, nonatomic) BOOL step2Active;
@property (assign, nonatomic) BOOL step2RecordFinish;
@property (assign, nonatomic) BOOL step4_1On;
@property (assign, nonatomic) BOOL step4_2On;
@property (assign, nonatomic) BOOL step4Active;
@property (assign, nonatomic) BOOL step4RecordFinish;
@property (assign, nonatomic) BOOL pauseWasActive;
@property (assign, nonatomic) BOOL stepWasActive;
@property (assign, nonatomic) BOOL micActive;
@property (assign, nonatomic) BOOL headsetActive;
@property (assign, nonatomic) BOOL bluetoothActive;
@property (assign, nonatomic) BOOL hdmiActive;

@end

@implementation Lesson

- (void)updateLessonTextSettings:(NSArray*)settings
{
    [settings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        self.activeSections[idx] = obj;
    }];

    [self lessonSettingsChange:kSections];
}

- (void)updateLessonSettings:(NSInteger)index withStatus:(BOOL)status
{
    switch (index)
    {
        case 10:
        {
            self.activeSteps[0] = @(status);
            break;
        }
        case 11:
        {
            self.activeSteps[1] = @(status);
            break;
        }
        case 12:
        {
            self.activeSteps[2] = @(status);
            break;
        }
        case 13:
        {
            self.activeSteps[3] = @(status);
            break;
        }
        case 14:
        {
            self.activeSteps[4] = @(status);
            break;
        }
        case 15:
        {
            self.activeSteps[5] = @(status);
            break;
        }
        case 20:
        {
            self.activeSections[0] = @(status);
            break;
        }
        case 21:
        {
            self.activeSections[1] = @(status);
            break;
        }
        case 22:
        {
            self.activeSections[2] = @(status);
            break;
        }
        case 23:
        {
            self.activeSections[3] = @(status);
            break;
        }
        default:
            break;
    }

    if (index >= 10 && index <16)
    {
        [self lessonSettingsChange:kSteps];
    }
    else if (index >= 20 && index <30)
    {
        [self lessonSettingsChange:kSections];
    }
}

- (void)lessonSettingsChange:(int)type
{
    if (type == kSteps)
    {
        [self updateSteps];
    }
    else if (type == kSections)
    {
//        [self.playlist generateLessonBySetting:self.activeSections];
        [self gotoItemByIndex:0 withForceType:ItemTypeChapter overwriteSettings:NO];
    }
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.audioPlayer = [AudioPlayer sharedInstance];
        self.audioPlayer.delegate = self;
        self.userAudio = [[UserAudio alloc] init];
        self.userAudio.delegate = self;
        self.appaudio = [[AppAudio alloc] init];
        self.appaudio.delegate = self;
        self.steps = [[NSMutableArray alloc] initWithCapacity:4];
        self.activeSteps = [[NSMutableArray alloc] initWithCapacity:6];
        self.activeSections = [[NSMutableArray alloc] initWithCapacity:4];
        self.currentItemNumber = 0;
        self.currentWordNumber = 0;
        self.currentStep = 0;
        self.currentVolume = 1.f;
        self.micActive = [[AudioPlayer sharedInstance] micActive];
        self.headsetActive = [[AudioPlayer sharedInstance] headsetActive];
        self.bluetoothActive = [[AudioPlayer sharedInstance] bluetoothActive];
        self.hdmiActive = [[AudioPlayer sharedInstance] hdmiActive];
        if (self.hdmiActive)
            self.headsetActive = YES;

        __weak Lesson *weakSelf = self;

        [[NSNotificationCenter defaultCenter] addObserverForName:kHDMIActive
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note)
         {
             weakSelf.hdmiActive = [note.object boolValue];
             weakSelf.headsetActive = [note.object boolValue];
         }];

        [[NSNotificationCenter defaultCenter] addObserverForName:kHeadsetActive
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note)
         {
             weakSelf.headsetActive = [note.object boolValue];
         }];

        [[NSNotificationCenter defaultCenter] addObserverForName:kBlueToothActive
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note)
         {
             weakSelf.bluetoothActive = [note.object boolValue];
         }];
    }
    return self;
}

- (StepType)getStepType
{
    return [self.steps[self.currentStep] integerValue];
}

- (BOOL)checkForMic
{
    return self.audioPlayer.micActive;
}

- (NSString*)documentsDirectory
{
    NSString *documents = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documents = [paths objectAtIndex:0];
    return documents;
}

- (void)createLessonSettingsWithClip:(Clip*)clip
{
    [self.activeSteps addObject:@([clip.lessonSwitch1_1 integerValue] & 1)];
    [self.activeSteps addObject:@([clip.lessonSwitch1_2 integerValue] & 1)];
    [self.activeSteps addObject:@([clip.lessonSwitch1_3 integerValue] & 1)];
    [self.activeSteps addObject:@([clip.lessonSwitch1_4 integerValue] & 1)];
    [self.activeSteps addObject:@([clip.lessonSwitch1_5 integerValue] & 1)];
    [self.activeSteps addObject:@([clip.lessonSwitch1_6 integerValue] & 1)];
    [self.activeSections addObject:@([clip.lessonSwitch2_1 integerValue] & 1)];
    [self.activeSections addObject:@([clip.lessonSwitch2_2 integerValue] & 1)];
    [self.activeSections addObject:@([clip.lessonSwitch2_3 integerValue] & 1)];
    [self.activeSections addObject:@([clip.lessonSwitch2_4 integerValue] & 1)];
}

- (void)createLesson:(NSDictionary*)data andClip:(Clip*)clip
{
    [self createLessonSettingsWithClip:clip];
    [self createSteps];
    self.playlist = [[Playlist alloc] initWithJSON:data];
    [self.playlist generateLessonBySetting:self.activeSections];
    if (self.playlist.list[1])
        [[Settings sharedInstance] setSampleText:self.playlist.list[1]];

    self.playType = [clip.playType integerValue];
    self.repeatCount = [clip.lessonRepeatCount integerValue];
    self.lessonID = [[NSString alloc] initWithString:data[@"id"]];
    self.saveUserAudioFiles = [clip.saveUserAudio boolValue];

    // create player and recorder with documents directory path
    NSString *lessonFilePath;

    if ([clip.lessonDemo boolValue])
    {
        lessonFilePath = [[self documentsDirectory] stringByAppendingPathComponent:[self.lessonID stringByAppendingString:@"_demo.mp3"]];
    }
    else
    {
        lessonFilePath = [[self documentsDirectory] stringByAppendingPathComponent:[self.lessonID stringByAppendingString:@".mp3"]];
    }
    [self.audioPlayer createPlayer:lessonFilePath];
}

- (void)switchPlaylist:(NSInteger)index
{
    self.currentLessonType = index;
}

- (void)playCurrentStep:(NSUInteger)repeat
{
    [self pause];
    if (repeat == 1)
    {
        self.currentItemNumber--;
        if ([self.steps count] > 1)
        {
            __block BOOL found = NO;
            [self.steps enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop)
            {
                if ([obj integerValue] == [Settings sharedInstance].lessonSettingsReplayLessonIndex)
                {
                    found = YES;
                    self.currentStep = idx;
                    *stop = YES;
                }
            }];
            if (!found)
                self.currentStep = [self.steps count] - 2;
        }
        else
        {
            self.currentStep = 0;
        }
    }
    if (repeat == 3)
    {
        if ([self.steps count] > 1)
        {
            __block BOOL found = NO;
            [self.steps enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop)
             {
                 if ([obj integerValue] == [Settings sharedInstance].lessonSettingsReplayLessonIndex)
                 {
                     found = YES;
                     self.currentStep = idx;
                     *stop = YES;
                 }
             }];
            if (!found)
                self.currentStep = [self.steps count] - 2;

        }
        else
        {
            self.currentStep = 0;
        }
    }

    [self playStep];
}

- (void)resetSteps
{
    self.currentStep = 0;
    [self createSteps];
}

- (void)updateSteps
{
    NSNumber *lastStep = self.steps[self.currentStep];
    NSArray *lastSteps = [[NSArray alloc] initWithArray:self.steps copyItems:YES];
    NSInteger lastCurrentStep = self.currentStep;

    [self createSteps];

    if ([self.steps count] >1)
    {
        BOOL found = NO;
        for (NSInteger i=0; i<[self.steps count]; i++)
        {
            NSNumber *tmpStep = self.steps[i];
            if ([tmpStep isEqual:lastStep])
            {
                self.currentStep = i;
                found = YES;
                break;
            }
        }

        if (!found)
        {
            if ([lastStep integerValue] < StepType4)
            {
                for (NSInteger i=0; i<[self.steps count]; i++)
                {
                    NSNumber *tmpStep = self.steps[i];
                    if (lastCurrentStep+1 < [lastSteps count]) {
                        if ([tmpStep isEqual:lastSteps[lastCurrentStep+1]])
                        {
                            self.currentStep = i;
                            break;
                        }
                    }
                    else
                    {
                        self.currentStep = 0;                        
                        break;
                    }
                }
            }
        }
    }
    else
    {
        self.currentStep = 0;
    }
    if (self.currentStep >= [self.steps count])
    {
        self.currentStep = [self.steps count]-1;
    }
    if ([self.steps[self.currentStep] integerValue] == StepType1)
    {
        self.pauseWasActive = NO;
    }
    else if ([self.steps[self.currentStep] integerValue] == StepType2)
    {
        self.step2Active = YES;
    }
    else if ([self.steps[self.currentStep] integerValue] == StepType3)
    {
        self.pauseWasActive = NO;
    }
    else if ([self.steps[self.currentStep] integerValue] == StepType4)
    {
        self.step4Active = YES;
    }
}

- (void)createSteps
{
    [self.steps removeAllObjects];
    self.step2_1On = NO;
    self.step4_1On = NO;
    if ([self.activeSteps[0] boolValue])
    {
        [self.steps addObject:@(StepType1)];
    }
    if ([self.activeSteps[1] boolValue])
    {
        self.step2_1On = YES;
        [self.steps addObject:@(StepType2)];
    }
    if ([self.activeSteps[2] boolValue])
    {
        [self.steps addObject:@(StepType3)];
    }
    if ([self.activeSteps[3] boolValue])
    {
        self.step4_1On = YES;
        [self.steps addObject:@(StepType4)];
    }
    self.step2_2On = [self.activeSteps[4] boolValue];
    self.step4_2On = [self.activeSteps[5] boolValue];
}

- (void)playLessonFromStart
{
    [self pause];
    self.currentStep = 0;
    self.currentWordNumber = 0;
    self.currentItemNumber = 0;
    self.step2Active = NO;
    self.step4Active = NO;
    self.userFileStep2 = nil;
    self.userFileStep4 = nil;
    self.pauseWasActive = NO;
    self.stepWasActive = NO;
    [self createSteps];
    [self.audioPlayer seekToTimeAndPause:kCMTimeZero];
}

- (void)resetLesson
{
    [self pause];
    self.currentStep = 0;
    self.currentWordNumber = 0;
    self.currentItemNumber = 0;
    [self createSteps];
    [self showItemOnScreen];
    [self play];
}

- (BOOL)didFinishSteps
{
    if ((self.currentStep >= [self.steps count]) || ([self.steps count] == 1))
    {
        self.currentStep = 0;
        return YES;
    }

    return NO;
}

- (void)moveToPreviousItem
{
    if (self.currentItemNumber > 0)
    {
        self.lastItem = self.playlist.list[self.currentLessonType][self.currentItemNumber];
        self.currentItemNumber--;
//        LessonMetadata *currentItem = self.playlist.list[self.currentItemNumber];
        LessonMetadata *currentItem = self.playlist.list[self.currentLessonType][self.currentItemNumber];
        if (currentItem.charStartIndex == self.lastItem.charStartIndex && currentItem.charEndIndex == self.lastItem.charEndIndex)
        {
            [self moveToPreviousItem];
        }
    }
}

- (BOOL)moveToNextItem:(BOOL)showAlert
{
    if (self.currentItemNumber +1 < [self.playlist.list[self.currentLessonType] count])
    {
        self.lastItem = self.playlist.list[self.currentLessonType][self.currentItemNumber];
        self.currentItemNumber++;
        LessonMetadata *currentItem = self.playlist.list[self.currentLessonType][self.currentItemNumber];
        if (currentItem.charStartIndex == self.lastItem.charStartIndex && currentItem.charEndIndex == self.lastItem.charEndIndex)
        {
            if ([self moveToNextItem:showAlert])
                return YES;
            return NO;
        }
        if (showAlert)
        {
            BOOL showSaveUserAudioFiles = YES;
            if (!self.step2_1On && !self.step4_1On)
                showSaveUserAudioFiles = NO;

            if (self.step2_1On && !self.step4_1On && self.saveUserAudioFiles)
                showSaveUserAudioFiles = NO;

            if ([self.delegate respondsToSelector:@selector(lessonItemFinish:)])
            {
                [self.delegate lessonItemFinish:showSaveUserAudioFiles];
            }
        }
        return NO;
    }
    else
    {
        [self.audioPlayer pause];
        self.playing = NO;
        self.step2Active = NO;
        self.step2RecordFinish = NO;
        self.step4Active = NO;
        self.step4RecordFinish = NO;
        if ([self.userAudio isRecording])
        {
            [self.userAudio stopRecording];
        }

        BOOL showSaveUserAudioFiles = YES;
        if (!self.step2_1On && !self.step4_1On)
            showSaveUserAudioFiles = NO;

        if (self.step2_1On && !self.step4_1On && self.saveUserAudioFiles)
            showSaveUserAudioFiles = NO;

        if ([self.delegate respondsToSelector:@selector(lessonEnd:)])
        {
            [self.delegate lessonEnd:showSaveUserAudioFiles];
        }
        return YES;
    }
}

- (void)playPreviousStep
{
    [self checkForDemo:^{
        [self pause];
        self.currentStep = 0;
        [self playStep];
    }];
}

- (void)playStep
{
    self.step2Active = NO;
    self.step4Active = NO;

    [self checkForDemo:^{
        switch ([self.steps[self.currentStep] integerValue])
        {
            case StepType1:
                [self playStep1AppAudio];
                break;
            case StepType2:
                [self playStep2_1AppAudio];
                break;
            case StepType3:
                [self playStep3AppAudio];
                break;
            case StepType4:
                [self playStep4AppAudio];
                break;
            default:
                break;
        }
    }];
}

- (void)playNextStep
{
    [self pause];
    self.currentStep++;
    if ([self didFinishSteps])
    {
        if (self.playType == PlayTypeUninterrupted)
        {
            self.currentRepeatCount++;
            if (self.currentRepeatCount >= self.repeatCount)
            {
                self.currentRepeatCount = 0;
                self.currentStep = 0;
                if (![self moveToNextItem:NO])
                {
                    [self saveCurrentItems:NO withStep2:NO];
                    [self playStep];
                }
            }
            else
            {
                self.currentStep = 0;
                [self playStep];
            }
        }
        else
        {
            [self moveToNextItem:YES];
        }
    }
    else
        [self playStep];
}

- (void)showItemOnScreen
{
    LessonMetadata *itemInfo = self.playlist.list[self.currentLessonType][self.currentItemNumber];
    if (itemInfo.hasWords)
    {
        self.currentWordNumber = itemInfo.wordStartIndex;
    }

    if ([self.delegate respondsToSelector:@selector(lessonShowItem:)])
    {
        [self.delegate lessonShowItem:itemInfo];
    }
}

- (void)resetWordsOnSection
{
    if ([self.delegate respondsToSelector:@selector(lessonShowWord:insideSection:)])
    {
        [self.delegate lessonShowWord:nil insideSection:nil];
    }
}

- (void)playStep1AppAudio
{
    [self checkForDemo:^{
        [self resetWordsOnSection];
        [self.audioPlayer pause];
        [self.userAudio pause];
        [self showItemOnScreen];
        self.playing = YES;
        self.stepWasActive = NO;
        [self.appaudio play:AppAudioListenToMe withItem:nil];
    }];
}

- (void)playStep2_1AppAudio
{
    [self checkForDemo:^{
        [self resetWordsOnSection];
        [self.audioPlayer pause];
        [self.userAudio pause];
        [self showItemOnScreen];
        self.playing = YES;
        self.stepWasActive = NO;
        [self.appaudio play:AppAudioReadingTogether withItem:nil];
    }];
}

- (void)playStep3AppAudio
{
    [self checkForDemo:^{
        [self resetWordsOnSection];
        [self.audioPlayer pause];
        [self.userAudio pause];
        [self showItemOnScreen];
        self.playing = YES;
        self.stepWasActive = NO;
        [self.appaudio play:AppAudioListenToMeAgain withItem:nil];
    }];
}

- (void)playStep4AppAudio
{
    [self checkForDemo:^{
        [self resetWordsOnSection];
        [self.audioPlayer pause];
        [self.userAudio pause];
        [self showItemOnScreen];
        self.playing = YES;
        self.stepWasActive = NO;
        [self.appaudio play:AppAudioNowYou withItem:nil];
    }];
}

- (void)playStep1
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kVolumeMenuStatusChanged
                                                        object:@NO
                                                      userInfo:nil];
    [self.audioPlayer changeVolume:1.f];
    [self playCurrentItem];
    self.stepWasActive = YES;
    self.step2Active = NO;
    self.step4Active = NO;
}

- (void)playStep2_1
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kVolumeMenuStatusChanged
                                                        object:@NO
                                                      userInfo:nil];
    [self.audioPlayer changeVolume:1.f];
    self.step2Active = YES;
    self.step4Active = NO;
    self.step2RecordFinish = NO;
    LessonMetadata *itemInfo = self.playlist.list[self.currentLessonType][self.currentItemNumber];
    self.userFileStep2 = [self.lessonID stringByAppendingFormat:@"%lu%lu%lu%lu%lu2.m4a",(unsigned long)itemInfo.chapter,(unsigned long)itemInfo.paragraph,(unsigned long)itemInfo.sentence,(unsigned long)itemInfo.section,(unsigned long)itemInfo.itemType];
    [self.userAudio createUserAudio:[[self documentsDirectory] stringByAppendingPathComponent:self.userFileStep2]
                       withDuration:CMTimeMake(([itemInfo.audioDuration doubleValue])*10, 10)];
    [self.userAudio startRecording];
    [self playCurrentItem];
    if ([self.delegate respondsToSelector:@selector(lessonStartRecording:)])
    {
        [self.delegate lessonStartRecording:NO];
    }
}

- (void)playStep2_2:(BOOL)reset
{
    [self resetWordsOnSection];
    [[NSNotificationCenter defaultCenter] postNotificationName:kVolumeMenuStatusChanged
                                                        object:@YES
                                                      userInfo:nil];

    [self.audioPlayer changeVolume:self.currentVolume];
    self.step2Active = NO;
    self.step4Active = NO;
    self.step2RecordFinish = YES;
    self.playing = YES;
   
    if (!reset)
    {
        [self.userAudio loadFile:[[self documentsDirectory] stringByAppendingPathComponent:self.userFileStep2]];
        [self.userAudio play:YES];
        if (!self.headsetActive && !self.bluetoothActive && !self.hdmiActive)
        {
            [self.audioPlayer changeVolume:0.f];
        }
        [self playCurrentItem];
    }
}

- (void)playStep3
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kVolumeMenuStatusChanged
                                                        object:@NO
                                                      userInfo:nil];
    [self.audioPlayer changeVolume:1.f];
    [self playCurrentItem];
    self.stepWasActive = YES;
    self.step2Active = NO;
    self.step4Active = NO;
}

- (void)playStep4_1
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kVolumeMenuStatusChanged
                                                        object:@NO
                                                      userInfo:nil];
    [[Settings sharedInstance] setIdletimer:YES];
    self.playing = YES;
    self.step2Active = NO;    
    self.step4Active = YES;
    self.step4RecordFinish = NO;
    LessonMetadata *itemInfo = self.playlist.list[self.currentLessonType][self.currentItemNumber];
    self.userFileStep4 = [self.lessonID stringByAppendingFormat:@"%lu%lu%lu%lu%lu4.m4a",(unsigned long)itemInfo.chapter,(unsigned long)itemInfo.paragraph,(unsigned long)itemInfo.sentence,(unsigned long)itemInfo.section,(unsigned long)itemInfo.itemType];
    NSLog(@"%f",CMTimeGetSeconds(CMTimeMultiplyByFloat64(CMTimeMake(([itemInfo.audioDuration doubleValue])*10, 10),1.2)));
    [self.userAudio createUserAudio:[[self documentsDirectory] stringByAppendingPathComponent:self.userFileStep4]
                       withDuration:CMTimeMultiplyByFloat64(CMTimeMake(([itemInfo.audioDuration doubleValue])*10, 10),1.2)];
    [self.userAudio startRecording];
    [self.audioPlayer changeVolume:0.f];
    [self playCurrentItem];
    self.recording = YES;
    if ([self.delegate respondsToSelector:@selector(lessonStartRecording:)])
    {
        [self.delegate lessonStartRecording:YES];
    }
}

- (void)playStep4_2:(BOOL)reset
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kVolumeMenuStatusChanged
                                                        object:@NO
                                                      userInfo:nil];
    [self showItemOnScreen];
//    if ([self.delegate respondsToSelector:@selector(lessonEndRecording)])
//    {
//        [self.delegate lessonEndRecording];
//    }
    self.playing = YES;
    self.step2Active = NO;    
    self.step4Active  = NO;
    self.step4RecordFinish = YES;
    if (!reset)
    {
        [self resetWordsOnSection];
        [self.audioPlayer changeVolume:0.f];
        [self playCurrentItem];
        [self.userAudio loadFile:[[self documentsDirectory] stringByAppendingPathComponent:self.userFileStep4]];
        [self.userAudio play:YES];
    }
}

- (void)play
{
    [[Settings sharedInstance] setIdletimer:YES];
    switch ([self.steps[self.currentStep] integerValue])
    {
        case StepType1:
        {
            if (!self.pauseWasActive)
                [self playStep1AppAudio];
            else
            {
                if (self.stepWasActive)
                {
//                    [self checkForDemo:^{
                        [self.audioPlayer play];
//                    }];
                }
                else
                    [self playStep1];
            }
            break;
        }
        case StepType2:
        {
            if (!self.pauseWasActive)
            {
                self.step2Active = NO;
                [self playStep2_1AppAudio];
            }
            else
            {
                if (self.step2Active && !self.step2RecordFinish)
                {
                    self.step2Active = NO;
                    [self playStep2_1AppAudio];
                }
                else
                {
                    [self playStep2_2:YES];
//                    [self checkForDemo:^{
//                        [self.audioPlayer play];
//                    }];
                    [self.userAudio play:NO];
                }
            }
            break;
        }
        case StepType3:
        {
            if (!self.pauseWasActive)
                [self playStep3AppAudio];
            else
            {
                if (self.stepWasActive)
                {
//                    [self checkForDemo:^{
                        [self.audioPlayer play];
//                    }];
                }
                else
                    [self playStep3];
            }
            break;
        }
        case StepType4:
        {
            if (!self.pauseWasActive)
            {
                self.step4Active = NO;
                [self playStep4AppAudio];
            }
            else
            {
                if (self.step4Active && !self.step4RecordFinish)
                {
                    self.step4Active = NO;
                    [self playStep4AppAudio];
                }
                else
                {
                    [self playStep4_2:YES];
                    [self.userAudio play:YES];
                }
            }
            break;
        }
        default:
            break;
    }
    self.pauseWasActive = NO;

    if (!self.firstTime)
    {
        self.firstTime = YES;
        LessonMetadata *itemInfo = self.playlist.list[self.currentLessonType][self.currentItemNumber];
        if ([self.delegate respondsToSelector:@selector(lessonShowItem:)])
        {
            [self.delegate lessonShowItem:itemInfo];
        }
    }
    self.playing = YES;
}

- (void)pause
{
    [[Settings sharedInstance] setIdletimer:NO];
    self.playing = NO;
    [self.audioPlayer pause];
    [self.userAudio pause];
    if ([self.appaudio isPlaying])
        self.pauseWasActive = NO;
    else
        self.pauseWasActive = YES;
    
    [self.appaudio pause];

    if ([self.userAudio isRecording])
    {
        [self.userAudio pauseRecording];
        if ([self.delegate respondsToSelector:@selector(lessonEndRecording)])
        {
            [self.delegate lessonEndRecording];
        }
    }
}

- (void)changeVolume:(CGFloat)volume
{
    self.currentVolume = volume;
    [self.audioPlayer changeVolume:volume];
}

- (void)externalStopRecording
{
    [self.userAudio stopRecording];
}

- (void)checkForDemo:(void (^)())executeFunction
{
    LessonMetadata *currentItemInfo = self.playlist.list[self.currentLessonType][self.currentItemNumber];

    if ([currentItemInfo.audioStart doubleValue] + [currentItemInfo.audioDuration doubleValue] > [[self.audioPlayer getAudioDuration] doubleValue])
    {
        [self pause];

        if ([self.delegate respondsToSelector:@selector(lessonShowDemoMessage)])
        {
            [self.delegate lessonShowDemoMessage];
            return;
        }
    }
    else
        executeFunction();
}

- (void)playPreviousItem
{
    [self pause];
    self.currentStep = 0;
    [self saveCurrentItems:NO withStep2:NO];
    self.userFileStep2 = nil;
    self.userFileStep4 = nil;
    [self moveToPreviousItem];

    self.step2Active = NO;
    self.step4Active = NO;

    switch ([self.steps[self.currentStep] integerValue])
    {
        case StepType1:
            [self playStep1AppAudio];
            break;
        case StepType2:
            [self playStep2_1AppAudio];
            break;
        case StepType3:
            [self playStep3AppAudio];
            break;
        case StepType4:
            [self playStep4AppAudio];
            break;
        default:
            break;
    }
}

- (void)playNextItem
{
    [self pause];
    self.currentStep = 0;
    [self saveCurrentItems:NO withStep2:NO];
    self.userFileStep2 = nil;
    self.userFileStep4 = nil;
    if ([self moveToNextItem:NO])
        return;

    self.step2Active = NO;
    self.step4Active = NO;

    switch ([self.steps[self.currentStep] integerValue])
    {
        case StepType1:
            [self playStep1AppAudio];
            break;
        case StepType2:
            [self playStep2_1AppAudio];
            break;
        case StepType3:
            [self playStep3AppAudio];
            break;
        case StepType4:
            [self playStep4AppAudio];
            break;
        default:
            break;
    }
}

- (void)playCurrentItem
{
    [[Settings sharedInstance] setIdletimer:YES];
    [self checkForDemo:^{
        LessonMetadata *itemInfo = self.playlist.list[self.currentLessonType][self.currentItemNumber];

        if (itemInfo.hasWords)
        {
            self.currentWordNumber = itemInfo.wordStartIndex;
        }

        [self.audioPlayer seekToTimeAndPlay:CMTimeMake(([itemInfo.audioStart doubleValue])*10, 10)];
    }];

}

- (void)updateCurrentItem:(NSMutableArray*)settings withForceType:(ItemType)type
{
}

- (void)gotoItemByIndex:(NSUInteger)index withForceType:(ItemType)type
{
    switch (type)
    {
        case ItemTypeSection:
        {
            if ([self.activeSections[0] isEqualToNumber:@NO])
            {
                if ([self.activeSections[1] isEqualToNumber:@YES])
                {
                    type = ItemTypeSentences;
                }
                else if ([self.activeSections[2] isEqualToNumber:@YES])
                {
                    type = ItemTypeParagraph;
                }
                else if ([self.activeSections[3] isEqualToNumber:@YES])
                {
                    type = ItemTypeChapter;
                }
            }
            break;
        }
        case ItemTypeSentences:
        {
            if ([self.activeSections[1] isEqualToNumber:@NO])
            {
                if ([self.activeSections[0] isEqualToNumber:@YES])
                {
                    type = ItemTypeSection;
                }
                else if ([self.activeSections[2] isEqualToNumber:@YES])
                {
                    type = ItemTypeParagraph;
                }
                else if ([self.activeSections[3] isEqualToNumber:@YES])
                {
                    type = ItemTypeChapter;
                }
            }
            break;
        }
        case ItemTypeParagraph:
        {
            if ([self.activeSections[2] isEqualToNumber:@NO])
            {
                if ([self.activeSections[1] isEqualToNumber:@YES])
                {
                    type = ItemTypeSentences;
                }
                else if ([self.activeSections[0] isEqualToNumber:@YES])
                {
                    type = ItemTypeSection;
                }
                else if ([self.activeSections[3] isEqualToNumber:@YES])
                {
                    type = ItemTypeChapter;
                }
            }
            break;
        }
        case ItemTypeChapter:
        {
            if ([self.activeSections[3] isEqualToNumber:@NO])
            {
                if ([self.activeSections[2] isEqualToNumber:@YES])
                {
                    type = ItemTypeParagraph;
                }
                else if ([self.activeSections[1] isEqualToNumber:@YES])
                {
                    type = ItemTypeSentences;
                }
                else if ([self.activeSections[0] isEqualToNumber:@YES])
                {
                    type = ItemTypeSection;
                }
            }
            break;
        }
        default:
            break;
    }

    [self.playlist generateLessonBySetting:self.activeSections];

    __block LessonMetadata *item1=nil;

    [self.playlist.list[self.currentLessonType] enumerateObjectsUsingBlock:^(LessonMetadata *obj, NSUInteger idx, BOOL *stop)
     {
         switch (type)
         {
             case ItemTypeSentences:
             {
                 if (obj.itemType == ItemTypeSentences)
                 {
                     if (index >= obj.charStartIndex && index < (obj.charStartIndex+obj.charEndIndex))
                     {
                         item1 = obj;
                         *stop = YES;
                     }
                 }

                 break;
             }
             case ItemTypeSection:
             {
                 if (obj.itemType == ItemTypeSection)
                 {
                     if (index >= obj.charStartIndex && index < (obj.charStartIndex+obj.charEndIndex))
                     {
                         item1 = obj;
                         *stop = YES;
                     }
                 }
                 break;
             }
             case ItemTypeParagraph:
             {
                 if (obj.itemType == ItemTypeParagraph)
                 {
                     if (index >= obj.charStartIndex && index < (obj.charStartIndex+obj.charEndIndex))
                     {
                         item1 = obj;
                         *stop = YES;
                     }
                 }
                 break;
             }
             case ItemTypeChapter:
             {
                 if (obj.itemType == ItemTypeChapter)
                 {
                     if (index >= obj.charStartIndex && index < (obj.charStartIndex+obj.charEndIndex))
                     {
                         item1 = obj;
                         *stop = YES;
                     }
                 }
                 break;
             }
             default:
                 break;
         }
     }];

    if (!item1)
    return;

    __block NSUInteger itemIndex = 0;
    [self.playlist.list[self.currentLessonType] enumerateObjectsUsingBlock:^(LessonMetadata *obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj compare:item1])
         {
             itemIndex = idx;
             *stop = YES;
         }
     }];

    __block NSUInteger wordIndex = 0;

    [self.playlist.words[self.currentLessonType] enumerateObjectsUsingBlock:^(LessonMetadata *obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj compare:item1])
         {
             wordIndex = idx;
             *stop = YES;
         }
     }];

    self.currentItemNumber = itemIndex;
    self.currentStep = 0;
    self.currentWordNumber = wordIndex;
    [self pause];
    self.playing = YES;
    [self playStep];


}

- (void)gotoItemByIndex:(NSUInteger)index withForceType:(ItemType)type overwriteSettings:(BOOL)overwrite
{
    if (overwrite)
    {
        NSMutableArray *lessonSettings = [@[@NO,@NO,@NO,@NO] mutableCopy];

        if ([[Settings sharedInstance].currentLanguage isEqual:@"he_il"])
        {
            switch (type)
            {
                case ItemTypeSection:
                    lessonSettings[3] = @YES;
    //                lessonSettings[1] = @YES;
    //                lessonSettings[2] = @YES;
    //                lessonSettings[3] = @YES;
                    break;
                case ItemTypeSentences:
                    lessonSettings[2] = @YES;
    //                lessonSettings[2] = @YES;
    //                lessonSettings[3] = @YES;
                    break;
                case ItemTypeParagraph:
                    lessonSettings[1] = @YES;
    //                lessonSettings[3] = @YES;
                    break;
                case ItemTypeChapter:
                    lessonSettings[0] = @YES;
                    break;

                default:
                    break;
            }
        }
        else
        {
            switch (type)
            {
                case ItemTypeSection:
                    lessonSettings[0] = @YES;
                    //                lessonSettings[1] = @YES;
                    //                lessonSettings[2] = @YES;
                    //                lessonSettings[3] = @YES;
                    break;
                case ItemTypeSentences:
                    lessonSettings[1] = @YES;
                    //                lessonSettings[2] = @YES;
                    //                lessonSettings[3] = @YES;
                    break;
                case ItemTypeParagraph:
                    lessonSettings[2] = @YES;
                    //                lessonSettings[3] = @YES;
                    break;
                case ItemTypeChapter:
                    lessonSettings[3] = @YES;
                    break;
                    
                default:
                    break;
            }
        }

        [self.playlist generateLessonBySetting:lessonSettings];
    }
    else
    {
        LessonMetadata *item = self.playlist.list[self.currentLessonType][self.currentItemNumber];
        type = item.itemType;
        index = item.charStartIndex;

        switch (type)
        {
            case ItemTypeSection:
            {
                if ([self.activeSections[0] isEqualToNumber:@NO])
                {
                    if ([self.activeSections[1] isEqualToNumber:@YES])
                    {
                        type = ItemTypeSentences;
                    }
                    else if ([self.activeSections[2] isEqualToNumber:@YES])
                    {
                        type = ItemTypeParagraph;
                    }
                    else if ([self.activeSections[3] isEqualToNumber:@YES])
                    {
                        type = ItemTypeChapter;
                    }
                }
                break;
            }
            case ItemTypeSentences:
            {
                if ([self.activeSections[1] isEqualToNumber:@NO])
                {
                    if ([self.activeSections[0] isEqualToNumber:@YES])
                    {
                        type = ItemTypeSection;
                    }
                    else if ([self.activeSections[2] isEqualToNumber:@YES])
                    {
                        type = ItemTypeParagraph;
                    }
                    else if ([self.activeSections[3] isEqualToNumber:@YES])
                    {
                        type = ItemTypeChapter;
                    }
                }
                break;
            }
            case ItemTypeParagraph:
            {
                if ([self.activeSections[2] isEqualToNumber:@NO])
                {
                    if ([self.activeSections[1] isEqualToNumber:@YES])
                    {
                        type = ItemTypeSentences;
                    }
                    else if ([self.activeSections[0] isEqualToNumber:@YES])
                    {
                        type = ItemTypeSection;
                    }
                    else if ([self.activeSections[3] isEqualToNumber:@YES])
                    {
                        type = ItemTypeChapter;
                    }
                }
                break;
            }
            case ItemTypeChapter:
            {
                if ([self.activeSections[3] isEqualToNumber:@NO])
                {
                    if ([self.activeSections[2] isEqualToNumber:@YES])
                    {
                        type = ItemTypeParagraph;
                    }
                    else if ([self.activeSections[1] isEqualToNumber:@YES])
                    {
                        type = ItemTypeSentences;
                    }
                    else if ([self.activeSections[0] isEqualToNumber:@YES])
                    {
                        type = ItemTypeSection;
                    }
                }
                break;
            }
            default:
                break;
        }

        [self.playlist generateLessonBySetting:self.activeSections];
    }

    __block LessonMetadata *item=nil;

    [self.playlist.list[self.currentLessonType] enumerateObjectsUsingBlock:^(LessonMetadata *obj, NSUInteger idx, BOOL *stop)
     {
         switch (type)
         {
             case ItemTypeSentences:
             {
                 if (obj.itemType == ItemTypeSentences)
                 {
                     if (index >= obj.charStartIndex && index < (obj.charStartIndex+obj.charEndIndex))
                     {
                         item = obj;
                         *stop = YES;
                     }
                 }

                 break;
             }
             case ItemTypeSection:
             {
                 if (obj.itemType == ItemTypeSection)
                 {
                     if (index >= obj.charStartIndex && index < (obj.charStartIndex+obj.charEndIndex))
                     {
                         item = obj;
                         *stop = YES;
                     }
                 }
                 break;
             }
             case ItemTypeParagraph:
             {
                 if (obj.itemType == ItemTypeParagraph)
                 {
                     if (index >= obj.charStartIndex && index < (obj.charStartIndex+obj.charEndIndex))
                     {
                         item = obj;
                         *stop = YES;
                     }
                 }
                 break;
             }
             case ItemTypeChapter:
             {
                 if (obj.itemType == ItemTypeChapter)
                 {
                     if (index >= obj.charStartIndex && index < (obj.charStartIndex+obj.charEndIndex))
                     {
                         item = obj;
                         *stop = YES;
                     }
                 }
                 break;
             }
             default:
                 break;
         }
     }];

    if (!item)
        return;

    __block NSUInteger itemIndex = 0;
    [self.playlist.list[self.currentLessonType] enumerateObjectsUsingBlock:^(LessonMetadata *obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj compare:item])
         {
             itemIndex = idx;
             *stop = YES;
         }
     }];

    __block NSUInteger wordIndex = 0;

    [self.playlist.words[self.currentLessonType] enumerateObjectsUsingBlock:^(LessonMetadata *obj, NSUInteger idx, BOOL *stop)
    {
        if ([obj compare:item])
        {
            wordIndex = idx;
            *stop = YES;
        }
    }];
    
    self.currentItemNumber = itemIndex;
    self.currentStep = 0;
    self.currentWordNumber = wordIndex;
    if (overwrite)
    {
        [self pause];
        self.playing = YES;
        [self playStep];
    }
}

- (LessonMetadata*)getCurrentWordInfo
{
    LessonMetadata *wordInfo = self.playlist.words[self.currentLessonType][self.currentWordNumber];
    return wordInfo;
}

- (LessonMetadata*)getCurrentItem
{
    LessonMetadata *item = self.playlist.list[self.currentLessonType][self.currentItemNumber];
    return item;
}

- (void)saveCurrentItems:(BOOL)saveUserAudio withStep2:(BOOL)deleteStep2_2
{
    NSError *error = nil;
    NSFileManager *manager = [[NSFileManager alloc] init];
    NSString *fileName;

    if (saveUserAudio)
    {
        if (deleteStep2_2)
        {
            if (self.userFileStep2)
            {
                fileName = [[self documentsDirectory] stringByAppendingPathComponent:self.userFileStep2];
                if ([manager fileExistsAtPath:fileName])
                {
                    error = nil;
                    [manager removeItemAtPath:fileName error:&error];
                    if (error)
                    {
                        NSLog(@"error %@",error);
                    }
                }
            }
        }
    }
    else
    {
        if (self.userFileStep2)
        {
            fileName = [[self documentsDirectory] stringByAppendingPathComponent:self.userFileStep2];
            if ([manager fileExistsAtPath:fileName])
            {
                error = nil;
                [manager removeItemAtPath:fileName error:&error];
                if (error)
                {
                    NSLog(@"error %@",error);
                }
            }
        }
        if (self.userFileStep4)
        {
            fileName = [[self documentsDirectory] stringByAppendingPathComponent:self.userFileStep4];
            if ([manager fileExistsAtPath:fileName])
            {
                error = nil;
                [manager removeItemAtPath:fileName error:&error];
                if (error)
                {
                    NSLog(@"error %@",error);
                }
            }
        }
    }
    self.userFileStep2 = nil;
    self.userFileStep4 = nil;
}

#pragma mark - AudioPlayer Delegate

- (void)audioPlayerLessonEnd
{
    BOOL showSaveUserAudioFiles = YES;
    if (!self.step2_1On && !self.step4_1On)
        showSaveUserAudioFiles = NO;

    if (self.step2_1On && !self.step4_1On && self.saveUserAudioFiles)
        showSaveUserAudioFiles = NO;

    if ([self.delegate respondsToSelector:@selector(lessonEnd:)])
    {
        [self.delegate lessonEnd:showSaveUserAudioFiles];
    }
}

- (void)checkForWords:(LessonMetadata*)item
{
    if (self.currentWordNumber >= item.wordEndIndex)
    {
        if ([self.delegate respondsToSelector:@selector(lessonClearWords)])
        {
            [self.delegate lessonClearWords];
        }
        return;
    }

    LessonMetadata *wordInfo = self.playlist.words[self.currentLessonType][self.currentWordNumber];

    CMTime time = self.audioPlayer.musicPlayer.currentTime;
    CMTime trackStart = CMTimeMake(([wordInfo.audioStart doubleValue])*10, 10);
    CMTime trackEnd = CMTimeMake(([wordInfo.audioStart doubleValue]+[wordInfo.audioDuration doubleValue])*10, 10);

    if (CMTIME_COMPARE_INLINE(time, >=, trackStart))
    {
        if ([self.delegate respondsToSelector:@selector(lessonShowWord:insideSection:)])
        {
            [self.delegate lessonShowWord:wordInfo insideSection:item];
        }
    }

    if (CMTIME_COMPARE_INLINE(time, >=, trackEnd))
    {
        self.currentWordNumber++;
    }
}

- (void)audioPlayerCheckTime
{
    LessonMetadata *item = self.playlist.list[self.currentLessonType][self.currentItemNumber];

    if (item.hasWords)
    {
        [self checkForWords:item];
    }

    CMTime time = self.audioPlayer.musicPlayer.currentTime;
    CMTime trackEnd = CMTimeMake(([item.audioStart doubleValue]+[item.audioDuration doubleValue])*10, 10);

    if (CMTIME_COMPARE_INLINE(time, >=, trackEnd))
    {
//        self.playing = NO;
        [self.audioPlayer pause];

        if (self.currentItemNumber +1 < [self.playlist.list[self.currentLessonType] count])
        {
            if ([self.steps[self.currentStep] integerValue] == StepType2)
            {
                if (self.step2RecordFinish)
                {

                    [[NSNotificationCenter defaultCenter] postNotificationName:kVolumeMenuStatusChanged
                                                                        object:@NO
                                                                      userInfo:nil];
                    [self playNextStep];
                    return;
                }
                if ([self.delegate respondsToSelector:@selector(lessonClearWords)])
                {
                    [self.delegate lessonClearWords];
                }
                return;
            }

            if ([self.steps[self.currentStep] integerValue] == StepType4)
            {
                if (!self.step4RecordFinish)
                {
                    if ([self.delegate respondsToSelector:@selector(lessonClearWords)])
                    {
                        [self.delegate lessonClearWords];
                    }
                    return;
                }
                else
                {
                    return;
                }
            }

            [self playNextStep];
        }
        else
        {
            if ([self.userAudio isRecording])
            {
                if (self.step4Active)
                    return;

                [self.userAudio stopRecording];
                if ([self.delegate respondsToSelector:@selector(lessonEndRecording)])
                {
                    [self.delegate lessonEndRecording];
                }
                [self showItemOnScreen];
                if (self.step4_2On)
                    [self.appaudio play:AppAudioListenToUs withItem:nil];
            }
            else
                [self playNextStep];
        }
    }
}

- (void)audioPlayerFinish:(NSUInteger)type
{

}

- (void)audioPlayerReceiveInterruptionNotification:(NSUInteger)type
{
    // need to check status
    // if playing so stop
}

- (void)audioPlayerReceiveRouteChangeNotification:(NSUInteger)type
{
    // show message with input type
}

#pragma mark - UserAudio Delegate

- (void)userAudioDidFinishPlaying
{
    if ([self.steps[self.currentStep] integerValue] == StepType2)
    {
        [self playNextStep];
    }
    else if ([self.steps[self.currentStep] integerValue] == StepType4)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kVolumeMenuStatusChanged
                                                            object:@NO
                                                          userInfo:nil];
        [self playNextStep];
    }
}

- (void)userAudioDidFinishRecording
{
    if ([self.steps[self.currentStep] integerValue] == StepType2)
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
            [self pause];
        }
        
        if ([self.delegate respondsToSelector:@selector(lessonEndRecording)])
        {
            [self.delegate lessonEndRecording];
        }
        if (self.step2_2On)
        {
            [self.appaudio play:AppAudioListenToUs withItem:nil];
            return;
        }
        else
        {
            [self playNextStep];
        }
        return;
    }

    if ([self.steps[self.currentStep] integerValue] == StepType4)
    {
        if ([self.delegate respondsToSelector:@selector(lessonEndRecording)])
        {
            [self.delegate lessonEndRecording];
        }

        self.recording = NO;
        if (self.step4_2On)
        {
            [self.appaudio play:AppAudioListenToYourself withItem:nil];
        }
        else
        {
            [self playNextStep];
        }
    }
}

#pragma mark - AppAudio Delegate

- (void)appAudioFinished:(id)action
{
    switch ([self.steps[self.currentStep] integerValue])
    {
        case StepType1:
        {
            [self playStep1];
            break;
        }
        case StepType2:
        {
            if (!self.step2Active)
            {
                [self playStep2_1];
            }
            else
            {
                [self playStep2_2:NO];
            }
            break;
        }
        case StepType3:
        {
            [self playStep3];
            break;
        }
        case StepType4:
        {
            if (!self.step4Active)
            {
                [self playStep4_1];
            }
            else
            {
                [self playStep4_2:NO];
            }
            break;
        }
        default:
            break;
    }
}

- (void) dealloc
{
    [self.audioPlayer removeMusicPlayer];
    self.playlist = nil;
    self.audioPlayer.delegate = nil;
    self.appaudio.delegate = nil;
    self.appaudio = nil;
    self.userAudio.delegate = nil;
    self.userAudio = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kHeadsetActive
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kSpeakerStatusChange
                                                  object:nil];

}

@end

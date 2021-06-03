//
//  Defines.h
//  Check Spot
//
//  Created by Walter Apps on 11/22/11.
//  Copyright (c) 2012 Walter Apps. All rights reserved.
//

#ifndef MyMentor
#define MyMentor

#define DegreeToRadian(x) ((x) * M_PI / 180.0f)

#define kMicStatusChange                        @"MicStatusChange"
#define kHeadsetActive                          @"HeadsetActive"
#define kBlueToothActive                        @"BlueToothActive"
#define kHDMIActive                             @"HDMIActive"

#define kSpeakerStatusChange                    @"SpeakerStatusChange"
#define kInternetStatusChanged                  @"InternetStatusChanged"
#define kVolumeMenuStatusChanged                @"VolumeMenuStatusChanged"
#define kTermsApproved                          @"TermsApproved"
#define kVoicePromptsLoadStatus                 @"VoicePromptsLoadStatus"
#define kUpdateNaturalLanguageUI                @"UpdateNaturalLanguageUI"
#define kUpdateLessonsListAfterAction           @"UpdateLessonsListAfterAction"


#define LessonFontSize                          @"fontSize"
#define LessonFontName                          @"fontName"

#define SectionStatusKey                        @"defaultSections"
#define ChapterButtonStatus                     @"chapter"
#define ParagraphButtonStatus                   @"paragraph"
#define SectionButtonStatus                     @"section"
#define SentenceButtonStatus                    @"sentence"

#define SectionLockingStatusKey                 @"lockedSections"
#define ChapterButtonLockingStatus              @"chapter"
#define ParagraphButtonLockingStatus            @"paragraph"
#define SectionButtonLockingStatus              @"section"
#define SentenceButtonLockingStatus             @"sentence"

#define LearningStatusKey                       @"defaultLearningOptions"
#define Teacher1ButtonStatus                    @"teacher1"
#define TeacherAndStudentButtonStatus           @"teacherAndStudent"
#define Teacher2ButtonStatus                    @"teacher2"
#define StudentButtonStatus                     @"student"

#define LearningLockingStatusKey                @"lockedLearningOptions"
#define Teacher1LockingButtonStatus             @"teacher1"
#define TeacherAndStudentLockingButtonStatus    @"teacherAndStudent"
#define Teacher2LockingButtonStatus             @"teacher2"
#define StudentButtonStatus                     @"student"

#define PlaylistAudioDuration                   @"audioDuration"
#define PlaylistAudioStart                      @"audioStart"
#define PlaylistCharIndex                       @"charIndex"
#define PlaylistIndex                           @"index"
#define PlaylistCharLength                      @"length"
#define PlaylistText                            @"text"

#define PlaylistChapter                         @"chapter"
#define PlaylistParagraphs                      @"paragraphs"
#define PlaylistSentences                       @"sentences"
#define PlaylistSections                        @"sections"
#define PlaylistWords                           @"words"

#define LessonFontNameKey                       @"fontName"
#define LessonFontSizeKey                       @"fontSize"
#define LessonFontKey                           @"fonts"

#define PlaylistNikudChapter                    @"onlyNikudChapter"
#define PlaylistTeamimChapter                   @"onlyTeamimChapter"
#define PlaylistCleatTextChapter                @"clearTextChapter"

#define PlaylistIsInGroup                       @"isInGroup"
#define PlaylistText                            @"text"

#define valueForKeySentences                    @"paragraphs.sentences"

#define PLAYING					1.0f
#define STOP					0.0f
#define PAUSE					0.0f

#define kSteps                  1
#define kSections               2

#define PLAYBUTTON              1
#define UPDATEBUTTON            2
#define DOWNLOADBUTTON          3
#define CANCELBUTTON            4
#define DELETEBUTTON            5

#define DEMO_ACTIVE             2020


typedef NS_ENUM(NSUInteger,ActionType)
{
    ActionTypeLogin = 0,
    ActionTypeLogout,
    ActionTypeSwitch_User,
    ActionTypeFailed_Login,
    ActionTypeFailed_Logout,

};


typedef NS_ENUM(NSUInteger,StepType)
{
    StepType1 = 0,
    StepType2,
    StepType3,
    StepType4,
    StepType5,
    StepType6,
};

typedef NS_ENUM(NSUInteger,AppAudioTypes)
{
    AppAudioOK = 0,
    AppAudioCancel,
    AppAudioReadingTogether,
    AppAudioListenToMe,
    AppAudioListenToMeAgain,
    AppAudioListenToUs,
    AppAudioListenToYourself,
    AppAudioNowYou,
    AppAudioIfContinue,
    AppAudioEndOfLesson,
    AppNoAudio
};

typedef NS_ENUM(NSUInteger, ClipStatus)
{
    ClipRegular = 1,
    ClipDownload,
    ClipDelete
};

typedef NS_ENUM(NSUInteger, LessonType)
{
    LessonTypeNikudAndTeamim = 0,
    LessonTypeNikud,
    LessonTypeTeamim,
    LessonTypeClearText
};

typedef NS_ENUM(NSUInteger, ArrowDirectionType)
{
    ArrowDirectionTypeRight = 0,
    ArrowDirectionTypeLeft
};

typedef NS_ENUM(NSUInteger, PlayType)
{
    PlayTypeInterrupted = 0,
    PlayTypeUninterrupted
};

typedef NS_ENUM(NSUInteger, PickerViewType)
{
    PickerViewTypeNotActive = 0,
    PickerViewTypeReplayLesson,
    PickerViewTypeVoicePrompts,
    PickerViewTypeContentWorlds,
    PickerViewType2,
};

typedef NS_ENUM(NSUInteger, ShowHighlightedWordsType)
{
//    ShowHighlightedWordsTypeNotActive = 0,
ShowHighlightedWordsTypeDontShow = 0,
    ShowHighlightedWordsTypeShow,

};


#endif

//
//  Lesson.h
//  MyMentor
//
//  Created by Walter Yaron on 5/24/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LessonMetadata.h"
#import "Defines.h"

@class LessonSettings;
@class Playlist;
@class Clip;

@protocol LessonDelegate <NSObject>

- (void)lessonEnd:(BOOL)showSaveUserAudioFiles;
- (void)lessonShowFinish:(NSUInteger)type;
- (void)lessonShowItem:(LessonMetadata*)item;
- (void)lessonShowWord:(LessonMetadata*)word insideSection:(LessonMetadata*)item;
- (void)lessonClearWords;
- (void)lessonItemFinish:(BOOL)showSaveUserAudioFiles;
- (void)lessonStartRecording:(BOOL)enableButton;
- (void)lessonEndRecording;
- (void)lessonShowDemoMessage;

@end

@interface Lesson : NSObject

@property (assign, nonatomic,getter = isPlaying) BOOL playing;
@property (assign, nonatomic,getter = isRecording) BOOL recording;
@property (assign, nonatomic) NSUInteger currentStep;
//@property (assign, nonatomic) BOOL saveUserAudio;
@property (assign, nonatomic) PlayType playType;
@property (assign, nonatomic) BOOL saveUserAudioFiles;
@property (assign, nonatomic) NSInteger repeatCount;
@property (unsafe_unretained, nonatomic) id <LessonDelegate> delegate;

/*
    Create Lesson with provided JSON diretory
    Initialize Lesson settings
    Initialize Lesson metadata
    Initialize Lesson Player
    Initialize Lesson Recorder
*/
- (void)createLesson:(NSDictionary*)data andClip:(Clip*)clip;

- (void)updateLessonSettings:(NSInteger)index withStatus:(BOOL)status;

- (void)saveCurrentItems:(BOOL)saveUserAudio withStep2:(BOOL)deleteStep2_2;

- (void)updateLessonTextSettings:(NSArray*)settings;

- (void)switchPlaylist:(NSInteger)index;

/*


*/
- (void)playCurrentStep:(NSUInteger)repeat;

/*
 
 
*/
- (void)playNextStep;

/*


 */
- (void)playLessonFromStart;

/*
    Play Lesson audio file
*/
- (void)play;

/*
    Pause Lesson audio file
*/
- (void)pause;


- (void)changeVolume:(CGFloat)volume;

/*

*/
- (void)playNextItem;

- (void)playPreviousItem;


- (void)playPreviousStep;

- (void)resetLesson;

- (BOOL)checkForMic;
/*
 

 
 
*/

/*
    Stop Record user
*/
- (void)externalStopRecording;


/*
 
*/
//- (void)gotoItemByIndex:(NSUInteger)index;

- (void)gotoItemByIndex:(NSUInteger)index withForceType:(ItemType)type overwriteSettings:(BOOL)overwrite;

- (void)gotoItemByIndex:(NSUInteger)index withForceType:(ItemType)type;

- (LessonMetadata*)getCurrentWordInfo;

- (LessonMetadata*)getCurrentItem;

- (StepType)getStepType;

@end

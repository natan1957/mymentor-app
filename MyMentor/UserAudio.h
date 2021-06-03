//
//  cuePlayer.h
//  cueplayerpro
//
//  Created by yaron walter on 9/15/12.
//  Copyright (c) 2012 Walter Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LessonMetadata.h"

@protocol UserAudioDelegate <NSObject>
@optional
- (void)userAudioDidFinishPlaying;
- (void)userAudioDidFinishRecording;

@end

@interface UserAudio : NSObject <AVAudioRecorderDelegate,AVAudioPlayerDelegate>

@property (strong, nonatomic, readonly) AVAudioRecorder           *recorder;
@property (strong, nonatomic, readonly) AVAudioPlayer             *player;
@property (assign, nonatomic,getter = isPlaying) BOOL   playing;
@property (assign, nonatomic,getter = isRecording) BOOL recording;
@property (unsafe_unretained, nonatomic) id <UserAudioDelegate> delegate;

// initalize recorder and save output file with given location and name
-(void) createUserAudio:(NSString*)recordFilePath withDuration:(CMTime)duration;

// stop the recorder
- (void)stopRecording;

- (void)pauseRecording;

// start recording
- (void)startRecording;

//- (void)removeMusicPlayer;

- (void)loadFile:(NSString*)recordFilePath;

- (void)play:(BOOL)enableDelegate;

- (void)pause;

- (void)changeVolume:(CGFloat)volume;

// checking for microphone
- (BOOL) mic_exist;

@end

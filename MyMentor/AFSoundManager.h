//
//  AFSoundManager.h
//  AFSoundManager-Demo
//
//  Created by Alvaro Franco on 4/16/14.
//  Copyright (c) 2014 AlvaroFranco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>
#import "AFAudioRouter.h"

@protocol AFSoundManagerDelegate <NSObject>

- (void)soundManagerProgress:(NSInteger)percentage;

@end

@interface AFSoundManager : NSObject

//typedef void (^progressBlock)

//+(instancetype)sharedManager;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (assign,nonatomic ,getter = isPlaying) BOOL playing;
@property (weak, nonatomic) id <AFSoundManagerDelegate> delegate;

-(void)startPlayingLocalFileWithName:(NSURL*)fileURL;
-(void)pause;
-(void)resume;
-(void)stop;
-(void)restart;

-(void)changeVolumeToValue:(CGFloat)volume;
-(void)changeSpeedToRate:(CGFloat)rate;
-(void)moveToSecond:(int)second;
-(void)moveToSection:(CGFloat)section;
-(NSDictionary *)retrieveInfoForCurrentPlaying;


-(BOOL)areHeadphonesConnected;
-(void)forceOutputToDefaultDevice;
-(void)forceOutputToBuiltInSpeakers;

@end

@interface NSTimer (Blocks)

+(id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;
+(id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;

@end

@interface NSTimer (Control)

-(void)pauseTimer;
-(void)resumeTimer;

@end
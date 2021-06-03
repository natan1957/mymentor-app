//
//  cuePlayer.h
//  cueplayerpro
//
//  Created by yaron walter on 9/15/12.
//  Copyright (c) 2012 Walter Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol AudioPlayerDelegate <NSObject>

@optional
- (void)audioPlayerLessonEnd;
- (void)audioPlayerFinish:(NSUInteger)type;
- (void)audioPlayerReceiveInterruptionNotification:(NSUInteger)type;
- (void)audioPlayerReceiveRouteChangeNotification:(NSUInteger)type;
- (void)audioPlayerCheckTime;

@end

@interface AudioPlayer : NSObject <UIApplicationDelegate>

@property (strong, nonatomic) AVQueuePlayer         *musicPlayer;
@property (strong, nonatomic) AVPlayerItem          *playerItem;
@property (assign, nonatomic,getter = isPlaying) BOOL                  playing;
@property (assign, nonatomic) BOOL micActive;
@property (assign, nonatomic) BOOL headsetActive;
@property (assign, nonatomic) BOOL bluetoothActive;
@property (assign, nonatomic) BOOL hdmiActive;
@property (unsafe_unretained ,nonatomic) id <AudioPlayerDelegate> delegate;

+ (id)sharedInstance;

- (void)play;

- (void)pause;

- (void)changeVolume:(CGFloat)volume;

- (void)createPlayer:(NSString*)songURL;

- (void)removeMusicPlayer;

- (void)seekToTimeAndPlay:(CMTime)time;

- (void)seekToTimeAndPause:(CMTime)time;

- (NSNumber*)getAudioDuration;

@end

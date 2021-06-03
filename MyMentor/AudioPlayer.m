//
//  cuePlayer.m
//  cueplayerpro
//
//  Created by yaron walter on 9/15/12.
//  Copyright (c) 2012 Walter Apps. All rights reserved.
//

#import "AudioPlayer.h"
#import "Defines.h"
#import <AudioToolbox/AudioServices.h>
#import "UIDevice+Hardware.h"

#define REFRESH_INTERVAL 0.001f

@interface AudioPlayer () <AVAudioSessionDelegate>

@property (strong, nonatomic) id timeObserver;

@end

@implementation AudioPlayer

static void *cloudPlayerMusicPlayerStatusObserverContext = &cloudPlayerMusicPlayerStatusObserverContext;

NSString *kTracksKey		= @"tracks";
NSString *kStatusKey		= @"status";
NSString *kRateKey			= @"rate";
NSString *kPlayableKey		= @"playable";
NSString *kCurrentItemKey	= @"currentItem";
NSString *kTimedMetadataKey	= @"currentItem.timedMetadata";

void audioRouteChangeListenerCallback (
									   void                      *inUserData,
									   AudioSessionPropertyID    inPropertyID,
									   UInt32                    inPropertyValueSize,
									   const void                *inPropertyValue
									   ) {

	// ensure that this callback was invoked for a route change
	if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;

	// This callback, being outside the implementation block, needs a reference to the
	//		MainViewController object, which it receives in the inUserData parameter.
	//		You provide this reference when registering this callback (see the call to
	//		AudioSessionAddPropertyListener).
	AudioPlayer *controller = (__bridge AudioPlayer *) inUserData;

    // Determines the reason for the route change, to ensure that it is not
    //		because of a category change.
    CFDictionaryRef	routeChangeDictionary = inPropertyValue;
    CFNumberRef routeChangeReasonRef =
    CFDictionaryGetValue (
                          routeChangeDictionary,
                          CFSTR (kAudioSession_AudioRouteChangeKey_Reason)
                          );
    SInt32 routeChangeReason;
    CFNumberGetValue (
                      routeChangeReasonRef,
                      kCFNumberSInt32Type,
                      &routeChangeReason
                      );
    // "Old device unavailable" indicates that a headset was unplugged, or that the
    //	device was removed from a dock connector that supports audio output. This is
    //	the recommended test for when to pause audio.

    if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMicStatusChange
                                                            object:@YES
                                                          userInfo:nil];
        if (![[UIDevice currentDevice] isCurrentDeviceHardwareBetterThan:IPOD_TOUCH_3G])
            controller.micActive = YES;

        controller.headsetActive = YES;
    }

    if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMicStatusChange
                                                            object:@NO
                                                          userInfo:nil];

        if (![[UIDevice currentDevice] isCurrentDeviceHardwareBetterThan:IPOD_TOUCH_3G])
        {
            controller.micActive = NO;
            controller.headsetActive = NO;
            controller.bluetoothActive = NO;

            return;
        }

        controller.headsetActive = NO;
        controller.bluetoothActive = NO;
        [controller checkForInputOutput];
    }
}

+ (id)sharedInstance
{
    static AudioPlayer *myInstance = nil;
    static dispatch_once_t onceToken; // lock
    dispatch_once(&onceToken, ^
    {
        myInstance = [[self alloc] init];
    });
    return myInstance;
}

- (id) init
{
    if (self = [super init])
    {

        NSError *error = nil;

        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
        {

            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        }


        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                         withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                                               error:&error];

        if (error != nil)
        {
        }


        [[AVAudioSession sharedInstance] setActive:YES error:nil];

        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
        {
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            
            }];
        }

//        // Configure the audio session
//        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

//
//        // Find the desired input port
//        NSArray* inputs = [audioSession availableInputs];
//        AVAudioSessionPortDescription *builtInMic = nil;
//        for (AVAudioSessionPortDescription* port in inputs) {
//            if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
//                builtInMic = port;
//                break;
//            }
//        }
//
//        // Find the desired microphone
//        for (AVAudioSessionDataSourceDescription* source in builtInMic.dataSources) {
//            if ([source.orientation isEqual:AVAudioSessionOrientationBottom]) {
//                [builtInMic setPreferredDataSource:source error:nil];
//                [audioSession setPreferredInput:builtInMic error:&error];
//                break;
//            }
//        }


        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        {
            BOOL success = [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
            if(!success)
            {
                NSLog(@"error doing outputaudioportoverride - %@", [error localizedDescription]);
            }
        }
        else
        {
            UInt32 doChangeDefaultRoute = 1;
            AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (doChangeDefaultRoute), &doChangeDefaultRoute);
        }



//
//        [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeVideoChat error:&error];
//
//        if (error != nil)
//        {
//        }


        [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeDefault error:&error];

        if (error != nil)
        {
        }
////
////
//        [[AVAudioSession sharedInstance] setActive: YES error: &error];
//
//        if (error != nil)
//        {
//        }

        UInt32 bt = TRUE;
        OSStatus result;
        result = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryEnableBluetoothInput , sizeof(UInt32), &bt);

        if (noErr != result)
        {
            NSLog(@"AudioSessionSetProperty kAudioSessionProperty_AudioCategory failed: %d", (int)result);
        }

        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_5_1)
        {
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector: @selector(handleRouteChange:)
                                                         name: AVAudioSessionRouteChangeNotification
                                                       object: [AVAudioSession sharedInstance]];
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
            {
                [self checkForMic];
            }
        }
//        else
//        {
//            [[AVAudioSession sharedInstance] setDelegate:self];
//
//            AudioSessionAddPropertyListener (
//                                             kAudioSessionProperty_AudioRouteChange,
//                                             audioRouteChangeListenerCallback,
//                                             (__bridge void *)(self));
//            [self checkForInputOutput];
//        }
    }
    return self;
}

/* notification for input become available or unavailable */
- (void)inputIsAvailableChanged:(BOOL)isInputAvailable
{
    if (!isInputAvailable)
    {
        if (![[UIDevice currentDevice] isCurrentDeviceHardwareBetterThan:IPOD_TOUCH_3G])
        {
            self.micActive = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:kMicStatusChange
                                                                object:@NO
                                                              userInfo:nil];
        }

        self.headsetActive = NO;
        self.bluetoothActive = NO;
    }
    else
    {

        if (![[UIDevice currentDevice] isCurrentDeviceHardwareBetterThan:IPOD_TOUCH_3G])
        {
            self.micActive = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:kMicStatusChange
                                                                object:@YES
                                                              userInfo:nil];
        }

        self.headsetActive = YES;
    }
}

- (void)checkForInputOutput
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![self isHeadsetPluggedIn])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"שגיאה" message:@"לא קיים מיקרופון\nאנא חבר אוזניות בכדי לתרגל" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    });
}

- (BOOL)isHeadsetPluggedIn
{
    CFDictionaryRef description = NULL;

    UInt32 propertySize;
    AudioSessionGetPropertySize(kAudioSessionProperty_AudioRouteDescription, &propertySize);
    OSStatus error = AudioSessionGetProperty(kAudioSessionProperty_AudioRouteDescription, &propertySize, &description);
    if ( !error && description )
    {
        CFArrayRef outputs = CFDictionaryGetValue(description, kAudioSession_AudioRouteKey_Outputs);
        CFIndex count = CFArrayGetCount(outputs);
        if ( outputs && count )
        {
            self.headsetActive = YES;
            if (![[UIDevice currentDevice] isCurrentDeviceHardwareBetterThan:IPOD_TOUCH_3G])
                self.micActive = YES;

            [[NSNotificationCenter defaultCenter] postNotificationName:kHeadsetActive
                                                                object:@YES
                                                              userInfo:nil];
            return YES;
        }
        else
        {
            self.headsetActive = NO;
            if (![[UIDevice currentDevice] isCurrentDeviceHardwareBetterThan:IPOD_TOUCH_3G])
                self.micActive = NO;

            [[NSNotificationCenter defaultCenter] postNotificationName:kHeadsetActive
                                                                object:@NO
                                                              userInfo:nil];
            return NO;
        }
    }
    else if (error)
    {
        self.headsetActive = NO;
        if (![[UIDevice currentDevice] isCurrentDeviceHardwareBetterThan:IPOD_TOUCH_3G])
            self.micActive = NO;

        [[NSNotificationCenter defaultCenter] postNotificationName:kHeadsetActive
                                                            object:@NO
                                                          userInfo:nil];

        return NO;
    }

    return NO;
}

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    /* AVPlayerItem "status" property value observer. */
    if (context == cloudPlayerMusicPlayerStatusObserverContext)
    {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerStatusUnknown:
            {
                
            }
                break;
            case AVPlayerStatusReadyToPlay:
            {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                //[self playOrPause];

            }
                break;

            case AVPlayerStatusFailed:
            {
            }
                break;
        }
    }
    else
    {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }

    return;
}

- (void)play
{
    if ([self isPlaying] == NO)
	{
        [self.musicPlayer play];
        self.playing = YES;
	}
}

- (void)pause
{
    if ([self isPlaying] == YES)
	{
        [self.musicPlayer pause];
		self.playing = NO;
	}
}

- (void)changeVolume:(CGFloat)volume
{
    NSArray *audioTracks = [self.playerItem.asset tracksWithMediaType:AVMediaTypeAudio];
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks)
    {
        AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:volume atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters:allAudioParams];
    [self.playerItem setAudioMix:audioMix];
}


-(void) removeMusicPlayer
{
    [self.musicPlayer setRate:0.f];
    [self.musicPlayer removeObserver:self
                          forKeyPath:@"status"
                             context:cloudPlayerMusicPlayerStatusObserverContext];

    [self.musicPlayer removeTimeObserver:self.timeObserver];
    self.musicPlayer = nil;
}

-(void) loadSong:(NSString*)songURL
{
    if (self.musicPlayer)
    {
        [self removeMusicPlayer];
    }

    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:songURL]];
    self.playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
    self.musicPlayer = [[AVQueuePlayer alloc] initWithPlayerItem:self.playerItem];

    [self.musicPlayer addObserver:self
                       forKeyPath:@"status"
                          options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                          context:cloudPlayerMusicPlayerStatusObserverContext];

    __weak __typeof(&*self)weakSelf = self;
    self.timeObserver = [self.musicPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(REFRESH_INTERVAL, NSEC_PER_SEC)
                                                                       queue:dispatch_get_main_queue()
                                                                  usingBlock:^(CMTime time)
     {
         if (weakSelf.playing)
         {
             [weakSelf.delegate audioPlayerCheckTime];
         }
     }];
}

- (void)createPlayer:(NSString*)songURL
{
    [self loadSong:songURL];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    self.playing = NO;
    if ([self.delegate respondsToSelector:@selector(audioPlayerLessonEnd)])
    {
        [self.delegate audioPlayerLessonEnd];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    self.playing = NO;
}

- (void)seekToTimeAndPlay:(CMTime)time
{
    [self.musicPlayer seekToTime:time];
    [self play];
}

- (void)seekToTimeAndPause:(CMTime)time
{
    [self pause];
    [self.musicPlayer seekToTime:time];
}

- (NSNumber*)getAudioDuration
{
    return @(CMTimeGetSeconds(self.musicPlayer.currentItem.asset.duration));
}

-(void) handleInterruption:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];

    if ([[userInfo objectForKey:AVAudioSessionInterruptionTypeKey] intValue] == AVAudioSessionInterruptionTypeBegan)
    {
//        if (self.wasPlayingBeforeInterrupt == YES)
//        {
//            ViewController *myView = [ViewController sharedInstance];
//            [myView.PlayOrPauseButton setImage:[UIImage imageNamed:@"button_player_play.png"] forState:UIControlStateNormal];
//            [self.musicPlayer pause];
//        }
    }
    else if ([[userInfo objectForKey:AVAudioSessionInterruptionTypeKey] intValue] ==   AVAudioSessionInterruptionTypeEnded)
    {
        if ([[userInfo objectForKey:AVAudioSessionInterruptionOptionKey] intValue] == AVAudioSessionInterruptionOptionShouldResume)
        {
            UInt32 bt = TRUE;
            OSStatus result;
            result = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryEnableBluetoothInput , sizeof(UInt32), &bt);

            if (noErr != result)
            {
                NSLog(@"AudioSessionSetProperty kAudioSessionProperty_AudioCategory failed: %d", (int)result);
            }

            if (self.playing)
            {

//                if (self.wasPlayingBeforeInterrupt == YES)
//                {
//                    ViewController *myView = [ViewController sharedInstance];
//                    [myView.PlayOrPauseButton setImage:[UIImage imageNamed:@"button_player_pause.png"] forState:UIControlStateNormal];
//                    [self.musicPlayer play];
//                }
            }
        }
    }
}

- (void)checkForMic
{
    AVAudioSessionRouteDescription *routeInfo = [[AVAudioSession sharedInstance] currentRoute];

    NSArray *ports = routeInfo.outputs;

    self.hdmiActive = NO;
    self.bluetoothActive = NO;
    self.headsetActive = NO;

    [ports enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj class] == [AVAudioSessionPortDescription class])
         {
             AVAudioSessionPortDescription *portDesc = obj;

             if ([portDesc.portType isEqualToString:AVAudioSessionPortHDMI])
             {
                 self.hdmiActive = YES;
                 [[NSNotificationCenter defaultCenter] postNotificationName:kHDMIActive
                                                                     object:@YES
                                                                   userInfo:nil];
             }
             else if ([portDesc.portType isEqualToString:AVAudioSessionPortBuiltInMic] ||
                      [portDesc.portType isEqualToString:AVAudioSessionPortHeadsetMic])
             {
                 [[NSNotificationCenter defaultCenter] postNotificationName:kMicStatusChange
                                                                     object:@NO
                                                                   userInfo:nil];
                 self.headsetActive = NO;
                 self.bluetoothActive = NO;
             }
             else if ([portDesc.portType isEqualToString:AVAudioSessionPortHeadphones])
             {
                 [[NSNotificationCenter defaultCenter] postNotificationName:kHeadsetActive
                                                                     object:@YES
                                                                   userInfo:nil];
                 self.headsetActive = YES;
             }
             else if ([portDesc.portType isEqualToString:AVAudioSessionPortBluetoothHFP])
             {
                 [[NSNotificationCenter defaultCenter] postNotificationName:kBlueToothActive
                                                                     object:@YES
                                                                   userInfo:nil];
                 self.bluetoothActive = YES;
             }
         }
     }];

    ports = routeInfo.inputs;

    [ports enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        if ([obj class] == [AVAudioSessionPortDescription class])
        {
            AVAudioSessionPortDescription *portDesc = obj;

            if ([portDesc.portType isEqualToString:AVAudioSessionPortBuiltInMic] ||
                [portDesc.portType isEqualToString:AVAudioSessionPortHeadsetMic])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kMicStatusChange
                                                                    object:@YES
                                                                  userInfo:nil];
                self.micActive = YES;
            }

        }
    }];


}

-(void) handleRouteChange:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];
    [self checkForMic];

    if ([[userInfo objectForKey:AVAudioSessionRouteChangeReasonKey] intValue]== AVAudioSessionRouteChangeReasonUnknown)
    {
//        ViewController *myView = [ViewController sharedInstance];
//        [myView.PlayOrPauseButton setImage:[UIImage imageNamed:@"button_player_play.png"] forState:UIControlStateNormal];
//        [self.musicPlayer pause];
//        self.playing = NO;
    }
    else if ([[userInfo objectForKey:AVAudioSessionRouteChangeReasonKey] intValue]== AVAudioSessionRouteChangeReasonNewDeviceAvailable)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSpeakerStatusChange
                                                            object:@YES
                                                          userInfo:nil];
    }
    else if ([[userInfo objectForKey:AVAudioSessionRouteChangeReasonKey] intValue] == AVAudioSessionRouteChangeReasonOldDeviceUnavailable)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSpeakerStatusChange
                                                            object:@NO
                                                          userInfo:nil];
//        ViewController *myView = [ViewController sharedInstance];
//        [myView.PlayOrPauseButton setImage:[UIImage imageNamed:@"button_player_play.png"] forState:UIControlStateNormal];
//        [self.musicPlayer pause];
//        self.playing = NO;
    }
    //        AVAudioSessionRouteChangeReasonUnknown = 0,

    //        AVAudioSessionRouteChangeReasonOldDeviceUnavailable = 2,
    //        AVAudioSessionRouteChangeReasonCategoryChange = 3,
    //        AVAudioSessionRouteChangeReasonOverride = 4,
    //        AVAudioSessionRouteChangeReasonWakeFromSleep = 6,
    //        AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory = 7
}



-(void) dealloc
{
    if (self.musicPlayer)
    {
        [self removeMusicPlayer];
        self.musicPlayer = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionRouteChangeNotification
                                                  object:[AVAudioSession sharedInstance]];


//    if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0)
//    {
//        [[AVAudioSession sharedInstance] setDelegate:nil];
//
//        AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback, (__bridge void *)(self));
//    }
}

@end
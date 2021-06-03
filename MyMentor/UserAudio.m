//
//  cuePlayer.m
//  cueplayerpro
//
//  Created by yaron walter on 9/15/12.
//  Copyright (c) 2012 Walter Apps. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import "UserAudio.h"
#import "Defines.h"
#import "Playlist.h"
#import "PlayerViewController.h"

@interface UserAudio ()

@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSTimer *recordTimer;
@property (assign, nonatomic) NSTimeInterval recordDuration;				// hold the current track time in second
@property (assign, nonatomic) CMTime recordDurationiOS6;
@property (assign, nonatomic) BOOL sendToDelegate;

@end

@implementation UserAudio

- (id) init
{
    if (self = [super init])
    {
    }
    return self;
}

- (void)loadFile:(NSString*)recordFilePath
{
    NSError *error = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:recordFilePath] error:&error];
    if (error)
    {
        NSLog(@"recorder error %@",error);
        return;
    }
    self.player.delegate = self;
    [self.player prepareToPlay];
}


- (void)createUserAudio:(NSString*)recordFilePath withDuration:(CMTime)duration
{
    NSError *error = nil;

    NSDictionary *settings = @{AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                AVSampleRateKey : @(44100.0),
                                AVNumberOfChannelsKey : @(1)};
    self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:recordFilePath]
                                                settings:settings
                                                   error:&error];
    self.recorder.delegate = self;

    if (error)
    {
        NSLog(@"recorder error %@",error);
        return;
    }
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
           self.recordDurationiOS6 = CMTimeMultiply(duration, 1);
    }
    else
    {
        self.recordDuration = (double)((double)duration.value / (double)duration.timescale);
    }
}

- (void)startRecording
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        if (![self.recorder record])
        {
            NSLog(@"error");
        }
        [self.recorder prepareToRecord];
        if (![self.recorder recordForDuration:CMTimeGetSeconds(self.recordDurationiOS6)])
        {
            NSLog(@"error recording");
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:CMTimeGetSeconds(self.recordDurationiOS6)
                                                                target:self
                                                              selector:@selector(stopRecording)
                                                              userInfo:nil
                                                               repeats:NO];
        });
    }
    else
    {
        if (![self.recorder record])
        {
            NSLog(@"error recording");
        }
        NSLog(@"test");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:self.recordDuration
                                                                target:self
                                                              selector:@selector(stopRecording)
                                                              userInfo:nil
                                                            repeats:NO];
        });
    }
    self.recording = YES;
}

- (void)pauseRecording
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_5_1)
        [self.recorder stop];
    else
        [self.recorder pause];

    [self.recordTimer invalidate];
    self.recording = NO;
}

- (void)stopRecording
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        [self.recorder stop];
    }
    else
    {
        if ([self.recorder isRecording])
        {
            [self.recorder stop];
        }
    }
}

- (BOOL)mic_exist
{
    AVAudioSession *audio_session = [AVAudioSession sharedInstance];
    return audio_session.inputAvailable;
}

- (void)changeVolume:(CGFloat)volume
{
    [self.player setVolume:volume];
}

- (void)play:(BOOL)enableDelegate
{
    self.sendToDelegate = enableDelegate;
    if (![self.player play])
    {
        [self audioPlayerDecodeErrorDidOccur:nil error:nil];
    }
    self.playing = YES;
}

- (void)pause
{
    [self.player pause];
    self.playing = NO;
}

#pragma mark - AVAudioRecorder Delegate

/* audioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"test");
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    self.recording = NO;
    if ([self.delegate respondsToSelector:@selector(userAudioDidFinishRecording)])
    {
        [self.delegate userAudioDidFinishRecording];
    }
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    self.recording = NO;
    if ([self.delegate respondsToSelector:@selector(userAudioDidFinishRecording)])
    {
        [self.delegate userAudioDidFinishRecording];
    }
}

#pragma mark - AVAudioPlayder Delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    self.playing = NO;
//    if (self.sendToDelegate)
//    {
        if ([self.delegate respondsToSelector:@selector(userAudioDidFinishPlaying)])
        {
            [self.delegate userAudioDidFinishPlaying];
        }
//    }
}

#pragma mark - AVAudioPlayer Delegate

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    self.playing = NO;
    if ([self.delegate respondsToSelector:@selector(userAudioDidFinishPlaying)])
    {
        [self.delegate userAudioDidFinishPlaying];
    }
}

@end
//
//  cuePlayer.m
//  cueplayerpro
//
//  Created by yaron walter on 9/15/12.
//  Copyright (c) 2012 Walter Apps. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AppAudio.h"
#import "Defines.h"
#import "Playlist.h"
#import "Settings.h"

@interface AppAudio () <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioPlayer             *player;
@property (strong, nonatomic) id item;

@end

@implementation AppAudio

- (id) init
{
    if (self = [super init])
    {

    }
    return self;
}

- (void)play:(int)fileNumber withItem:(id)action
{
    NSString *filename = nil;
    self.item = action;

    NSDictionary *promptsFiles = [Settings sharedInstance].prompts;

    switch (fileNumber)
    {
        case AppAudioOK:
            filename = promptsFiles[@(AppAudioOK)];
            break;
        case AppAudioCancel:
            filename = promptsFiles[@(AppAudioCancel)];
            break;
        case AppAudioListenToMe:
            filename = promptsFiles[@(AppAudioListenToMe)];
            break;
        case AppAudioListenToMeAgain:
            filename = promptsFiles[@(AppAudioListenToMeAgain)];
            break;
        case AppAudioListenToUs:
            filename = promptsFiles[@(AppAudioListenToUs)];
            break;
        case AppAudioListenToYourself:
            filename = promptsFiles[@(AppAudioListenToYourself)];
            break;
        case AppAudioNowYou:
            filename = promptsFiles[@(AppAudioNowYou)];
            break;
        case AppAudioReadingTogether:
            filename = promptsFiles[@(AppAudioReadingTogether)];
            break;
        case AppAudioIfContinue:
            filename = promptsFiles[@(AppAudioIfContinue)];
            break;
        case AppAudioEndOfLesson:
            filename = promptsFiles[@(AppAudioEndOfLesson)];
            break;

        default:
            break;
    }

    if (filename)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:(NSURL*)[NSURL fileURLWithPath:filename] error:nil];
            self.player.delegate = self;
            [self.player play];
        });
    }
}

- (void)pause
{
    [self.player pause];
}

- (BOOL)isPlaying
{
    return self.player.playing;
}

#pragma mark - AVAudioPlayder Delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if ([self.delegate respondsToSelector:@selector(appAudioFinished:)])
    {
        [self.delegate appAudioFinished:self.item];
    }
}

#pragma mark - AVAudioPlayer Delegate

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(appAudioFinished:)])
    {
        [self.delegate appAudioFinished:self.item];
    }
}

@end
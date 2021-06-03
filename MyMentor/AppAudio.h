//
//  cuePlayer.h
//  cueplayerpro
//
//  Created by yaron walter on 9/15/12.
//  Copyright (c) 2012 Walter Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppAudioDelegate <NSObject>

- (void)appAudioFinished:(id)action;

@end

@interface AppAudio : NSObject

@property (unsafe_unretained, nonatomic) id <AppAudioDelegate> delegate;

- (void)play:(int)fileNumber withItem:(id)action;

- (void)pause;

- (BOOL)isPlaying;

@end

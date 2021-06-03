//
//  DownloadMMN.h
//  MyMentor
//
//  Created by Walter Yaron on 4/26/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DownloadVoicePromptsSuccessBlock) (BOOL done);
typedef void (^DownloadVoicePromptsFailureBlock) (NSError *error);
typedef void (^DownloadVoicePromptsProgressBlock) (NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations);

@interface DownloadVoicePrompts : NSObject

- (void)downloadVoicePrompts:(PFObject*)object progressBlock:(DownloadVoicePromptsProgressBlock)progressBlock completionBlock:(DownloadVoicePromptsSuccessBlock)completionBlock;

- (void)cancelDownload;

@end

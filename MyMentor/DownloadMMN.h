//
//  DownloadMMN.h
//  MyMentor
//
//  Created by Walter Yaron on 4/26/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DownloadMMNSuccessBlock) (BOOL done);
typedef void (^DownloadMMNFailureBlock) (NSError *error);
typedef void (^DownloadMMNProgressBlock) (long long totalBytesRead, long long totalBytesExpectedToRead);

@interface DownloadMMN : NSObject

@property (assign, nonatomic, getter = isDownloading) BOOL downloading;

-(void) downloadWithFilename:(NSString*)filename andURL:(NSString*)fileURL withSuccess:(DownloadMMNSuccessBlock)success withFailure:(DownloadMMNFailureBlock)failure;

- (void)setDownloadProgressBlock:(DownloadMMNProgressBlock)block;
- (void)cancelDownload;


@end

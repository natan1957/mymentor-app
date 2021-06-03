//
//  DownloadMMN.m
//  MyMentor
//
//  Created by Walter Yaron on 4/26/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import <Parse/Parse.h>
#import "DownloadVoicePrompts.h"
#import "AFClient.h"

@interface DownloadVoicePrompts()

@end

@implementation DownloadVoicePrompts

- (void)downloadVoicePrompts:(PFObject*)object progressBlock:(DownloadVoicePromptsProgressBlock)progressBlock completionBlock:(DownloadVoicePromptsSuccessBlock)completionBlock

{
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *directory = object.objectId;
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:directory];

    NSFileManager *manager = [[NSFileManager alloc] init];
    if (![manager fileExistsAtPath:documentsDirectory])
        [manager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder

    PFFileObject *file;
    NSString *fileURL;
    NSString *fileName;
    AFHTTPRequestOperation *operation;
    NSMutableArray *operations = [NSMutableArray array];

    file = object[@"OkContinue"];
    fileURL = file.url;
    fileName = [documentsDirectory stringByAppendingPathComponent:@"OkContinue.mp3"];
    operation = [self download:fileName andURL:fileURL];
    [operations addObject:operation];

    file = object[@"OkAgain"];
    fileURL = file.url;
    fileName = [documentsDirectory stringByAppendingPathComponent:@"OkAgain.mp3"];
    operation = [self download:fileName andURL:fileURL];
    [operations addObject:operation];

    file = object[@"ListenToMe"];
    fileURL = file.url;
    fileName = [documentsDirectory stringByAppendingPathComponent:@"ListenToMe.mp3"];
    operation = [self download:fileName andURL:fileURL];
    [operations addObject:operation];

    file = object[@"ListenToMeAgain"];
    fileURL = file.url;
    fileName = [documentsDirectory stringByAppendingPathComponent:@"ListenToMeAgain.mp3"];
    operation = [self download:fileName andURL:fileURL];
    [operations addObject:operation];

    file = object[@"ListenToUs"];
    fileURL = file.url;
    fileName = [documentsDirectory stringByAppendingPathComponent:@"ListenToUs.mp3"];
    operation = [self download:fileName andURL:fileURL];
    [operations addObject:operation];

    file = object[@"ListenToYourself"];
    fileURL = file.url;
    fileName = [documentsDirectory stringByAppendingPathComponent:@"ListenToYourself.mp3"];
    operation = [self download:fileName andURL:fileURL];
    [operations addObject:operation];

    file = object[@"NowYou"];
    fileURL = file.url;
    fileName = [documentsDirectory stringByAppendingPathComponent:@"NowYou.mp3"];
    operation = [self download:fileName andURL:fileURL];
    [operations addObject:operation];

    file = object[@"ReadingTogether"];
    fileURL = file.url;
    fileName = [documentsDirectory stringByAppendingPathComponent:@"ReadingTogether.mp3"];
    operation = [self download:fileName andURL:fileURL];
    [operations addObject:operation];

    file = object[@"IfContinue"];
    fileURL = file.url;
    fileName = [documentsDirectory stringByAppendingPathComponent:@"IfContinue.mp3"];
    operation = [self download:fileName andURL:fileURL];
    [operations addObject:operation];

    file = object[@"EndOfLessonSeeYou"];
    fileURL = file.url;
    fileName = [documentsDirectory stringByAppendingPathComponent:@"EndOfLessonSeeYou.mp3"];
    operation = [self download:fileName andURL:fileURL];
    [operations addObject:operation];

    [[[AFClient sharedInstance] client] enqueueBatchOfHTTPRequestOperations:operations
                                                              progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations)
    {
        progressBlock(numberOfFinishedOperations,totalNumberOfOperations);
    }
                                                            completionBlock:^(NSArray *operations)
    {
        completionBlock(YES);
    }];
}

-(AFHTTPRequestOperation*) download:(NSString*)fileName andURL:(NSString*)fileURL
{
    NSMutableURLRequest* request = [[[AFClient sharedInstance] client] requestWithMethod:@"GET"
                                                                                    path:fileURL
                                                                              parameters:nil];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:fileName append:NO];
    return operation;
}

- (void)cancelDownload
{
    [[[AFClient sharedInstance] client].operationQueue cancelAllOperations];
}

@end

//
//  DownloadMMN.m
//  MyMentor
//
//  Created by Walter Yaron on 4/26/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import "DownloadMMN.h"
#import "AFClient.h"
#import "ZipArchive.h"

@interface DownloadMMN()

@property (strong, nonatomic) DownloadMMNProgressBlock progressBlock;
@property (strong, nonatomic) AFHTTPRequestOperation *operation;

@end

@implementation DownloadMMN

- (void)setDownloadProgressBlock:(DownloadMMNProgressBlock)block
{
    self.progressBlock = block;
}

-(void) downloadWithFilename:(NSString*)filename andURL:(NSString*)fileURL withSuccess:(DownloadMMNSuccessBlock)success withFailure:(DownloadMMNFailureBlock)failure
{
    NSMutableURLRequest* request = [[[AFClient sharedInstance] client] requestWithMethod:@"GET"
                                                                                    path:fileURL
                                                                              parameters:nil];

    self.operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:filename];

    self.operation.outputStream = [NSOutputStream outputStreamToFileAtPath:imagePath append:NO];

    __weak DownloadMMN *weakSelf = self;
    [self.operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
     {
        weakSelf.progressBlock(totalBytesRead,totalBytesExpectedToRead);
     }];

    [self.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"SUCCCESSFULL IMG RETRIEVE to %@!",imagePath);

         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         NSString *documentsDirectory = [paths objectAtIndex:0];
         NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];

         ZipArchive *zipArchive = [[ZipArchive alloc] init];
         if ([zipArchive UnzipOpenFile:filePath])
         {
             if ([zipArchive UnzipFileTo:documentsDirectory overWrite:YES] == YES)
             {
                 NSError *error = nil;
                 NSFileManager *manager = [[NSFileManager alloc] init];
                 [manager removeItemAtPath:filePath error:&error];
                 if (error)
                 {
                     NSLog(@"%@",[error localizedDescription]);
                 }
             }
         }
         success(YES);
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         failure(error);
         // Deal with failure
     }];
    [self.operation start];
    self.downloading = YES;
}

- (void)cancelDownload
{
    [self.operation cancel];
    self.progressBlock = nil;
    self.operation = nil;
    self.downloading = NO;
}

@end

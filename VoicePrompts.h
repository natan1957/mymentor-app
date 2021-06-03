//
//  VoicePrompts.h
//  MyMentorV2
//
//  Created by Walter Yaron on 4/29/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VoicePrompts : NSManagedObject

@property (nonatomic, retain) NSString * voiceType;
@property (nonatomic, retain) NSString * voicePromptFile1;
@property (nonatomic, retain) NSString * voicePromptFile2;
@property (nonatomic, retain) NSString * voicePromptFile0;
@property (nonatomic, retain) NSString * voicePromptFile3;
@property (nonatomic, retain) NSString * voicePromptFile4;
@property (nonatomic, retain) NSString * voicePromptFile5;
@property (nonatomic, retain) NSString * voicePromptFile6;
@property (nonatomic, retain) NSString * voicePromptFile7;
@property (nonatomic, retain) NSString * voicePromptFile8;
@property (nonatomic, retain) NSString * voicePromptFile9;
@property (nonatomic, retain) NSDate * updateAt;
@property (nonatomic, retain) NSString * voiceId;

@end

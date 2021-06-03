//
//  User.m
//  BjoyPlus
//
//  Created by BLUE walter on 3/13/12.
//  Copyright (c) 2012 Walter Apps. All rights reserved.
//

#import <AVFoundation/AVMetadataFormat.h>
#import "Playlist.h"
#import "Defines.h"
#import "LessonMetadata.h"
#import "audioPlayer.h"
#import "Settings.h"

#define TIME_START 3
#define TIME_LENGTH 8

@interface Playlist ()

@property (strong, nonatomic) NSDictionary *lesson;
@property (strong, nonatomic) NSMutableArray *listNikudAndTeamim;
@property (strong, nonatomic) NSMutableArray *listNikud;
@property (strong, nonatomic) NSMutableArray *listTeamim;
@property (strong, nonatomic) NSMutableArray *listClearText;
@property (strong, nonatomic) NSMutableArray *wordsNikudAndTeamim;
@property (strong, nonatomic) NSMutableArray *wordsNikud;
@property (strong, nonatomic) NSMutableArray *wordsTeamim;
@property (strong, nonatomic) NSMutableArray *wordsClearText;

@end

@implementation Playlist

static Playlist *myInstance = nil;

- (id)initWithJSON:(NSDictionary*)data
{
    self = [super init];
    if (self)
    {
        self.lesson = [[NSDictionary alloc] initWithDictionary:data];
        self.words = [[NSMutableArray alloc] initWithCapacity:100];
        self.wordsNikudAndTeamim = [[NSMutableArray alloc] initWithCapacity:100];
        self.wordsNikud = [[NSMutableArray alloc] initWithCapacity:100];
        self.wordsTeamim = [[NSMutableArray alloc] initWithCapacity:100];
        self.wordsClearText = [[NSMutableArray alloc] initWithCapacity:100];
        self.list = [[NSMutableArray alloc] initWithCapacity:1];
        self.listNikudAndTeamim = [[NSMutableArray alloc] initWithCapacity:1];
        self.listNikud = [[NSMutableArray alloc] initWithCapacity:1];
        self.listTeamim = [[NSMutableArray alloc] initWithCapacity:1];
        self.listClearText = [[NSMutableArray alloc] initWithCapacity:1];
        
    }
    return self;
}

+(Playlist*) shareInstance
{
    if (self == [Playlist class])
    {
        @synchronized (self)
        {
            if (myInstance == nil)
            {
               myInstance = [[self alloc] init];
            }
        }
    }
    return myInstance;
}

-(NSNumber*) convertString:(NSString*)audioTime
{
    NSRange match;
    double trackduration;
    if (([audioTime length]) == 13)
    {
        match.location = TIME_START;
        match.length = 3;
        trackduration = [[audioTime substringWithRange:match] doubleValue]*60;

        match.location = TIME_START+4;
        match.length = 2;
        trackduration += [[audioTime substringWithRange:match] doubleValue];

        match.location = TIME_START+6;
        match.length = 3;
        trackduration += [[audioTime substringWithRange:match] doubleValue];
    }

    if (([audioTime length]) == 12)
    {
        match.location = TIME_START;
        match.length = 2;
        trackduration = [[audioTime substringWithRange:match] doubleValue]*60;

        match.location = TIME_START+3;
        match.length = 2;
        trackduration += [[audioTime substringWithRange:match] doubleValue];

        match.location = TIME_START+5;
        match.length = 3;
        trackduration += [[audioTime substringWithRange:match] doubleValue];
    }

    return @(trackduration);
}

-(void) generateLessonBySetting:(NSArray*)settings
{
    [self generateNinkudAndTeamim:settings];
    [self generateNinkud:settings];
    [self generateTeamim:settings];
    [self generateClearText:settings];
}

- (void)generateNinkudAndTeamim:(NSArray*)settings
{
    [self.listNikudAndTeamim removeAllObjects];

    __block NSUInteger currentParagraph = 0;
    __block NSUInteger currentSentences = 0;
    __block NSUInteger currentSection = 0;
    __block BOOL       foundSectionsWords = NO;
    __block BOOL       foundSentencesWords = NO;
    __block BOOL       foundParagraphWords = NO;
    __block BOOL       foundChapterWords = NO;
    __block NSUInteger currentSectionsWordIndex = 0;
    __block NSUInteger currentSentencesWordIndex = 0;
    __block NSUInteger currentParagraphWordIndex = 0;
    __block NSUInteger currentChapterWordIndex = 0;

    NSDictionary *obj = self.lesson[PlaylistChapter];
    {
        currentChapterWordIndex = [self.wordsNikudAndTeamim count];
        NSArray *tmpparagraph = obj[PlaylistParagraphs];
        [tmpparagraph enumerateObjectsUsingBlock:^(NSDictionary *obj1, NSUInteger idx1, BOOL *stop1)
         {
             currentParagraph = idx1;
             currentParagraphWordIndex = [self.wordsNikudAndTeamim count];
             NSArray *tmpsentences = obj1[PlaylistSentences];
             [tmpsentences enumerateObjectsUsingBlock:^(NSDictionary *obj2, NSUInteger idx2, BOOL *stop2)
              {
                  currentSentences = idx2;
                  currentSentencesWordIndex = [self.wordsNikudAndTeamim count];
                  NSArray *tmpsections = obj2[PlaylistSections];
                  if ([tmpsections count])
                  {
                      [tmpsections enumerateObjectsUsingBlock:^(NSDictionary *obj3, NSUInteger idx3, BOOL *stop3)
                       {
                           currentSection = idx3;
                           currentSectionsWordIndex = [self.wordsNikudAndTeamim count];
                           NSArray *tmpwords = obj3[PlaylistWords];
                           if ([tmpwords count])
                           {
                               [tmpwords enumerateObjectsUsingBlock:^(NSDictionary *obj4, NSUInteger idx4, BOOL *stop4)
                                {
                                    if (![[self convertString:obj4[PlaylistAudioDuration]] isEqualToNumber:@(0)])
                                    {
                                        LessonMetadata *metadata = [[LessonMetadata alloc] init];
                                        metadata.paragraph = currentParagraph;
                                        metadata.sentence = currentSentences;
                                        metadata.section = currentSection;
                                        metadata.localIndex = idx1;
                                        metadata.index = [obj4[PlaylistIndex] integerValue];
                                        metadata.charStartIndex = [obj4[PlaylistCharIndex] integerValue];
                                        metadata.charEndIndex = [obj4[PlaylistCharLength] integerValue];
                                        metadata.audioStart = [self convertString:obj4[PlaylistAudioStart]];
                                        metadata.audioDuration = [self convertString:obj4[PlaylistAudioDuration]];
                                        foundSectionsWords = YES;
                                        foundSentencesWords = YES;
                                        foundParagraphWords = YES;
                                        foundChapterWords = YES;
                                        [self.wordsNikudAndTeamim addObject:metadata];
                                    }
                                }];
                           }

                           if ([settings[0] boolValue])
                           {
                               if (![[self convertString:obj3[PlaylistAudioDuration]] isEqualToNumber:@(0)])
                               {
                                   LessonMetadata *metadata = [[LessonMetadata alloc] init];
                                   metadata.paragraph = currentParagraph;
                                   metadata.sentence = currentSentences;
                                   metadata.section = currentSection;
                                   metadata.localIndex = idx1;
                                   metadata.index = [obj3[PlaylistIndex] integerValue];
                                   metadata.charStartIndex = [obj3[PlaylistCharIndex] integerValue];
                                   metadata.charEndIndex = [obj3[PlaylistCharLength] integerValue];
                                   metadata.audioStart = [self convertString:obj3[PlaylistAudioStart]];
                                   metadata.audioDuration = [self convertString:obj3[PlaylistAudioDuration]];
                                   metadata.itemType = ItemTypeSection;
                                   if (foundSectionsWords)
                                   {
                                       metadata.hasWords = YES;
                                       metadata.wordStartIndex = currentSectionsWordIndex;
                                       metadata.wordEndIndex = [self.wordsNikudAndTeamim count];
                                       foundSectionsWords = NO;
                                   }
                                   [self.listNikudAndTeamim addObject:metadata];
                               }
                           }
                       }];
                  }
                  if ([settings[1] boolValue])
                  {
                      if (![[self convertString:obj2[PlaylistAudioDuration]] isEqualToNumber:@(0)])
                      {
                          LessonMetadata *metadata = [[LessonMetadata alloc] init];
                          metadata.paragraph = currentParagraph;
                          metadata.sentence = currentSentences;
                          metadata.section = currentSection;
                          metadata.localIndex = idx1;
                          metadata.index = [obj2[PlaylistIndex] integerValue];
                          metadata.charStartIndex = [obj2[PlaylistCharIndex] integerValue];
                          metadata.charEndIndex = [obj2[PlaylistCharLength] integerValue];
                          metadata.audioStart = [self convertString:obj2[PlaylistAudioStart]];
                          metadata.audioDuration = [self convertString:obj2[PlaylistAudioDuration]];
                          metadata.itemType = ItemTypeSentences;
                          if (foundSentencesWords)
                          {
                              metadata.hasWords = YES;
                              metadata.wordStartIndex = currentSentencesWordIndex;
                              metadata.wordEndIndex = [self.wordsNikudAndTeamim count];
                              foundSentencesWords = NO;
                          }
                          [self.listNikudAndTeamim addObject:metadata];
                      }
                  }
              }];

             if ([settings[2] boolValue])
             {
                 if (![[self convertString:obj1[PlaylistAudioDuration]] isEqualToNumber:@(0)])
                 {
                     LessonMetadata *metadata = [[LessonMetadata alloc] init];
                     metadata.paragraph = currentParagraph;
                     metadata.sentence = currentSentences;
                     metadata.section = currentSection;
                     metadata.localIndex = idx1;
                     metadata.index = [obj1[PlaylistIndex] integerValue];
                     metadata.charStartIndex = [obj1[PlaylistCharIndex] integerValue];
                     metadata.charEndIndex = [obj1[PlaylistCharLength] integerValue];
                     metadata.audioStart = [self convertString:obj1[PlaylistAudioStart]];
                     metadata.audioDuration = [self convertString:obj1[PlaylistAudioDuration]];
                     metadata.itemType = ItemTypeParagraph;
                     if (foundParagraphWords)
                     {
                         metadata.hasWords = YES;
                         metadata.wordStartIndex = currentParagraphWordIndex;
                         metadata.wordEndIndex = [self.wordsNikudAndTeamim count];
                         foundParagraphWords = NO;
                     }
                     [self.listNikudAndTeamim addObject:metadata];
                 }
             }
         }];

        if ([settings[3] boolValue])
        {
            if (![[self convertString:obj[PlaylistAudioDuration]] isEqualToNumber:@(0)])
            {
                LessonMetadata *metadata = [[LessonMetadata alloc] init];
                metadata.chapter = 1;
                metadata.paragraph = 0;
                metadata.sentence = 0;
                metadata.section = 0;
                metadata.localIndex = 0;
                metadata.index = [obj[PlaylistIndex] integerValue];
                metadata.charStartIndex = [obj[PlaylistCharIndex] integerValue];
                metadata.charEndIndex = [obj[PlaylistCharLength] integerValue];
                metadata.audioStart = [self convertString:obj[PlaylistAudioStart]];
                metadata.audioDuration = [self convertString:obj[PlaylistAudioDuration]];
                metadata.itemType = ItemTypeChapter;
                if (foundChapterWords)
                {
                    metadata.hasWords = YES;
                    metadata.wordStartIndex = currentChapterWordIndex;
                    metadata.wordEndIndex = [self.wordsNikudAndTeamim count];
                    foundChapterWords = NO;
                }
                [self.listNikudAndTeamim addObject:metadata];
            }
        }
    }

    if ([self.listNikudAndTeamim count])
        [self.list addObject:self.listNikudAndTeamim];
    else
        [self.list addObject:@NO];

    if ([self.wordsNikudAndTeamim count])
        [self.words addObject:self.wordsNikudAndTeamim];
    else
        [self.list addObject:@NO];
    
//    [self.listNikudAndTeamim enumerateObjectsUsingBlock:^(LessonMetadata *obj, NSUInteger idx, BOOL *stop)
//     {
//         NSLog(@"%@",obj);
//     }];
//    NSLog(@"tes");
}

- (void)generateNinkud:(NSArray*)settings
{
    [self.listNikud removeAllObjects];

    __block NSUInteger currentParagraph = 0;
    __block NSUInteger currentSentences = 0;
    __block NSUInteger currentSection = 0;
    __block BOOL       foundSectionsWords = NO;
    __block BOOL       foundSentencesWords = NO;
    __block BOOL       foundParagraphWords = NO;
    __block BOOL       foundChapterWords = NO;
    __block NSUInteger currentSectionsWordIndex = 0;
    __block NSUInteger currentSentencesWordIndex = 0;
    __block NSUInteger currentParagraphWordIndex = 0;
    __block NSUInteger currentChapterWordIndex = 0;

    NSDictionary *obj = self.lesson[PlaylistNikudChapter];
    {
        currentChapterWordIndex = [self.wordsNikud count];
        NSArray *tmpparagraph = obj[PlaylistParagraphs];
        [tmpparagraph enumerateObjectsUsingBlock:^(NSDictionary *obj1, NSUInteger idx1, BOOL *stop1)
         {
             currentParagraph = idx1;
             currentParagraphWordIndex = [self.wordsNikud count];
             NSArray *tmpsentences = obj1[PlaylistSentences];
             [tmpsentences enumerateObjectsUsingBlock:^(NSDictionary *obj2, NSUInteger idx2, BOOL *stop2)
              {
                  currentSentences = idx2;
                  currentSentencesWordIndex = [self.wordsNikud count];
                  NSArray *tmpsections = obj2[PlaylistSections];
                  if ([tmpsections count])
                  {
                      [tmpsections enumerateObjectsUsingBlock:^(NSDictionary *obj3, NSUInteger idx3, BOOL *stop3)
                       {
                           currentSection = idx3;
                           currentSectionsWordIndex = [self.wordsNikud count];
                           NSArray *tmpwords = obj3[PlaylistWords];
                           if ([tmpwords count])
                           {
                               [tmpwords enumerateObjectsUsingBlock:^(NSDictionary *obj4, NSUInteger idx4, BOOL *stop4)
                                {
                                    if (![[self convertString:obj4[PlaylistAudioDuration]] isEqualToNumber:@(0)])
                                    {
                                        LessonMetadata *metadata = [[LessonMetadata alloc] init];
                                        metadata.paragraph = currentParagraph;
                                        metadata.sentence = currentSentences;
                                        metadata.section = currentSection;
                                        metadata.localIndex = idx1;
                                        metadata.index = [obj4[PlaylistIndex] integerValue];
                                        metadata.charStartIndex = [obj4[PlaylistCharIndex] integerValue];
                                        metadata.charEndIndex = [obj4[PlaylistCharLength] integerValue];
                                        metadata.audioStart = [self convertString:obj4[PlaylistAudioStart]];
                                        metadata.audioDuration = [self convertString:obj4[PlaylistAudioDuration]];
                                        foundSectionsWords = YES;
                                        foundSentencesWords = YES;
                                        foundParagraphWords = YES;
                                        foundChapterWords = YES;
                                        [self.wordsNikud addObject:metadata];
                                    }
                                }];
                           }

                           if ([settings[0] boolValue])
                           {
                               if (![[self convertString:obj3[PlaylistAudioDuration]] isEqualToNumber:@(0)])
                               {
                                   LessonMetadata *metadata = [[LessonMetadata alloc] init];
                                   metadata.paragraph = currentParagraph;
                                   metadata.sentence = currentSentences;
                                   metadata.section = currentSection;
                                   metadata.localIndex = idx1;
                                   metadata.index = [obj3[PlaylistIndex] integerValue];
                                   metadata.charStartIndex = [obj3[PlaylistCharIndex] integerValue];
                                   metadata.charEndIndex = [obj3[PlaylistCharLength] integerValue];
                                   metadata.audioStart = [self convertString:obj3[PlaylistAudioStart]];
                                   metadata.audioDuration = [self convertString:obj3[PlaylistAudioDuration]];
                                   metadata.itemType = ItemTypeSection;
                                   if (foundSectionsWords)
                                   {
                                       metadata.hasWords = YES;
                                       metadata.wordStartIndex = currentSectionsWordIndex;
                                       metadata.wordEndIndex = [self.wordsNikud count];
                                       foundSectionsWords = NO;
                                   }
                                   [self.listNikud addObject:metadata];
                               }
                           }
                       }];
                  }
                  if ([settings[1] boolValue])
                  {
                      if (![[self convertString:obj2[PlaylistAudioDuration]] isEqualToNumber:@(0)])
                      {
                          LessonMetadata *metadata = [[LessonMetadata alloc] init];
                          metadata.paragraph = currentParagraph;
                          metadata.sentence = currentSentences;
                          metadata.section = currentSection;
                          metadata.localIndex = idx1;
                          metadata.index = [obj2[PlaylistIndex] integerValue];
                          metadata.charStartIndex = [obj2[PlaylistCharIndex] integerValue];
                          metadata.charEndIndex = [obj2[PlaylistCharLength] integerValue];
                          metadata.audioStart = [self convertString:obj2[PlaylistAudioStart]];
                          metadata.audioDuration = [self convertString:obj2[PlaylistAudioDuration]];
                          metadata.itemType = ItemTypeSentences;
                          if (foundSentencesWords)
                          {
                              metadata.hasWords = YES;
                              metadata.wordStartIndex = currentSentencesWordIndex;
                              metadata.wordEndIndex = [self.wordsNikud count];
                              foundSentencesWords = NO;
                          }
                          [self.listNikud addObject:metadata];
                      }
                  }
              }];

             if ([settings[2] boolValue])
             {
                 if (![[self convertString:obj1[PlaylistAudioDuration]] isEqualToNumber:@(0)])
                 {
                     LessonMetadata *metadata = [[LessonMetadata alloc] init];
                     metadata.paragraph = currentParagraph;
                     metadata.sentence = currentSentences;
                     metadata.section = currentSection;
                     metadata.localIndex = idx1;
                     metadata.index = [obj1[PlaylistIndex] integerValue];
                     metadata.charStartIndex = [obj1[PlaylistCharIndex] integerValue];
                     metadata.charEndIndex = [obj1[PlaylistCharLength] integerValue];
                     metadata.audioStart = [self convertString:obj1[PlaylistAudioStart]];
                     metadata.audioDuration = [self convertString:obj1[PlaylistAudioDuration]];
                     metadata.itemType = ItemTypeParagraph;
                     if (foundParagraphWords)
                     {
                         metadata.hasWords = YES;
                         metadata.wordStartIndex = currentParagraphWordIndex;
                         metadata.wordEndIndex = [self.wordsNikud count];
                         foundParagraphWords = NO;
                     }
                     [self.listNikud addObject:metadata];
                 }
             }
         }];

        if ([settings[3] boolValue])
        {
            if (![[self convertString:obj[PlaylistAudioDuration]] isEqualToNumber:@(0)])
            {
                LessonMetadata *metadata = [[LessonMetadata alloc] init];
                metadata.chapter = 1;
                metadata.paragraph = 0;
                metadata.sentence = 0;
                metadata.section = 0;
                metadata.localIndex = 0;
                metadata.index = [obj[PlaylistIndex] integerValue];
                metadata.charStartIndex = [obj[PlaylistCharIndex] integerValue];
                metadata.charEndIndex = [obj[PlaylistCharLength] integerValue];
                metadata.audioStart = [self convertString:obj[PlaylistAudioStart]];
                metadata.audioDuration = [self convertString:obj[PlaylistAudioDuration]];
                metadata.itemType = ItemTypeChapter;
                if (foundChapterWords)
                {
                    metadata.hasWords = YES;
                    metadata.wordStartIndex = currentChapterWordIndex;
                    metadata.wordEndIndex = [self.wordsNikud count];
                    foundChapterWords = NO;
                }
                [self.listNikud addObject:metadata];
            }
        }
    }

    if ([self.listNikud count])
        [self.list addObject:self.listNikud];
    else
        [self.list addObject:@NO];

    if ([self.wordsNikud count])
        [self.words addObject:self.wordsNikud];
    else
        [self.list addObject:@NO];

//    [self.listNikud enumerateObjectsUsingBlock:^(LessonMetadata *obj, NSUInteger idx, BOOL *stop)
//     {
//         NSLog(@"%@",obj);
//     }];
}

- (void)generateTeamim:(NSArray*)settings
{
    [self.listTeamim removeAllObjects];

    __block NSUInteger currentParagraph = 0;
    __block NSUInteger currentSentences = 0;
    __block NSUInteger currentSection = 0;
    __block BOOL       foundSectionsWords = NO;
    __block BOOL       foundSentencesWords = NO;
    __block BOOL       foundParagraphWords = NO;
    __block BOOL       foundChapterWords = NO;
    __block NSUInteger currentSectionsWordIndex = 0;
    __block NSUInteger currentSentencesWordIndex = 0;
    __block NSUInteger currentParagraphWordIndex = 0;
    __block NSUInteger currentChapterWordIndex = 0;

    NSDictionary *obj = self.lesson[PlaylistTeamimChapter];
    {
        currentChapterWordIndex = [self.wordsTeamim count];
        NSArray *tmpparagraph = obj[PlaylistParagraphs];
        [tmpparagraph enumerateObjectsUsingBlock:^(NSDictionary *obj1, NSUInteger idx1, BOOL *stop1)
         {
             currentParagraph = idx1;
             currentParagraphWordIndex = [self.wordsTeamim count];
             NSArray *tmpsentences = obj1[PlaylistSentences];
             [tmpsentences enumerateObjectsUsingBlock:^(NSDictionary *obj2, NSUInteger idx2, BOOL *stop2)
              {
                  currentSentences = idx2;
                  currentSentencesWordIndex = [self.wordsTeamim count];
                  NSArray *tmpsections = obj2[PlaylistSections];
                  if ([tmpsections count])
                  {
                      [tmpsections enumerateObjectsUsingBlock:^(NSDictionary *obj3, NSUInteger idx3, BOOL *stop3)
                       {
                           currentSection = idx3;
                           currentSectionsWordIndex = [self.wordsTeamim count];
                           NSArray *tmpwords = obj3[PlaylistWords];
                           if ([tmpwords count])
                           {
                               [tmpwords enumerateObjectsUsingBlock:^(NSDictionary *obj4, NSUInteger idx4, BOOL *stop4)
                                {
                                    if (![[self convertString:obj4[PlaylistAudioDuration]] isEqualToNumber:@(0)])
                                    {
                                        LessonMetadata *metadata = [[LessonMetadata alloc] init];
                                        metadata.paragraph = currentParagraph;
                                        metadata.sentence = currentSentences;
                                        metadata.section = currentSection;
                                        metadata.localIndex = idx1;
                                        metadata.index = [obj4[PlaylistIndex] integerValue];
                                        metadata.charStartIndex = [obj4[PlaylistCharIndex] integerValue];
                                        metadata.charEndIndex = [obj4[PlaylistCharLength] integerValue];
                                        metadata.audioStart = [self convertString:obj4[PlaylistAudioStart]];
                                        metadata.audioDuration = [self convertString:obj4[PlaylistAudioDuration]];
                                        foundSectionsWords = YES;
                                        foundSentencesWords = YES;
                                        foundParagraphWords = YES;
                                        foundChapterWords = YES;
                                        [self.wordsTeamim addObject:metadata];
                                    }
                                }];
                           }

                           if ([settings[0] boolValue])
                           {
                               if (![[self convertString:obj3[PlaylistAudioDuration]] isEqualToNumber:@(0)])
                               {
                                   LessonMetadata *metadata = [[LessonMetadata alloc] init];
                                   metadata.paragraph = currentParagraph;
                                   metadata.sentence = currentSentences;
                                   metadata.section = currentSection;
                                   metadata.localIndex = idx1;
                                   metadata.index = [obj3[PlaylistIndex] integerValue];
                                   metadata.charStartIndex = [obj3[PlaylistCharIndex] integerValue];
                                   metadata.charEndIndex = [obj3[PlaylistCharLength] integerValue];
                                   metadata.audioStart = [self convertString:obj3[PlaylistAudioStart]];
                                   metadata.audioDuration = [self convertString:obj3[PlaylistAudioDuration]];
                                   metadata.itemType = ItemTypeSection;
                                   if (foundSectionsWords)
                                   {
                                       metadata.hasWords = YES;
                                       metadata.wordStartIndex = currentSectionsWordIndex;
                                       metadata.wordEndIndex = [self.wordsTeamim count];
                                       foundSectionsWords = NO;
                                   }
                                   [self.listTeamim addObject:metadata];
                               }
                           }
                       }];
                  }
                  if ([settings[1] boolValue])
                  {
                      if (![[self convertString:obj2[PlaylistAudioDuration]] isEqualToNumber:@(0)])
                      {
                          LessonMetadata *metadata = [[LessonMetadata alloc] init];
                          metadata.paragraph = currentParagraph;
                          metadata.sentence = currentSentences;
                          metadata.section = currentSection;
                          metadata.localIndex = idx1;
                          metadata.index = [obj2[PlaylistIndex] integerValue];
                          metadata.charStartIndex = [obj2[PlaylistCharIndex] integerValue];
                          metadata.charEndIndex = [obj2[PlaylistCharLength] integerValue];
                          metadata.audioStart = [self convertString:obj2[PlaylistAudioStart]];
                          metadata.audioDuration = [self convertString:obj2[PlaylistAudioDuration]];
                          metadata.itemType = ItemTypeSentences;
                          if (foundSentencesWords)
                          {
                              metadata.hasWords = YES;
                              metadata.wordStartIndex = currentSentencesWordIndex;
                              metadata.wordEndIndex = [self.wordsTeamim count];
                              foundSentencesWords = NO;
                          }
                          [self.listTeamim addObject:metadata];
                      }
                  }
              }];

             if ([settings[2] boolValue])
             {
                 if (![[self convertString:obj1[PlaylistAudioDuration]] isEqualToNumber:@(0)])
                 {
                     LessonMetadata *metadata = [[LessonMetadata alloc] init];
                     metadata.paragraph = currentParagraph;
                     metadata.sentence = currentSentences;
                     metadata.section = currentSection;
                     metadata.localIndex = idx1;
                     metadata.index = [obj1[PlaylistIndex] integerValue];
                     metadata.charStartIndex = [obj1[PlaylistCharIndex] integerValue];
                     metadata.charEndIndex = [obj1[PlaylistCharLength] integerValue];
                     metadata.audioStart = [self convertString:obj1[PlaylistAudioStart]];
                     metadata.audioDuration = [self convertString:obj1[PlaylistAudioDuration]];
                     metadata.itemType = ItemTypeParagraph;
                     if (foundParagraphWords)
                     {
                         metadata.hasWords = YES;
                         metadata.wordStartIndex = currentParagraphWordIndex;
                         metadata.wordEndIndex = [self.wordsTeamim count];
                         foundParagraphWords = NO;
                     }
                     [self.listTeamim addObject:metadata];
                 }
             }
         }];

        if ([settings[3] boolValue])
        {
            if (![[self convertString:obj[PlaylistAudioDuration]] isEqualToNumber:@(0)])
            {
                LessonMetadata *metadata = [[LessonMetadata alloc] init];
                metadata.chapter = 1;
                metadata.paragraph = 0;
                metadata.sentence = 0;
                metadata.section = 0;
                metadata.localIndex = 0;
                metadata.index = [obj[PlaylistIndex] integerValue];
                metadata.charStartIndex = [obj[PlaylistCharIndex] integerValue];
                metadata.charEndIndex = [obj[PlaylistCharLength] integerValue];
                metadata.audioStart = [self convertString:obj[PlaylistAudioStart]];
                metadata.audioDuration = [self convertString:obj[PlaylistAudioDuration]];
                metadata.itemType = ItemTypeChapter;
                if (foundChapterWords)
                {
                    metadata.hasWords = YES;
                    metadata.wordStartIndex = currentChapterWordIndex;
                    metadata.wordEndIndex = [self.wordsTeamim count];
                    foundChapterWords = NO;
                }
                [self.listTeamim addObject:metadata];
            }
        }
    }

    if ([self.listTeamim count])
        [self.list addObject:self.listTeamim];
    else
        [self.list addObject:@NO];

    if ([self.wordsTeamim count])
        [self.words addObject:self.wordsTeamim];
    else
        [self.list addObject:@NO];

//    [self.listTeamim enumerateObjectsUsingBlock:^(LessonMetadata *obj, NSUInteger idx, BOOL *stop)
//     {
//         NSLog(@"%@",obj);
//     }];
}

- (void)generateClearText:(NSArray*)settings
{
    [self.listClearText removeAllObjects];

    __block NSUInteger currentParagraph = 0;
    __block NSUInteger currentSentences = 0;
    __block NSUInteger currentSection = 0;
    __block BOOL       foundSectionsWords = NO;
    __block BOOL       foundSentencesWords = NO;
    __block BOOL       foundParagraphWords = NO;
    __block BOOL       foundChapterWords = NO;
    __block NSUInteger currentSectionsWordIndex = 0;
    __block NSUInteger currentSentencesWordIndex = 0;
    __block NSUInteger currentParagraphWordIndex = 0;
    __block NSUInteger currentChapterWordIndex = 0;

    NSDictionary *obj = self.lesson[PlaylistCleatTextChapter];
    {
        currentChapterWordIndex = [self.wordsClearText count];
        NSArray *tmpparagraph = obj[PlaylistParagraphs];
        [tmpparagraph enumerateObjectsUsingBlock:^(NSDictionary *obj1, NSUInteger idx1, BOOL *stop1)
         {
             currentParagraph = idx1;
             currentParagraphWordIndex = [self.wordsClearText count];
             NSArray *tmpsentences = obj1[PlaylistSentences];
             [tmpsentences enumerateObjectsUsingBlock:^(NSDictionary *obj2, NSUInteger idx2, BOOL *stop2)
              {
                  currentSentences = idx2;
                  currentSentencesWordIndex = [self.wordsClearText count];
                  NSArray *tmpsections = obj2[PlaylistSections];
                  if ([tmpsections count])
                  {
                      [tmpsections enumerateObjectsUsingBlock:^(NSDictionary *obj3, NSUInteger idx3, BOOL *stop3)
                       {
                           currentSection = idx3;
                           currentSectionsWordIndex = [self.wordsClearText count];
                           NSArray *tmpwords = obj3[PlaylistWords];
                           if ([tmpwords count])
                           {
                               [tmpwords enumerateObjectsUsingBlock:^(NSDictionary *obj4, NSUInteger idx4, BOOL *stop4)
                                {
                                    if (![[self convertString:obj4[PlaylistAudioDuration]] isEqualToNumber:@(0)])
                                    {
                                        LessonMetadata *metadata = [[LessonMetadata alloc] init];
                                        metadata.paragraph = currentParagraph;
                                        metadata.sentence = currentSentences;
                                        metadata.section = currentSection;
                                        metadata.localIndex = idx1;
                                        metadata.index = [obj4[PlaylistIndex] integerValue];
                                        metadata.charStartIndex = [obj4[PlaylistCharIndex] integerValue];
                                        metadata.charEndIndex = [obj4[PlaylistCharLength] integerValue];
                                        metadata.audioStart = [self convertString:obj4[PlaylistAudioStart]];
                                        metadata.audioDuration = [self convertString:obj4[PlaylistAudioDuration]];
                                        foundSectionsWords = YES;
                                        foundSentencesWords = YES;
                                        foundParagraphWords = YES;
                                        foundChapterWords = YES;
                                        [self.wordsClearText addObject:metadata];
                                    }
                                }];
                           }

                           if ([settings[0] boolValue])
                           {
                               if (![[self convertString:obj3[PlaylistAudioDuration]] isEqualToNumber:@(0)])
                               {
                                   LessonMetadata *metadata = [[LessonMetadata alloc] init];
                                   metadata.paragraph = currentParagraph;
                                   metadata.sentence = currentSentences;
                                   metadata.section = currentSection;
                                   metadata.localIndex = idx1;
                                   metadata.index = [obj3[PlaylistIndex] integerValue];
                                   metadata.charStartIndex = [obj3[PlaylistCharIndex] integerValue];
                                   metadata.charEndIndex = [obj3[PlaylistCharLength] integerValue];
                                   metadata.audioStart = [self convertString:obj3[PlaylistAudioStart]];
                                   metadata.audioDuration = [self convertString:obj3[PlaylistAudioDuration]];
                                   metadata.itemType = ItemTypeSection;
                                   if (foundSectionsWords)
                                   {
                                       metadata.hasWords = YES;
                                       metadata.wordStartIndex = currentSectionsWordIndex;
                                       metadata.wordEndIndex = [self.wordsClearText count];
                                       foundSectionsWords = NO;
                                   }
                                   [self.listClearText addObject:metadata];
                               }
                           }
                       }];
                  }
                  if ([settings[1] boolValue])
                  {
                      if (![[self convertString:obj2[PlaylistAudioDuration]] isEqualToNumber:@(0)])
                      {
                          LessonMetadata *metadata = [[LessonMetadata alloc] init];
                          metadata.paragraph = currentParagraph;
                          metadata.sentence = currentSentences;
                          metadata.section = currentSection;
                          metadata.localIndex = idx1;
                          metadata.index = [obj2[PlaylistIndex] integerValue];
                          metadata.charStartIndex = [obj2[PlaylistCharIndex] integerValue];
                          metadata.charEndIndex = [obj2[PlaylistCharLength] integerValue];
                          metadata.audioStart = [self convertString:obj2[PlaylistAudioStart]];
                          metadata.audioDuration = [self convertString:obj2[PlaylistAudioDuration]];
                          metadata.itemType = ItemTypeSentences;
                          if (foundSentencesWords)
                          {
                              metadata.hasWords = YES;
                              metadata.wordStartIndex = currentSentencesWordIndex;
                              metadata.wordEndIndex = [self.wordsClearText count];
                              foundSentencesWords = NO;
                          }
                          [self.listClearText addObject:metadata];
                      }
                  }
              }];

             if ([settings[2] boolValue])
             {
                 if (![[self convertString:obj1[PlaylistAudioDuration]] isEqualToNumber:@(0)])
                 {
                     LessonMetadata *metadata = [[LessonMetadata alloc] init];
                     metadata.paragraph = currentParagraph;
                     metadata.sentence = currentSentences;
                     metadata.section = currentSection;
                     metadata.localIndex = idx1;
                     metadata.index = [obj1[PlaylistIndex] integerValue];
                     metadata.charStartIndex = [obj1[PlaylistCharIndex] integerValue];
                     metadata.charEndIndex = [obj1[PlaylistCharLength] integerValue];
                     metadata.audioStart = [self convertString:obj1[PlaylistAudioStart]];
                     metadata.audioDuration = [self convertString:obj1[PlaylistAudioDuration]];
                     metadata.itemType = ItemTypeParagraph;
                     if (foundParagraphWords)
                     {
                         metadata.hasWords = YES;
                         metadata.wordStartIndex = currentParagraphWordIndex;
                         metadata.wordEndIndex = [self.wordsClearText count];
                         foundParagraphWords = NO;
                     }
                     [self.listClearText addObject:metadata];
                 }
             }
         }];

        if ([settings[3] boolValue])
        {
            if (![[self convertString:obj[PlaylistAudioDuration]] isEqualToNumber:@(0)])
            {
                LessonMetadata *metadata = [[LessonMetadata alloc] init];
                metadata.chapter = 1;
                metadata.paragraph = 0;
                metadata.sentence = 0;
                metadata.section = 0;
                metadata.localIndex = 0;
                metadata.index = [obj[PlaylistIndex] integerValue];
                metadata.charStartIndex = [obj[PlaylistCharIndex] integerValue];
                metadata.charEndIndex = [obj[PlaylistCharLength] integerValue];
                metadata.audioStart = [self convertString:obj[PlaylistAudioStart]];
                metadata.audioDuration = [self convertString:obj[PlaylistAudioDuration]];
                metadata.itemType = ItemTypeChapter;
                if (foundChapterWords)
                {
                    metadata.hasWords = YES;
                    metadata.wordStartIndex = currentChapterWordIndex;
                    metadata.wordEndIndex = [self.wordsClearText count];
                    foundChapterWords = NO;
                }
                [self.listClearText addObject:metadata];
            }
        }
    }

    if ([self.listClearText count])
        [self.list addObject:self.listClearText];
    else
        [self.list addObject:@NO];

    if ([self.wordsClearText count])
        [self.words addObject:self.wordsClearText];
    else
        [self.list addObject:@NO];

//    [self.listClearText enumerateObjectsUsingBlock:^(LessonMetadata *obj, NSUInteger idx, BOOL *stop)
//     {
//         NSLog(@"%@",obj);
//     }];
}

@end

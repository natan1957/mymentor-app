//
//  song.h
//  CUEPlayer
//
//  Created by Yaron Walter on 2/10/11.
//  Copyright 2011 Walter Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ItemType)
{
    ItemTypeSection = 0,
    ItemTypeSentences,
    ItemTypeParagraph,
    ItemTypeChapter
};

@interface LessonMetadata : NSObject

@property (assign, nonatomic) NSUInteger            chapter;
@property (assign, nonatomic) NSUInteger            paragraph;
@property (assign, nonatomic) NSUInteger            sentence;
@property (assign, nonatomic) NSUInteger            section;
@property (assign, nonatomic) NSUInteger            word;
@property (assign, nonatomic) NSUInteger            charStartIndex;
@property (assign, nonatomic) NSUInteger            charEndIndex;
@property (assign, nonatomic) NSUInteger            index;
@property (assign, nonatomic) NSUInteger            localIndex;
@property (assign, nonatomic) NSUInteger            wordStartIndex;
@property (assign, nonatomic) NSUInteger            wordEndIndex;
@property (strong, nonatomic) NSString              *text;
@property (strong, nonatomic) NSNumber              *audioStart;
@property (strong, nonatomic) NSNumber              *audioDuration;
@property (assign, nonatomic) ItemType              itemType;
@property (assign, nonatomic,getter = isInGroup) BOOL               inGroup;
@property (assign, nonatomic) BOOL                  hasWords;

- (BOOL)compare:(LessonMetadata*)metadata;

@end

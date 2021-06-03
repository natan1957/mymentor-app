//
//  song.m
//  CUEPlayer
//
//  Created by Yaron Walter on 2/10/11.
//  Copyright 2011 Walter Apps. All rights reserved.
//

#import "LessonMetadata.h"


@implementation LessonMetadata

- (NSString*)description
{

    return [NSString stringWithFormat:@"paragraph %lu\nsentence %lu\nsection %lu\nword %lu\nstart %lu\nend %lu\ntype %lu\n%f start\n%f duration",
                                                                                            (unsigned long)self.paragraph,
                                                                                            (unsigned long)self.sentence,
                                                                                            (unsigned long)self.section,
                                                                                            (unsigned long)self.word,
                                                                                            (unsigned long)self.charStartIndex,
                                                                                            (unsigned long)self.charEndIndex,
            (unsigned long)self.itemType,
            [self.audioStart doubleValue],
            [self.audioDuration doubleValue]];
}

- (BOOL)compare:(LessonMetadata*)metadata
{
    if ((self.paragraph != metadata.paragraph) || (self.sentence != metadata.sentence) || (self.section != metadata.section) || (self.word != metadata.word) || (self.itemType != metadata.itemType))
    {
        return NO;
    }

    return YES;
}

@end

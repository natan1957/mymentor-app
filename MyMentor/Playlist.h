//
//  User.h
//  Check Spot
//
//  Created by BLUE walter on 3/13/12.
//  Copyright (c) 2012 Walter Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@class LessonMetadata;

@interface Playlist : NSObject

@property (strong, nonatomic) NSMutableArray    *words;
@property (strong, nonatomic) NSMutableArray    *list;

+(Playlist*)    shareInstance;

/*
 Initialize all the class properties.

 @param data is the lesson JSON file that this class need to convert to playlist
*/
- (id)initWithJSON:(NSDictionary*)data;

/*
 Creates list of LessonMetadata objects according to the settings values.

 @param settings an array of values (YES,NO) that represents what to include in the list array = [paragraph (YES,NO),sentences (YES,NO),sections (YES,NO),words (YES,NO)]
*/
- (void)generateLessonBySetting:(NSArray*)settings;

@end

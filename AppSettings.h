//
//  AppSettings.h
//  MyMentorV2
//
//  Created by Walter Yaron on 5/7/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AppSettings : NSManagedObject

@property (nonatomic, retain) NSNumber * appSettingsArrowDirectionType;
@property (nonatomic, retain) NSString * appSettingsContentWorldId;
@property (nonatomic, retain) NSNumber * appSettingsReplayLessonIndex;
@property (nonatomic, retain) NSNumber * appSettingsShowHighlightedWords;
@property (nonatomic, retain) NSNumber * appSettingsVoicePromptsIndex;
@property (nonatomic, retain) NSNumber * appSettingsNaturalLanguage;
@property (nonatomic, retain) NSNumber * appSettingsPlayType;
@property (nonatomic, retain) NSNumber * appSettingsSaveUserAudio;
@property (nonatomic, retain) NSNumber * appSettingsEnvironment;

@end

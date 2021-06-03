//
//  Clip.h
//  MyMentorV2
//
//  Created by Walter Yaron on 7/16/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Clip : NSManagedObject

@property (nonatomic, retain) NSNumber * arrowDirectionType;
@property (nonatomic, retain) NSString * category1_en_us;
@property (nonatomic, retain) NSString * category1_he_il;
@property (nonatomic, retain) NSNumber * category1_order;
@property (nonatomic, retain) NSString * category2_en_us;
@property (nonatomic, retain) NSString * category2_he_il;
@property (nonatomic, retain) NSNumber * category2_order;
@property (nonatomic, retain) NSString * category3_en_us;
@property (nonatomic, retain) NSString * category3_he_il;
@property (nonatomic, retain) NSNumber * category3_order;
@property (nonatomic, retain) NSString * category4_en_us;
@property (nonatomic, retain) NSString * category4_he_il;
@property (nonatomic, retain) NSNumber * category4_order;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * createdByUser;
@property (nonatomic, retain) NSString * defaultVoicePromptsId;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * lessonContentWorldId;
@property (nonatomic, retain) NSNumber * lessonDemo;
@property (nonatomic, retain) NSString * lessonDescription_en_us;
@property (nonatomic, retain) NSString * lessonDescription_he_il;
@property (nonatomic, retain) NSString * lessonDuration;
@property (nonatomic, retain) NSString * lessonFontName;
@property (nonatomic, retain) NSNumber * lessonFontSize;
@property (nonatomic, retain) NSString * lessonId;
@property (nonatomic, retain) NSNumber * lessonIncludingSupport;
@property (nonatomic, retain) NSNumber * lessonNikudActive;
@property (nonatomic, retain) NSString * lessonRamarks_he_il;
@property (nonatomic, retain) NSString * lessonRemarks_en_us;
@property (nonatomic, retain) NSNumber * lessonRepeatCount;
@property (nonatomic, retain) NSString * lessonSampleText;
@property (nonatomic, retain) NSNumber * lessonSampleTextFontSize;
@property (nonatomic, retain) NSNumber * lessonSwitch1_1;
@property (nonatomic, retain) NSNumber * lessonSwitch1_2;
@property (nonatomic, retain) NSNumber * lessonSwitch1_3;
@property (nonatomic, retain) NSNumber * lessonSwitch1_4;
@property (nonatomic, retain) NSNumber * lessonSwitch1_5;
@property (nonatomic, retain) NSNumber * lessonSwitch1_6;
@property (nonatomic, retain) NSNumber * lessonSwitch2_1;
@property (nonatomic, retain) NSNumber * lessonSwitch2_2;
@property (nonatomic, retain) NSNumber * lessonSwitch2_3;
@property (nonatomic, retain) NSNumber * lessonSwitch2_4;
@property (nonatomic, retain) NSNumber * lessonTeamimActive;
@property (nonatomic, retain) NSNumber * locked;
@property (nonatomic, retain) NSString * name_en_us;
@property (nonatomic, retain) NSString * name_he_il;
@property (nonatomic, retain) NSString * performer_he_il;
@property (nonatomic, retain) NSString * performer_en_us;
@property (nonatomic, retain) NSString * purchaseId;
@property (nonatomic, retain) NSNumber * playType;
@property (nonatomic, retain) NSNumber * repeatLessonStartFrom;
@property (nonatomic, retain) NSNumber * showHighlightedWords;
@property (nonatomic, retain) NSNumber * saveUserAudio;
@property (nonatomic, retain) NSString * teacherGroupId;
@property (nonatomic, retain) NSString * teacherId;
@property (nonatomic, retain) NSString * teacherParentGroupId;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSDate * updatedByMyMentor;
@property (nonatomic, retain) NSDecimalNumber * version;
@property (nonatomic, retain) NSString * teacherName_he_il;
@property (nonatomic, retain) NSString * teacherName_en_us;
@property (nonatomic, retain) NSString * lessonFingerPrint;

- (void)updateLessonSettingsWithJSON:(NSDictionary*)jsonSettings;
- (void)saveNewClipToCoreData:(NSDictionary*)data;
- (void)updateClipToCoreData:(NSDictionary*)data;
- (NSMutableDictionary*)loadClipFromCoreData;

@end

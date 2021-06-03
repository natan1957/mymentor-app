//
//  Clip.m
//  MyMentorV2
//
//  Created by Walter Yaron on 7/16/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import "Clip.h"
#import "Defines.h"
#import "Settings.h"
#import "CocoaSecurity.h"

@implementation Clip

@dynamic arrowDirectionType;
@dynamic category1_en_us;
@dynamic category1_he_il;
@dynamic category1_order;
@dynamic category2_en_us;
@dynamic category2_he_il;
@dynamic category2_order;
@dynamic category3_en_us;
@dynamic category3_he_il;
@dynamic category3_order;
@dynamic category4_en_us;
@dynamic category4_he_il;
@dynamic category4_order;
@dynamic createdAt;
@dynamic createdByUser;
@dynamic defaultVoicePromptsId;
@dynamic favorite;
@dynamic fileName;
@dynamic identifier;
@dynamic lessonContentWorldId;
@dynamic lessonDemo;
@dynamic lessonDescription_en_us;
@dynamic lessonDescription_he_il;
@dynamic lessonDuration;
@dynamic lessonFontName;
@dynamic lessonFontSize;
@dynamic lessonId;
@dynamic lessonIncludingSupport;
@dynamic lessonNikudActive;
@dynamic lessonRamarks_he_il;
@dynamic lessonRemarks_en_us;
@dynamic lessonRepeatCount;
@dynamic lessonSampleText;
@dynamic lessonSampleTextFontSize;
@dynamic lessonSwitch1_1;
@dynamic lessonSwitch1_2;
@dynamic lessonSwitch1_3;
@dynamic lessonSwitch1_4;
@dynamic lessonSwitch1_5;
@dynamic lessonSwitch1_6;
@dynamic lessonSwitch2_1;
@dynamic lessonSwitch2_2;
@dynamic lessonSwitch2_3;
@dynamic lessonSwitch2_4;
@dynamic lessonTeamimActive;
@dynamic locked;
@dynamic name_en_us;
@dynamic name_he_il;
@dynamic performer_he_il;
@dynamic performer_en_us;
@dynamic purchaseId;
@dynamic playType;
@dynamic repeatLessonStartFrom;
@dynamic showHighlightedWords;
@dynamic saveUserAudio;
@dynamic teacherGroupId;
@dynamic teacherId;
@dynamic teacherParentGroupId;
@dynamic updatedAt;
@dynamic updatedByMyMentor;
@dynamic version;
@dynamic teacherName_he_il;
@dynamic teacherName_en_us;
@dynamic lessonFingerPrint;

- (void)updateLessonSettingsWithJSON:(NSDictionary*)jsonSettings
{
    NSDictionary *fontData = jsonSettings[LessonFontKey];
    if ([[fontData allKeys] count])
    {
        NSString *fontName = [[fontData allKeys] objectAtIndex:0];
        NSArray *fontSizes = [fontData objectForKey:fontName];
        self.lessonFontName = [fontName stringByReplacingOccurrencesOfString:@" " withString:@""];

        if ([fontSizes count])
        {
            __block NSInteger fontSize = 0;
            [fontSizes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if ([obj integerValue] > fontSize)
                 {
                     fontSize = [obj integerValue];
                 }
             }];
            self.lessonSampleTextFontSize = @(fontSize);
        }
    }

    NSDictionary *tmp = jsonSettings[PlaylistChapter];
    NSString *tmpString = tmp[PlaylistText];
    if ([tmpString length]>=20) {
        self.lessonSampleText = [tmpString substringToIndex:20];
    }

    NSDictionary *tmp1 = jsonSettings[LearningStatusKey];
    NSDictionary *tmp2 = jsonSettings[LearningLockingStatusKey];
    self.lessonSwitch1_1 = @([tmp1[Teacher1ButtonStatus ] integerValue] + ([tmp2[Teacher1LockingButtonStatus] integerValue] << 1));
    self.lessonSwitch1_2 = @([tmp1[TeacherAndStudentButtonStatus] integerValue] + ([tmp2[TeacherAndStudentLockingButtonStatus] integerValue] << 1));
    self.lessonSwitch1_3 = @([tmp1[Teacher2ButtonStatus] integerValue] + ([tmp2[Teacher2LockingButtonStatus] integerValue] << 1));
    self.lessonSwitch1_4 = @([tmp1[StudentButtonStatus] integerValue] + ([tmp2[StudentButtonStatus] integerValue] << 1));
    self.lessonSwitch1_5 = self.lessonSwitch1_2;
    self.lessonSwitch1_6 = self.lessonSwitch1_4;
    tmp1 = jsonSettings[SectionStatusKey];
    tmp2 = jsonSettings[SectionLockingStatusKey];
    self.lessonSwitch2_1 = @([tmp1[SectionButtonStatus] integerValue] + ([tmp2[SectionButtonLockingStatus] integerValue] << 1));
    self.lessonSwitch2_2 = @([tmp1[SentenceButtonStatus] integerValue] + ([tmp2[SentenceButtonLockingStatus] integerValue] << 1));
    self.lessonSwitch2_3 = @([tmp1[ParagraphButtonStatus] integerValue] + ([tmp2[ParagraphButtonLockingStatus] integerValue] << 1));
    self.lessonSwitch2_4 = @([tmp1[ChapterButtonStatus] integerValue] + ([tmp2[ChapterButtonLockingStatus] integerValue] << 1));
}

- (void) saveNewClipToCoreData:(NSDictionary*)data
{
    self.name_he_il = data[@"name_he_il"];
    self.name_en_us = data[@"name_en_us"];
    
    if (data[@"lessonDescription_he_il"] != [NSNull null])
        self.lessonDescription_he_il = data[@"lessonDescription_he_il"];

    if (data[@"lessonDescription_en_us"] != [NSNull null])
        self.lessonDescription_en_us = data[@"lessonDescription_en_us"];

    NSDecimalNumber *version = [NSDecimalNumber decimalNumberWithString:data[@"version"]];
    self.version = version;
    self.fileName = data[@"fileName"];
    self.identifier = data[@"identifier"];
    self.updatedAt = data[@"updatedAt"];
    self.createdAt = data[@"createdAt"];
    self.category1_en_us = data[@"category1_en_us"];
    self.category1_he_il = data[@"category1_he_il"];
    self.category1_order = data[@"category1_order"];
    self.category2_en_us = data[@"category2_en_us"];
    self.category2_he_il = data[@"category2_he_il"];
    self.category2_order = data[@"category2_order"];
    self.category3_en_us = data[@"category3_en_us"];
    self.category3_he_il = data[@"category3_he_il"];
    self.category3_order = data[@"category3_order"];
    self.category4_en_us = data[@"category4_en_us"];
    self.category4_he_il = data[@"category4_he_il"];
    self.category4_order = data[@"category4_order"];
    self.updatedByMyMentor = data[@"updatedByMyMentor"];
    self.locked = data[@"locked"];
    self.teacherId = data[@"teacherId"];
    self.teacherGroupId = data[@"teacherGroupId"];
    self.teacherParentGroupId = data[@"teacherParentGroupId"];
    self.defaultVoicePromptsId = data[@"defaultVoicePromptsId"];
    self.lessonId = data[@"lessonId"];
    self.lessonContentWorldId = data[@"lessonContentWorldId"];
    self.lessonIncludingSupport = data[@"lessonIncludingSupport"];
    self.lessonDemo = data[@"lessonDemo"];
    self.lessonDuration = data[@"lessonDuration"];
    self.lessonNikudActive = data[@"lessonNikudActive"];
    self.lessonTeamimActive = data[@"lessonTeamimActive"];

    if (data[@"lessonRemarks_he_il"] != [NSNull null])
        self.lessonRamarks_he_il =  data[@"lessonRemarks_he_il"];
    if (data[@"lessonRemarks_en_us"] != [NSNull null])
        self.lessonRemarks_en_us = data[@"lessonRemarks_en_us"];

    self.teacherName_he_il = data[@"teacherName_he_il"];
    self.teacherName_en_us = data[@"teacherName_en_us"];
    self.performer_he_il = data[@"performer_he_il"];
    self.performer_en_us = data[@"performer_en_us"];
    self.purchaseId = data[@"purchaseId"];
    self.lessonFingerPrint = data[@"fingerPrint"];
    self.playType = @([Settings sharedInstance].appSettingsPlayType);
    self.lessonRepeatCount = @(1);
    self.arrowDirectionType = @([Settings sharedInstance].appSettingsArrowDirectionType);
    self.saveUserAudio = @([Settings sharedInstance].appSettingsSaveUserAudio);
    [self updateLessonSettings:data];

}

- (void)updateLessonSettings:(NSDictionary*)data
{
    NSString *fileName = data[@"identifier"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *jsonFilePath = [documentsDirectory stringByAppendingPathComponent:[fileName stringByAppendingString:@".json"]];
    NSString *jsonString = [NSString stringWithContentsOfFile:jsonFilePath
                                                     encoding:NSUTF8StringEncoding
                                                        error:NULL];
    //encrypt
    CocoaSecurityResult *result = [CocoaSecurity aesEncrypt:jsonString key:data[@"fingerPrint"]];

    NSError *error = nil;
    [result.data writeToFile:jsonFilePath options:NSDataWritingAtomic error:&error];
    NSLog(@"Write returned error: %@", [error localizedDescription]);

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:kNilOptions
                                                           error:&error];

    [self updateLessonSettingsWithJSON:json];
}

-(void) updateClipToCoreData:(NSDictionary*)data
{
    self.name_he_il = data[@"name_he_il"];
    self.name_en_us = data[@"name_en_us"];
    NSDecimalNumber *version = [NSDecimalNumber decimalNumberWithString:data[@"version"]];
    self.lessonDescription_he_il = data[@"lessonDescription_he_il"];
    self.lessonDescription_en_us = data[@"lessonDescription_en_us"];
    self.version = version;
    self.fileName = data[@"fileName"];
    self.identifier = data[@"identifier"];
    self.updatedAt = data[@"updatedAt"];
    self.createdAt = data[@"createdAt"];
    self.category1_en_us = data[@"category1_en_us"];
    self.category1_he_il = data[@"category1_he_il"];
    self.category1_order = data[@"category1_order"];
    self.category2_en_us = data[@"category2_en_us"];
    self.category2_he_il = data[@"category2_he_il"];
    self.category2_order = data[@"category2_order"];
    self.category3_en_us = data[@"category3_en_us"];
    self.category3_he_il = data[@"category3_he_il"];
    self.category3_order = data[@"category3_order"];
    self.category4_en_us = data[@"category4_en_us"];
    self.category4_he_il = data[@"category4_he_il"];
    self.category4_order = data[@"category4_order"];
    self.updatedByMyMentor = data[@"updatedByMyMentor"];
    self.teacherId = data[@"teacherId"];
    self.teacherGroupId = data[@"teacherGroupId"];
    self.teacherParentGroupId = data[@"teacherParentGroupId"];
    self.defaultVoicePromptsId = data[@"defaultVoicePromptsId"];
    self.lessonId = data[@"lessonId"];
    self.lessonContentWorldId = data[@"lessonContentWorldId"];
    self.lessonIncludingSupport = data[@"lessonIncludingSupport"];
    self.lessonDemo = data[@"lessonDemo"];
    self.lessonDuration = data[@"lessonDuration"];
    self.lessonNikudActive = data[@"lessonNikudActive"];
    self.lessonTeamimActive = data[@"lessonTeamimActive"];
    self.lessonRamarks_he_il =  data[@"lessonRemarks_he_il"];
    self.lessonRemarks_en_us = data[@"lessonRemarks_en_us"];
    self.teacherName_he_il = data[@"teacherName_he_il"];
    self.teacherName_en_us = data[@"teacherName_en_us"];
    self.performer_he_il = data[@"performer_he_il"];
    self.performer_en_us = data[@"performer_en_us"];
    self.lessonFingerPrint = data[@"fingerPrint"];
    [self updateLessonSettings:data];
}

- (NSMutableDictionary*)loadClipFromCoreData
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithCapacity:1];

    if (self.category1_en_us)
    {
        [data setObject:self.category1_en_us forKey:@"category1_en_us"];
    }
    if (self.category1_he_il)
    {
        [data setObject:self.category1_he_il forKey:@"category1_he_il"];
    }
    if (self.category1_order)
    {
        [data setObject:self.category1_order forKey:@"category1_order"];
    }
    if (self.category2_en_us)
    {
        [data setObject:self.category2_en_us forKey:@"category2_en_us"];
    }
    if (self.category2_he_il)
    {
        [data setObject:self.category2_he_il forKey:@"category2_he_il"];
    }
    if (self.category2_order)
    {
        [data setObject:self.category2_order forKey:@"category2_order"];
    }
    if (self.category3_en_us)
    {
        [data setObject:self.category3_en_us forKey:@"category3_en_us"];
    }
    if (self.category3_he_il)
    {
        [data setObject:self.category3_he_il forKey:@"category3_he_il"];
    }
    if (self.category3_order)
    {
        [data setObject:self.category3_order forKey:@"category3_order"];
    }
    if (self.category4_en_us)
    {
        [data setObject:self.category4_en_us forKey:@"category4_en_us"];
    }
    if (self.category4_he_il)
    {
        [data setObject:self.category4_he_il forKey:@"category4_he_il"];
    }
    if (self.category4_order)
    {
        [data setObject:self.category4_order forKey:@"category4_order"];
    }
    if (self.updatedByMyMentor)
    {
        [data setObject:self.updatedByMyMentor forKey:@"updatedByMyMentor"];
    }
    if (self.performer_he_il)
    {
        [data setObject:self.performer_he_il forKey:@"performer_he_il"];
    }
    if (self.performer_en_us)
    {
        [data setObject:self.performer_en_us forKey:@"performer_en_us"];
    }
    if (self.teacherId)
    {
        [data setObject:self.teacherId forKey:@"teacherId"];
    }
    if (self.teacherGroupId)
    {
        [data setObject:self.teacherGroupId forKey:@"teacherGroupId"];
    }
    if (self.teacherParentGroupId)
    {
        [data setObject:self.teacherParentGroupId forKey:@"teacherParentGroupId"];
    }
    if (self.defaultVoicePromptsId)
    {
        [data setObject:self.defaultVoicePromptsId forKey:@"defaultVoicePromptsId"];
    }
    if (self.lessonFontSize)
    {
        [data setObject:self.lessonFontSize forKey:@"lessonFontSize"];
    }
    if (self.showHighlightedWords)
    {
        [data setObject:self.showHighlightedWords forKey:@"showHighlightedWords"];
    }
    if (self.arrowDirectionType)
    {
        [data setObject:self.arrowDirectionType forKey:@"arrowDirectionType"];
    }
    if (self.repeatLessonStartFrom)
    {
        [data setObject:self.repeatLessonStartFrom forKey:@"repeatLessonStratFrom"];
    }
    if (self.lessonContentWorldId)
    {
        [data setObject:self.lessonContentWorldId forKey:@"lessonContentWorldId"];
    }
    if (self.lessonIncludingSupport)
    {
        [data setObject:self.lessonIncludingSupport forKey:@"lessonIncludingSupport"];
    }
    if (self.lessonDemo)
    {
        [data setObject:self.lessonDemo forKey:@"lessonDemo"];
    }
    if (self.lessonDuration)
    {
        [data setObject:self.lessonDuration forKey:@"lessonDuration"];
    }

    if (self.createdAt)
    {
        [data setObject:self.createdAt forKey:@"createdAt"];
    }
    if (self.lessonFingerPrint)
    {
        [data setObject:self.lessonFingerPrint forKey:@"fingerPrint"];
    }
    if (self.lessonNikudActive)
    {
        [data setObject:self.lessonNikudActive forKey:@"lessonNikudActive"];
    }
    if (self.lessonTeamimActive)
    {
        [data setObject:self.lessonTeamimActive forKey:@"lessonTeamimActive"];
    }
    if (self.lessonRamarks_he_il)
    {
        [data setObject:self.lessonRamarks_he_il forKey:@"lessonRemarks_he_il"];
    }
    if (self.lessonRemarks_en_us)
    {
        [data setObject:self.lessonRemarks_en_us forKey:@"lessonRemarks_en_us"];
    }
    if (self.createdByUser)
    {
        [data setObject:self.createdByUser forKey:@"createdByUser"];
    }
    if (self.fileName)
    {
        [data setObject:self.fileName forKey:@"fileName"];
    }
    if (self.identifier)
    {
        [data setObject:self.identifier forKey:@"identifier"];
    }
    if (self.lessonDescription_he_il)
    {
        [data setObject:self.lessonDescription_he_il forKey:@"lessonDescription_he_il"];
    }
    if (self.lessonDescription_en_us)
    {
        [data setObject:self.lessonDescription_en_us forKey:@"lessonDescription_en_us"];
    }
    if (self.name_he_il)
    {
        [data setObject:self.name_he_il forKey:@"name_he_il"];
    }
    if (self.name_en_us)
    {
        [data setObject:self.name_en_us forKey:@"name_en_us"];
    }
    if (self.teacherName_he_il)
    {
        [data setObject:self.teacherName_he_il forKey:@"teacherName_he_il"];
    }
    if (self.teacherName_en_us)
    {
        [data setObject:self.teacherName_en_us forKey:@"teacherName_en_us"];
    }
    if (self.locked)
    {
        [data setObject:self.locked forKey:@"locked"];
    }
    if (self.favorite)
    {
        [data setObject:self.favorite forKey:@"favorite"];
    }
    if (self.updatedAt)
    {
        [data setObject:self.updatedAt forKey:@"updatedAt"];
    }
    if (self.version)
    {
        NSString *version = [NSString stringWithFormat:@"%@",self.version];
        [data setObject:version forKey:@"version"];
    }
    if (self.lessonId)
    {
        [data setObject:self.lessonId forKey:@"lessonId"];
    }
    if (self.purchaseId)
    {
        [data setObject:self.purchaseId forKey:@"purchaseId"];
    }

    return data;
}

@end

//
//  Settings.m
//  MyMentorV2
//
//  Created by Walter Yaron on 4/16/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import <Parse/Parse.h>
#import "Settings.h"
#import "AppDelegate.h"
#import "VoicePrompts.h"
#import "Defines.h"
#import "AppSettings.h"
#import "ContentWorld.h"
#import "User.h"
#import "Clip.h"

@interface Settings ()

@property (strong, nonatomic) NSMutableDictionary *strings;
@property (strong, nonatomic) NSArray *localPrompts;

@end

@implementation Settings

- (id)init
{
    self = [super init];
    if (self)
    {
        self.managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
        self.serverPrompts = [[NSMutableArray alloc] initWithCapacity:1];
        self.prompts = [[NSMutableDictionary alloc] initWithCapacity:1];
        self.currentLanguage = [NSLocale preferredLanguages][0];

        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_4)
        {
            NSArray<NSString *> *availableLanguages = @[@"en", @"es", @"de", @"ru", @"zh-Hans", @"ja", @"pt",@"he"];
            self.currentLanguage = [[[NSBundle preferredLocalizationsFromArray:availableLanguages] firstObject] mutableCopy];
        }

        if ([self.currentLanguage isEqualToString:@"he"])
            self.appSettingsOldLanguage = self.currentLanguage = @"he_il";
        else
            self.appSettingsOldLanguage = self.currentLanguage = @"en_us";

        [self loadAppSettingsFromCoreData];
        [self loadUserFromCoreData];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static Settings *myInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myInstance = [[self alloc] init];
    });
    return myInstance;
}

- (void)setIdletimer:(BOOL)new_idletimer
{
    if (_idletimer != new_idletimer)
    {
        _idletimer = new_idletimer;
        [[UIApplication sharedApplication] setIdleTimerDisabled:_idletimer];
    }
}

- (void)setAppSettingsNaturalLanguage:(BOOL)appSettingsNaturalLanguage
{
    _appSettingsNaturalLanguage = appSettingsNaturalLanguage;
//    if (appSettingsNaturalLanguage) {
        self.currentLanguage = self.appSettingsOldLanguage;
//    }
//    else
//    {
//        if ([self.currentLanguage isEqualToString:@"en_us"])
//        {
//            self.currentLanguage = @"he_il";
//        }
//        else if ([self.currentLanguage isEqualToString:@"he_il"])
//        {
//            self.currentLanguage = @"en_us";
//        }
//
//    }
}

- (NSString*)getStringByName:(NSString*)viewName
{
    NSString *code = [NSString stringWithFormat:@"IPHONE_STRING_%@",viewName];
    NSDictionary *data = self.strings[code];
    NSString *string = nil;
    if (data)
    {
//        if (self.appSettingsNaturalLanguage)
            string = data[self.currentLanguage];
//        else
//        {
//            NSMutableArray *keys = [[data allKeys] mutableCopy];
//            [keys removeObject:self.currentLanguage];
//            [keys removeObject:@"code"];
//            if ([keys count]) {
//                NSString* key = keys[0];
//                string = data[key];
//            }
//        }
    }
    return string;
}

- (void)saveCustomObject:(id)object key:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];

}

- (id)loadCustomObjectWithKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    id object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}

- (void)loadSettingsFromServer
{
//    NSTimeInterval timestamp = [[NSUserDefaults standardUserDefaults] doubleForKey:@"serverSettings"];
//    if (([[NSDate date] timeIntervalSince1970] - timestamp <= 60 * 60 * 24)) {
////        self.strings = [self loadCustomObjectWithKey:@"serverStrings"];
//        self.strings = [[NSUserDefaults standardUserDefaults] objectForKey:@"serverStrings"];
//        return;
//    }

    PFQuery *query = [PFQuery queryWithClassName:@"Strings"];
    [query whereKey:@"code" hasPrefix:@"IPHONE_STRING_"];
    query.limit = 1000;
    self.strings = [[NSMutableDictionary alloc] initWithCapacity:1];


    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
//    dispatch_semaphore_t sema = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)


    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
    {
        if (!error)
        {
            [objects enumerateObjectsUsingBlock:^(PFObject *obj, NSUInteger idx, BOOL *stop)
             {
                 NSDictionary *data =  @{ @"en_us" : obj[@"en_us"],
                                          @"he_il" : obj[@"he_il"],
                                          @"code" : obj[@"code"]};

                 [self.strings setObject:data forKey:obj[@"code"]];
             }];

            [[NSUserDefaults standardUserDefaults] setObject:self.strings forKey:@"serverStrings"];
            [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:@"serverSettings"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        dispatch_semaphore_signal(sema);
    }];

    while (dispatch_semaphore_wait(sema, DISPATCH_TIME_NOW))
    {
        [[NSRunLoop currentRunLoop]
         runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    }

//    dispatch_time_t timeoutTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
//    if (dispatch_semaphore_wait(sema, timeoutTime))
//    {
//        XCTFail(@"%@ timed out", URLString);
//        NSLog(@"Error");
//    }

}

- (void)loadAppSettingsFromCoreData
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    dispatch_async(dispatch_get_main_queue(), ^
    {
        NSError *error = nil;
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AppSettings"];
        [request setFetchLimit:1];
        NSArray *items = [self.managedObjectContext executeFetchRequest:request error:&error];
        if ([items count])
        {
            AppSettings *appSettings = items[0];
            self.appSettingsReplayLessonIndex = [appSettings.appSettingsReplayLessonIndex integerValue];
            self.appSettingsArrowDirectionType = [appSettings.appSettingsArrowDirectionType integerValue];
            self.appSettingsContentWorldId = appSettings.appSettingsContentWorldId;
            self.appSettingsShowHighlightedWords = [appSettings.appSettingsShowHighlightedWords integerValue];
            self.appSettingsNaturalLanguage = [appSettings.appSettingsNaturalLanguage boolValue];
            self.appSettingsPlayType = [appSettings.appSettingsPlayType integerValue];
            self.appSettingsSaveUserAudio = [appSettings.appSettingsSaveUserAudio boolValue];
            self.environmentProduction = [appSettings.appSettingsEnvironment boolValue];
        }
        else
        {
            self.appSettingsReplayLessonIndex = StepType3;
            if ([self.currentLanguage isEqualToString:@"he_il"])
                self.appSettingsArrowDirectionType = ArrowDirectionTypeLeft;
            else
                self.appSettingsArrowDirectionType = ArrowDirectionTypeRight;

            self.appSettingsShowHighlightedWords = ShowHighlightedWordsTypeShow;
            self.appSettingsNaturalLanguage = NO;
            self.appSettingsPlayType = PlayTypeInterrupted;
            self.appSettingsSaveUserAudio = YES;
            self.environmentProduction = YES;
        }
        dispatch_semaphore_signal(sema);
    });

    while (dispatch_semaphore_wait(sema, DISPATCH_TIME_NOW))
    {
        [[NSRunLoop currentRunLoop]
         runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    }


    self.strings = [[NSUserDefaults standardUserDefaults]objectForKey:@"serverStrings"];
}

- (void)saveAppSettingsToCoreData
{
    NSError *error = nil;
    AppSettings *appSettings;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AppSettings"];
    NSArray *items = [self.managedObjectContext executeFetchRequest:request error:&error];

    if ([items count])
    {
        appSettings = items[0];
    }
    else
    {
        appSettings = [NSEntityDescription insertNewObjectForEntityForName:@"AppSettings"
                                              inManagedObjectContext:self.managedObjectContext];
    }

    appSettings.appSettingsReplayLessonIndex = @(self.appSettingsReplayLessonIndex);
    appSettings.appSettingsArrowDirectionType = @(self.appSettingsArrowDirectionType);
    appSettings.appSettingsContentWorldId = self.appSettingsContentWorldId;
    appSettings.appSettingsShowHighlightedWords = @(self.appSettingsShowHighlightedWords);
    appSettings.appSettingsNaturalLanguage = @(self.appSettingsNaturalLanguage);
    appSettings.appSettingsPlayType = @(self.appSettingsPlayType);
    appSettings.appSettingsSaveUserAudio = @(self.appSettingsSaveUserAudio);
    appSettings.appSettingsEnvironment = @(self.environmentProduction);

    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

- (ContentWorld*)loadContentWorldFromCoreData
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ContentWorld"];
    [request setFetchLimit:1];

    NSError *error = nil;

    NSArray *items = [self.managedObjectContext executeFetchRequest:request error:&error];

    ContentWorld *world;

    if ([items count])
    {
        world = items[0];
    }
    return world;
}

- (void)saveContentWorldToCoreData:(PFObject*)obj save:(BOOL)willSave
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ContentWorld"];
        [request setFetchLimit:1];

        NSError *error = nil;

        NSArray *items = [self.managedObjectContext executeFetchRequest:request error:&error];

        ContentWorld *world;

        if ([items count])
        {
            world = items[0];
        }
        else
        {
            world = [NSEntityDescription insertNewObjectForEntityForName:@"ContentWorld"
                                                  inManagedObjectContext:self.managedObjectContext];
        }

        [obj fetch];


        PFQuery *query = [PFQuery queryWithClassName:@"CategoryLabels"];
//        NSLog(@"%@",obj.objectId);
        [query whereKey:@"contentType" equalTo:obj];

        NSArray *objects = [query findObjects:&error];
        if (!error)
        {
            [objects enumerateObjectsUsingBlock:^(PFObject *content, NSUInteger idx, BOOL *stop)
            {
                if ([content[@"culture"] isEqualToString:@"he-il"])
                {
                    world.category1_he_il = content[@"category1"];
                    world.category2_he_il = content[@"category2"];
                    world.category3_he_il = content[@"category3"];
                    world.category4_he_il = content[@"category4"];
                }
                if ([content[@"culture"] isEqualToString:@"en-us"])
                {
                    world.category1_en_us = content[@"category1"];
                    world.category2_en_us = content[@"category2"];
                    world.category3_en_us = content[@"category3"];
                    world.category4_en_us = content[@"category4"];
                }
            }];
        }

        world.worldId = obj.objectId;
        world.name_he_il = obj[@"value_he_il"];
        world.name_en_us = obj[@"value_en_us"];

        if (![self.managedObjectContext save:&error])
        {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }

        self.appSettingsContentWorldId = obj.objectId;
        [self saveAppSettingsToCoreData];

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];

        NSString *directory = obj.objectId;
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:directory];
        NSFileManager *manager = [[NSFileManager alloc] init];
        if (![manager fileExistsAtPath:documentsDirectory])
            [manager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder

        PFFileObject *file;
        NSData *fileData;
        NSString *imagePath;

        if ([[UIScreen mainScreen] bounds].size.height == 480.f)
        {
            file = obj[@"WorldHomePage_i4"];
            fileData = [file getData];
            imagePath = [documentsDirectory stringByAppendingPathComponent:@"splash.jpg"];
            [fileData writeToFile:imagePath options:NSDataWritingAtomic error:&error];

        }
        if ([[UIScreen mainScreen] bounds].size.height == 568.f)
        {
            file = obj[@"WorldHomePage_i5"];
            fileData = [file getData];
            imagePath = [documentsDirectory stringByAppendingPathComponent:@"splash.jpg"];
            [fileData writeToFile:imagePath options:NSDataWritingAtomic error:&error];
        }

        if (willSave)
        {
            [[PFUser currentUser] setObject:obj forKey:@"contentType"];
            [[PFUser currentUser] save];
        }

        [self saveUserToCoreData];
    });
}

- (void)loadVoicePromptsFromCoreData:(NSString*)voiceId
{
    [self.prompts removeAllObjects];

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VoicePrompts"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"voiceId == %@", voiceId];
    [request setPredicate:predicate];
    [request setFetchLimit:1];

    NSError *error = nil;

    NSArray *items = [self.managedObjectContext executeFetchRequest:request error:&error];

    if ([items count])
    {
        VoicePrompts *voicePrompts = items[0];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];

        [self.prompts setObject:[documentsDirectory stringByAppendingPathComponent:voicePrompts.voicePromptFile0] forKey:@(AppAudioOK)];
        [self.prompts setObject:[documentsDirectory stringByAppendingPathComponent:voicePrompts.voicePromptFile1] forKey:@(AppAudioCancel)];
        [self.prompts setObject:[documentsDirectory stringByAppendingPathComponent:voicePrompts.voicePromptFile2] forKey:@(AppAudioListenToMe)];
        [self.prompts setObject:[documentsDirectory stringByAppendingPathComponent:voicePrompts.voicePromptFile3] forKey:@(AppAudioListenToMeAgain)];
        [self.prompts setObject:[documentsDirectory stringByAppendingPathComponent:voicePrompts.voicePromptFile4] forKey:@(AppAudioListenToUs)];
        [self.prompts setObject:[documentsDirectory stringByAppendingPathComponent:voicePrompts.voicePromptFile5] forKey:@(AppAudioListenToYourself)];
        [self.prompts setObject:[documentsDirectory stringByAppendingPathComponent:voicePrompts.voicePromptFile6] forKey:@(AppAudioNowYou)];
        [self.prompts setObject:[documentsDirectory stringByAppendingPathComponent:voicePrompts.voicePromptFile7] forKey:@(AppAudioReadingTogether)];
        [self.prompts setObject:[documentsDirectory stringByAppendingPathComponent:voicePrompts.voicePromptFile8] forKey:@(AppAudioIfContinue)];
        [self.prompts setObject:[documentsDirectory stringByAppendingPathComponent:voicePrompts.voicePromptFile9] forKey:@(AppAudioEndOfLesson)];
    }
    else
    {
        NSLog(@"error");
    }
}

- (void)loadLocalVoicePromptsFromCoreData:(VoicePrompts*)voicePrompts
{
    [self.prompts removeAllObjects];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    [self.prompts setObject:[documentsDirectory stringByAppendingPathComponent:voicePrompts.voicePromptFile0] forKey:@(AppAudioOK)];
    [self.prompts setObject:[documentsDirectory stringByAppendingPathComponent:voicePrompts.voicePromptFile1] forKey:@(AppAudioCancel)];
    [self.prompts setObject:[documentsDirectory stringByAppendingPathComponent:voicePrompts.voicePromptFile2] forKey:@(AppAudioListenToMe)];
    [self.prompts setObject:[documentsDirectory stringByAppendingPathComponent:voicePrompts.voicePromptFile3] forKey:@(AppAudioListenToMeAgain)];
    [self.prompts setObject:[documentsDirectory stringByAppendingPathComponent:voicePrompts.voicePromptFile4] forKey:@(AppAudioListenToUs)];
    [self.prompts setObject:[documentsDirectory stringByAppendingPathComponent:voicePrompts.voicePromptFile5] forKey:@(AppAudioListenToYourself)];
    [self.prompts setObject:[documentsDirectory stringByAppendingPathComponent:voicePrompts.voicePromptFile6] forKey:@(AppAudioNowYou)];
    [self.prompts setObject:[documentsDirectory stringByAppendingPathComponent:voicePrompts.voicePromptFile7] forKey:@(AppAudioReadingTogether)];
    [self.prompts setObject:[documentsDirectory stringByAppendingPathComponent:voicePrompts.voicePromptFile8] forKey:@(AppAudioIfContinue)];
    [self.prompts setObject:[documentsDirectory stringByAppendingPathComponent:voicePrompts.voicePromptFile9] forKey:@(AppAudioEndOfLesson)];
}

- (void)updateVoicePromptsFiles:(PFObject*)obj
{
    NSError *error = nil;
    NSData *fileData;
    NSString *imagePath;
    PFFileObject *file;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *directory = obj.objectId;
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:directory];
    NSFileManager *manager = [[NSFileManager alloc] init];

    if (![manager fileExistsAtPath:documentsDirectory])
        [manager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder

    [self.prompts removeAllObjects];

    file = obj[@"OkContinue"];
    fileData = [file getData];
    imagePath = [documentsDirectory stringByAppendingPathComponent:@"OkContinue.mp3"];
    [fileData writeToFile:imagePath options:NSDataWritingAtomic error:&error];
    [self.prompts setObject:imagePath forKey:@(AppAudioOK)];

    file = obj[@"OkAgain"];
    fileData = [file getData];
    imagePath = [documentsDirectory stringByAppendingPathComponent:@"OkAgain.mp3"];
    [fileData writeToFile:imagePath options:NSDataWritingAtomic error:&error];
    [self.prompts setObject:imagePath forKey:@(AppAudioCancel)];

    file = obj[@"ListenToMe"];
    fileData = [file getData];
    imagePath = [documentsDirectory stringByAppendingPathComponent:@"ListenToMe.mp3"];
    [fileData writeToFile:imagePath options:NSDataWritingAtomic error:&error];
    [self.prompts setObject:imagePath forKey:@(AppAudioListenToMe)];

    file = obj[@"ListenToMeAgain"];
    fileData = [file getData];
    imagePath = [documentsDirectory stringByAppendingPathComponent:@"ListenToMeAgain.mp3"];
    [fileData writeToFile:imagePath options:NSDataWritingAtomic error:&error];
    [self.prompts setObject:imagePath forKey:@(AppAudioListenToMeAgain)];

    file = obj[@"ListenToUs"];
    fileData = [file getData];
    imagePath = [documentsDirectory stringByAppendingPathComponent:@"ListenToUs.mp3"];
    [fileData writeToFile:imagePath options:NSDataWritingAtomic error:&error];
    [self.prompts setObject:imagePath forKey:@(AppAudioListenToUs)];

    file = obj[@"ListenToYourself"];
    fileData = [file getData];
    imagePath = [documentsDirectory stringByAppendingPathComponent:@"ListenToYourself.mp3"];
    [fileData writeToFile:imagePath options:NSDataWritingAtomic error:&error];
    [self.prompts setObject:imagePath forKey:@(AppAudioListenToYourself)];

    file = obj[@"NowYou"];
    fileData = [file getData];
    imagePath = [documentsDirectory stringByAppendingPathComponent:@"NowYou.mp3"];
    [fileData writeToFile:imagePath options:NSDataWritingAtomic error:&error];
    [self.prompts setObject:imagePath forKey:@(AppAudioNowYou)];

    file = obj[@"ReadingTogether"];
    fileData = [file getData];
    imagePath = [documentsDirectory stringByAppendingPathComponent:@"ReadingTogether.mp3"];
    [fileData writeToFile:imagePath options:NSDataWritingAtomic error:&error];
    [self.prompts setObject:imagePath forKey:@(AppAudioReadingTogether)];

    file = obj[@"IfContinue"];
    fileData = [file getData];
    imagePath = [documentsDirectory stringByAppendingPathComponent:@"IfContinue.mp3"];
    [fileData writeToFile:imagePath options:NSDataWritingAtomic error:&error];
    [self.prompts setObject:imagePath forKey:@(AppAudioIfContinue)];

    file = obj[@"EndOfLessonSeeYou"];
    fileData = [file getData];
    imagePath = [documentsDirectory stringByAppendingPathComponent:@"EndOfLessonSeeYou.mp3"];
    [fileData writeToFile:imagePath options:NSDataWritingAtomic error:&error];
    [self.prompts setObject:imagePath forKey:@(AppAudioEndOfLesson)];
}

- (VoicePrompts*)searchVoicePromptInCoreData:(NSString*)identifier
{
    __block VoicePrompts *foundVoicePrompts = nil;
    [self.localPrompts enumerateObjectsUsingBlock:^(VoicePrompts *obj, NSUInteger idx, BOOL *stop)
    {
        if ([obj.voiceId isEqual:identifier])
        {
            foundVoicePrompts = obj;
            *stop = YES;
        }
    }];

    return foundVoicePrompts;
}

- (void)saveVoicePromptsToCoreData:(PFObject*)serverVoicePrompts
{
//    dispatch_async(dispatch_get_main_queue(), ^{

        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VoicePrompts"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"voiceId == %@", serverVoicePrompts.objectId];
        [request setPredicate:predicate];
        [request setFetchLimit:1];

        NSError *error = nil;

        NSArray *items = [self.managedObjectContext executeFetchRequest:request error:&error];

        VoicePrompts *voicePrompts;

        if ([items count])
        {
            voicePrompts = items[0];
        }
        else
        {
            voicePrompts = [NSEntityDescription insertNewObjectForEntityForName:@"VoicePrompts"
                                                  inManagedObjectContext:self.managedObjectContext];
        }

        voicePrompts.voiceId = serverVoicePrompts.objectId;
        voicePrompts.voiceType = serverVoicePrompts[@"VoiceType"];
        voicePrompts.updateAt = serverVoicePrompts.updatedAt;

        NSString *directory = serverVoicePrompts.objectId;

        voicePrompts.voicePromptFile0 = [directory stringByAppendingPathComponent:@"OkContinue.mp3"];
        voicePrompts.voicePromptFile1 = [directory stringByAppendingPathComponent:@"OkAgain.mp3"];
        voicePrompts.voicePromptFile2 = [directory stringByAppendingPathComponent:@"ListenToMe.mp3"];
        voicePrompts.voicePromptFile3 = [directory stringByAppendingPathComponent:@"ListenToMeAgain.mp3"];
        voicePrompts.voicePromptFile4 = [directory stringByAppendingPathComponent:@"ListenToUs.mp3"];
        voicePrompts.voicePromptFile5 = [directory stringByAppendingPathComponent:@"ListenToYourself.mp3"];
        voicePrompts.voicePromptFile6 = [directory stringByAppendingPathComponent:@"NowYou.mp3"];
        voicePrompts.voicePromptFile7 = [directory stringByAppendingPathComponent:@"ReadingTogether.mp3"];
        voicePrompts.voicePromptFile8 = [directory stringByAppendingPathComponent:@"IfContinue.mp3"];
        voicePrompts.voicePromptFile9 = [directory stringByAppendingPathComponent:@"EndOfLessonSeeYou.mp3"];

        if (![self.managedObjectContext save:&error])
        {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
//    });
}

- (void)loadVoicePromptsFromServer:(NSString*)teacherId
{
    [self.serverPrompts removeAllObjects];

    PFObject *teacher = nil;
    if (teacherId)
    {
        teacher = [PFObject objectWithoutDataWithClassName:@"_User" objectId:teacherId];
        NSError *error = nil;
        [teacher fetch:&error];
    }

    PFQuery *queryMyMentor = [PFQuery queryWithClassName:@"VoicePrompts"];
    [queryMyMentor whereKey:@"MyMentorVoice" equalTo:@YES];

    PFQuery *queryTeacher = [PFQuery queryWithClassName:@"VoicePrompts"];
    PFQuery *query = nil;

    if (teacher)
    {
        [queryTeacher whereKey:@"Teacher" equalTo:teacher];
        query = [PFQuery orQueryWithSubqueries:@[queryMyMentor,queryTeacher]];
    }
    else
    {
        query = [PFQuery orQueryWithSubqueries:@[queryMyMentor]];
    }

    [query orderByAscending:@"Sorting"];
    __weak Settings *weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             [weakSelf.serverPrompts addObjectsFromArray:objects];
             [[NSNotificationCenter defaultCenter] postNotificationName:kVoicePromptsLoadStatus
                                                                 object:@YES
                                                               userInfo:nil];
         }
         else
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:kVoicePromptsLoadStatus
                                                                 object:@NO
                                                               userInfo:nil];
         }
     }];
}

- (BOOL)checkIfVoicePromptsExist:(NSString*)voicePromptsId
{
    NSError *error = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VoicePrompts"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"voiceId == %@", voicePromptsId];
    [request setPredicate:predicate];
    [request setFetchLimit:1];

    NSArray *items = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ([items count])
    {
        return YES;
    }

    return NO;
}

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
            service, (__bridge id)kSecAttrService,
            service, (__bridge id)kSecAttrAccount,
            (__bridge id)kSecAttrAccessibleAfterFirstUnlock, (__bridge id)kSecAttrAccessible,
            nil];
}

+ (void)saveKeychain:(NSString *)service data:(id)data {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)kSecValueData];
    SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
}

+ (id)loadKeychain:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        }
        @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        }
        @finally {}
    }
    if (keyData) CFRelease(keyData);
    return ret;
}

+ (void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
}


- (void)saveVoicePrompts:(NSUInteger)index
{
    NSError *error = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VoicePrompts"];
    self.localPrompts = [self.managedObjectContext executeFetchRequest:request error:&error];
    PFObject *obj = self.serverPrompts[index];

    VoicePrompts *voicePrompts = [self searchVoicePromptInCoreData:obj.objectId];
    if (voicePrompts)
    {
        NSComparisonResult result = [obj.updatedAt compare:voicePrompts.updateAt];
        if (result != NSOrderedSame)
        {
            [self updateVoicePromptsFiles:obj];
            [self saveVoicePromptsToCoreData:obj];
        }
        else
        {
            [self loadLocalVoicePromptsFromCoreData:voicePrompts];
        }
    }
    else
    {
        [self updateVoicePromptsFiles:obj];
        [self saveVoicePromptsToCoreData:obj];
    }
}

- (User*)loadUserFromCoreData
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    [request setFetchLimit:1];
    NSError *error = nil;
    NSArray *items = [self.managedObjectContext executeFetchRequest:request error:&error];
    User *user = nil;

    if ([items count])
    {
        user = items[0];
        self.deviceIdentifier = user.deviceIdentifier;
    }
    else
    {
        NSString *uuidString = [Settings loadKeychain:@"com.mymentorv2.deviceidentifier"];
        if (!uuidString) {
        self.deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            [Settings saveKeychain:@"com.mymentorv2.deviceidentifier" data:self.deviceIdentifier];
        }
        else
            self.deviceIdentifier = uuidString;
    }

    return user;
}

- (void)saveUserToCoreData
{
//    dispatch_async(dispatch_get_main_queue(), ^
//    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        [request setFetchLimit:1];

        NSError *error = nil;

        NSArray *items = [self.managedObjectContext executeFetchRequest:request error:&error];

        User *user = nil;

        if ([items count])
        {
            user = items[0];
        }
        else
        {
            user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                  inManagedObjectContext:self.managedObjectContext];
        }

        PFUser *currentUser =  [PFUser currentUser];
        PFObject *parent = nil;
        if (currentUser)
        {
            PFObject *contentType = currentUser[@"contentType"];

            PFObject *adminData = currentUser[@"adminData"];
            [adminData fetch];
            PFObject *group = adminData[@"group"];
            if (group)
            {
                [group fetchIfNeeded];
                user.groupId = group.objectId;
                parent = group[@"parent"];
                if (parent)
                {
                    [parent fetchIfNeeded];
                    user.parentGroupId = parent.objectId;
                }
            }
            user.userId = currentUser.objectId;
            user.deviceIdentifier = self.deviceIdentifier;
            user.updateAt = currentUser.updatedAt;
            user.contentWorldId = contentType.objectId;
            user.firstName_he_il = currentUser[@"firstName_he_il"];
            user.firstName_en_us = currentUser[@"firstName_en_us"];
            user.changeEnvironment = currentUser[@"changeEnvironment"];
            PFObject *world = currentUser[@"worldTester"];
            if (world)
            {
                user.contentTester = world.objectId;
            }

            PFQuery *query = [PFRole query];
            [query whereKey:@"name" equalTo:@"Administrators"];
            [query whereKey:@"users" equalTo:currentUser];

            NSArray *results = [query findObjects];
            if ([results count])
            {
                user.admin = @YES;
            }
            else
            {
                user.admin = @NO;
            }

            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];

            NSString *directory = group.objectId;
            documentsDirectory = [documentsDirectory stringByAppendingPathComponent:directory];
            NSFileManager *manager = [[NSFileManager alloc] init];

            if (![manager fileExistsAtPath:documentsDirectory])
                [manager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder

            PFFileObject *file;
            NSData *fileData;
            NSString *imagePath;

            if ([[UIScreen mainScreen] bounds].size.height == 480.f)
            {
                file = group[@"groupPromo_i4"];
                fileData = [file getData];
                imagePath = [documentsDirectory stringByAppendingPathComponent:@"group.jpg"];
                [fileData writeToFile:imagePath options:NSDataWritingAtomic error:&error];

            }
            if ([[UIScreen mainScreen] bounds].size.height >= 568.f)
            {
                file = group[@"groupPromo_i5"];
                fileData = [file getData];
                imagePath = [documentsDirectory stringByAppendingPathComponent:@"group.jpg"];
                [fileData writeToFile:imagePath options:NSDataWritingAtomic error:&error];
            }

            if (parent)
            {

                directory = parent.objectId;
                documentsDirectory = [paths objectAtIndex:0];
                documentsDirectory = [documentsDirectory stringByAppendingPathComponent:directory];

                if (![manager fileExistsAtPath:documentsDirectory])
                    [manager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder


                if ([[UIScreen mainScreen] bounds].size.height == 480.f)
                {
                    file = parent[@"groupPromo_i4"];
                    fileData = [file getData];
                    imagePath = [documentsDirectory stringByAppendingPathComponent:@"parentgroup.jpg"];
                    [fileData writeToFile:imagePath options:NSDataWritingAtomic error:&error];

                }
                if ([[UIScreen mainScreen] bounds].size.height >= 568.f)
                {
                    file = parent[@"groupPromo_i5"];
                    fileData = [file getData];
                    imagePath = [documentsDirectory stringByAppendingPathComponent:@"parentgroup.jpg"];
                    [fileData writeToFile:imagePath options:NSDataWritingAtomic error:&error];
                }
            }
        }
        else
        {
            user.deviceIdentifier = self.deviceIdentifier;
            user.contentWorldId = [Settings sharedInstance].appSettingsContentWorldId;
        }

        if (![self.managedObjectContext save:&error])
        {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
//    });
}

+ (void)deleteUser
{
    NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    NSError *error;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    [array enumerateObjectsUsingBlock:^(User *obj, NSUInteger idx, BOOL *stop)
     {
         [managedObjectContext deleteObject:obj];
     }];
    [managedObjectContext save:nil];
}

+ (void)deleteClips
{
    NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Clip"];
    NSError *error;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    [array enumerateObjectsUsingBlock:^(Clip *obj, NSUInteger idx, BOOL *stop)
     {
         [managedObjectContext deleteObject:obj];
     }];
    [managedObjectContext save:nil];
    [[Settings sharedInstance] saveUserToCoreData];
}

+ (void)deleteAllUserFiles
{
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *manager = [[NSFileManager alloc] init];
    NSArray *contents = [manager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    for (NSString* item in contents)
    {
        if ([[item pathExtension] isEqualToString:@"html"] ||
            [[item pathExtension] isEqualToString:@"json"] ||
            [[item pathExtension] isEqualToString:@"mp3"])
        {
            error = nil;
            [manager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:item] error:&error];
            if (error)
            {
                NSLog(@"%@",[error localizedDescription]);
            }
        }
    }
}

+ (void)deleteContentWorlds
{
    NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ContentWorld"];
    NSError *error;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    [array enumerateObjectsUsingBlock:^(ContentWorld *obj, NSUInteger idx, BOOL *stop)
     {
         [managedObjectContext deleteObject:obj];
     }];
    [managedObjectContext save:nil];
}

@end

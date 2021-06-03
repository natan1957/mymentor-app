//
//  Settings.h
//  MyMentorV2
//
//  Created by Walter Yaron on 4/16/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Defines.h"
#import <Parse/Parse.h>

@class User;
@class ContentWorld;
@class VoicePrompts;

@interface Settings : NSObject

/**
 NSString that represent device current language
 Can be:

 - he_il = Hebrew
 - en_us = English

 */

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


/**
 NSString that represent device current language
 Can be:

 - he_il = Hebrew
 - en_us = English

 */

@property (strong, nonatomic) NSString *currentLanguage;

/**
 This property hold 
 */

@property (copy, nonatomic) NSString *sampleText;

@property (strong, nonatomic) NSString *deviceIdentifier;

/**
 This block is called before the element is written to the output attributed string
 */

@property (strong, nonatomic) NSMutableArray *serverPrompts;
/**
 This block is called before the element is written to the output attributed string
 */

@property (strong, nonatomic) NSMutableDictionary *prompts;
/**
 This block is called before the element is written to the output attributed string
 */

@property (strong, nonatomic) NSString *appSettingsContentWorldId;
/**
 This block is called before the element is written to the output attributed string
 */

@property (assign, nonatomic) ArrowDirectionType appSettingsArrowDirectionType;

/**
 Setting this property to `YES` causes the tree of parse nodes to be preserved until the end of the generation process. This allows to output the HTML structure of the document for debugging.
 */

@property (assign, nonatomic) ShowHighlightedWordsType appSettingsShowHighlightedWords;

/**
 Setting this property to `YES` causes the tree of parse nodes to be preserved until the end of the generation process. This allows to output the HTML structure of the document for debugging.
 */

@property (assign, nonatomic) StepType lessonSettingsReplayLessonIndex;

/**
 Setting this property to `YES` causes the tree of parse nodes to be preserved until the end of the generation process. This allows to output the HTML structure of the document for debugging.
 */

@property (assign, nonatomic) StepType appSettingsReplayLessonIndex;

/**
 Setting this property to `YES` causes the tree of parse nodes to be preserved until the end of the generation process. This allows to output the HTML structure of the document for debugging.
 */


//@property (assign, nonatomic) PlayType lessonSettingsPlayType;

@property (assign, nonatomic) PlayType appSettingsPlayType;

@property (assign, nonatomic) BOOL appSettingsNaturalLanguage;

@property (strong, nonatomic) NSString* appSettingsOldLanguage;

@property (assign, nonatomic) BOOL appSettingsSaveUserAudio;

@property (assign, nonatomic) BOOL lessonUpdate;

@property (assign, nonatomic) BOOL environmentProduction;

/**
 Setting this property to `YES` causes the tree of parse nodes to be preserved until the end of the generation process. This allows to output the HTML structure of the document for debugging.
 */

@property (assign, nonatomic, getter = isIdleTimer) BOOL idletimer;

/**
 Setting this property to `YES` causes the tree of parse nodes to be preserved until the end of the generation process. This allows to output the HTML structure of the document for debugging.
 */

+ (instancetype)sharedInstance;

/**
 Creates a layout frame with a given rectangle and string range. The layouter fills the layout frame with as many lines as fit. You can query [DTCoreTextLayoutFrame visibleStringRange] for the range the fits and create another layout frame that continues the text from there to create multiple pages, for example for an e-book.
 @param frame The rectangle to fill with text
 @param range The string range to fill, pass {0,0} for the entire string (as much as fits)
 */

- (void)loadSettingsFromServer;

/**
 Creates a layout frame with a given rectangle and string range. The layouter fills the layout frame with as many lines as fit. You can query [DTCoreTextLayoutFrame visibleStringRange] for the range the fits and create another layout frame that continues the text from there to create multiple pages, for example for an e-book.
 @param frame The rectangle to fill with text
 @param range The string range to fill, pass {0,0} for the entire string (as much as fits)
 */


- (NSString*)getStringByName:(NSString*)viewName;

/**
 Creates a layout frame with a given rectangle and string range. The layouter fills the layout frame with as many lines as fit. You can query [DTCoreTextLayoutFrame visibleStringRange] for the range the fits and create another layout frame that continues the text from there to create multiple pages, for example for an e-book.
 @param frame The rectangle to fill with text
 @param range The string range to fill, pass {0,0} for the entire string (as much as fits)
 */

- (BOOL)checkIfVoicePromptsExist:(NSString*)voicePromptsId;

/**
 Creates a layout frame with a given rectangle and string range. The layouter fills the layout frame with as many lines as fit. You can query [DTCoreTextLayoutFrame visibleStringRange] for the range the fits and create another layout frame that continues the text from there to create multiple pages, for example for an e-book.
 @param frame The rectangle to fill with text
 @param range The string range to fill, pass {0,0} for the entire string (as much as fits)
 */

- (void)loadVoicePromptsFromServer:(NSString*)teacherId;

/**
 Creates a layout frame with a given rectangle and string range. The layouter fills the layout frame with as many lines as fit. You can query [DTCoreTextLayoutFrame visibleStringRange] for the range the fits and create another layout frame that continues the text from there to create multiple pages, for example for an e-book.
 @param frame The rectangle to fill with text
 @param range The string range to fill, pass {0,0} for the entire string (as much as fits)
 */

- (void)saveVoicePrompts:(NSUInteger)index;

/**
 Creates a layout frame with a given rectangle and string range. The layouter fills the layout frame with as many lines as fit. You can query [DTCoreTextLayoutFrame visibleStringRange] for the range the fits and create another layout frame that continues the text from there to create multiple pages, for example for an e-book.
 @param frame The rectangle to fill with text
 @param range The string range to fill, pass {0,0} for the entire string (as much as fits)
 */

- (void)saveVoicePromptsToCoreData:(PFObject*)serverVoicePrompts;

/**
 Creates a layout frame with a given rectangle and string range. The layouter fills the layout frame with as many lines as fit. You can query [DTCoreTextLayoutFrame visibleStringRange] for the range the fits and create another layout frame that continues the text from there to create multiple pages, for example for an e-book.
 @param frame The rectangle to fill with text
 @param range The string range to fill, pass {0,0} for the entire string (as much as fits)
 */

- (void)loadVoicePromptsFromCoreData:(NSString*)voiceId;

/**
 Creates a layout frame with a given rectangle and string range. The layouter fills the layout frame with as many lines as fit. You can query [DTCoreTextLayoutFrame visibleStringRange] for the range the fits and create another layout frame that continues the text from there to create multiple pages, for example for an e-book.
 @param frame The rectangle to fill with text
 @param range The string range to fill, pass {0,0} for the entire string (as much as fits)
 */

- (ContentWorld*)loadContentWorldFromCoreData;

/**
 Creates a layout frame with a given rectangle and string range. The layouter fills the layout frame with as many lines as fit. You can query [DTCoreTextLayoutFrame visibleStringRange] for the range the fits and create another layout frame that continues the text from there to create multiple pages, for example for an e-book.
 @param frame The rectangle to fill with text
 @param range The string range to fill, pass {0,0} for the entire string (as much as fits)
 */


- (void)saveContentWorldToCoreData:(PFObject*)obj save:(BOOL)willSave;

/**
 Creates a layout frame with a given rectangle and string range. The layouter fills the layout frame with as many lines as fit. You can query [DTCoreTextLayoutFrame visibleStringRange] for the range the fits and create another layout frame that continues the text from there to create multiple pages, for example for an e-book.
 @param frame The rectangle to fill with text
 @param range The string range to fill, pass {0,0} for the entire string (as much as fits)
 */

- (void)saveAppSettingsToCoreData;

/**
 Creates a layout frame with a given rectangle and string range. The layouter fills the layout frame with as many lines as fit. You can query [DTCoreTextLayoutFrame visibleStringRange] for the range the fits and create another layout frame that continues the text from there to create multiple pages, for example for an e-book.
 @param frame The rectangle to fill with text
 @param range The string range to fill, pass {0,0} for the entire string (as much as fits)
 */

- (User*)loadUserFromCoreData;

/**
 Creates a layout frame with a given rectangle and string range. The layouter fills the layout frame with as many lines as fit. You can query [DTCoreTextLayoutFrame visibleStringRange] for the range the fits and create another layout frame that continues the text from there to create multiple pages, for example for an e-book.
 @param frame The rectangle to fill with text
 @param range The string range to fill, pass {0,0} for the entire string (as much as fits)
 */

- (void)saveUserToCoreData;

- (VoicePrompts*)searchVoicePromptInCoreData:(NSString*)identifier;

+ (void)deleteUser;

+ (void)deleteClips;

+ (void)deleteAllUserFiles;

+ (void)deleteContentWorlds;

@end

//
//  LessonAdvanceSettingsViewController.h
//  MyMentorV2
//
//  Created by Walter Yaron on 7/7/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"
#import "Clip.h"

@interface LessonAdvanceSettingsViewController : UIViewController

@property (strong, nonatomic) Clip *clip;

- (void)loadVoicePromptsDataSource;
- (void)loadReplayLessonDataSource;

@end

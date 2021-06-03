//
//  AppSettingsViewController.h
//  MyMentorV2
//
//  Created by Walter Yaron on 4/26/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppSettingsViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *pickerViewDataSource;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)loadReplayLessonDataSource;
- (void)loadContentWorlds;
- (void)loadInterfaceDataSource;
- (void)loadSwitchUserView;
- (void)updateTexts;

@end

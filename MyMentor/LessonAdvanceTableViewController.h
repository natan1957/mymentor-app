//
//  LessonAdvanceTableViewController.h
//  MyMentorV2
//
//  Created by Walter Yaron on 7/7/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Clip.h"
#import "LessonAdvanceSettingsViewController.h"

@interface LessonAdvanceTableViewController : UITableViewController

@property (strong, nonatomic) Clip *clip;
@property (weak, nonatomic) LessonAdvanceSettingsViewController *parent;

- (void)updateView;

@end

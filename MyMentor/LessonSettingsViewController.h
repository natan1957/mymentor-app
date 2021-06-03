//
//  SettingsViewController.h
//  MyMentor
//
//  Created by Walter Yaron on 5/1/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"
#import "Clip.h"

@protocol LesseonSettingsViewDelegate <NSObject>

- (void)lessonSettingsDidUpdate:(NSInteger)index withStatus:(BOOL)status;

@end


@interface LessonSettingsViewController : UIViewController

@property (strong, nonatomic) Clip *clip;
@property (weak, nonatomic) id <LesseonSettingsViewDelegate> delegate;

- (void)updateLessonSettingsToCoreData;

@end

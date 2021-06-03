//
//  LessonInformationViewController.h
//  MyMentorV2
//
//  Created by Walter Yaron on 12/28/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lesson.h"
#import "MainViewController.h"
#import "FavoriteViewController.h"

@interface LessonInformationViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (strong ,nonatomic) NSString *fileName;
@property (strong, nonatomic) NSDictionary *lessonClip;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//@property (weak, nonatomic) MainViewController *mainViewDelegate;
//@property (weak, nonatomic) FavoriteViewController *favoriteViewDelegate;

@end

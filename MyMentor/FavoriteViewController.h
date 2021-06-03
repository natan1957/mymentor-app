//
//  FavoriteViewController.h
//  MyMentorV2
//
//  Created by Walter Yaron on 12/29/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteViewController : UIViewController

@property (strong, nonatomic) NSMutableDictionary *serverLessons;
@property (assign, nonatomic) BOOL lessonUpdate;

@end

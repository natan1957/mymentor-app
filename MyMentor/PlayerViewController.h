//
//  PlayerViewController.h
//  MyMentor
//
//  Created by Walter Yaron on 4/27/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//


#import <DTCoreText/DTCoreText.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
//#import <DTCoreText/DTCoreText.h>
//#import "DTTiledLayerWithoutFade.h"
#import "Lesson.h"
#import "SWRevealViewController.h"

@interface PlayerViewController : UIViewController <DTAttributedTextContentViewDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) Lesson *lesson;
@property (strong ,nonatomic) NSString *fileName;
@property (strong ,nonatomic) NSString *lessonName;
@property (strong ,nonatomic) NSDictionary *lessonDictionary;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)pause;

@end

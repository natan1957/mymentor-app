//
//  UserGroupImageViewController.h
//  MyMentorV2
//
//  Created by Walter Yaron on 5/7/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserGroupImageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *userGroupImageView;
@property (strong, nonatomic) UIImage *image;

- (void)fadein;
- (void)fadeout:(void(^)(void))complitionHandler;
@end

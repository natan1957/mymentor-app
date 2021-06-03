//
//  ChooseWorldViewController.h
//  MyMentorV2
//
//  Created by Walter Yaron on 12/29/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChooseContentWorldDelegate <NSObject>

- (void)serverUpdateWorldSuccessfully;

@end

@interface ChooseContentWorldViewController : UIViewController

@property (weak, nonatomic) id <ChooseContentWorldDelegate> delegate;

@end

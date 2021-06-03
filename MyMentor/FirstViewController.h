//
//  FirstViewController.h
//  MyMentor
//
//  Created by Walter Yaron on 8/30/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FirstViewControllerDelegate <NSObject>

- (void)firstViewControllerDidFinish;

@end

@interface FirstViewController : UIViewController

@property (weak, nonatomic) id <FirstViewControllerDelegate> delegate;

@end

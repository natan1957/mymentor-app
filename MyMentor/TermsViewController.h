//
//  TermsViewController.h
//  MyMentorV2
//
//  Created by Walter Yaron on 12/29/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TermsViewDelegate <NSObject>

- (void)userDidApprove;

@end

@interface TermsViewController : UIViewController

@property (weak, nonatomic) id <TermsViewDelegate> delegate;

@end

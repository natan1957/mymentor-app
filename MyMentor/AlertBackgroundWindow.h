//
//  AlertBackgroundWindow.h
//  ownerlistens DEBUG
//
//  Created by Walter Yaron on 12/5/13.
//  Copyright (c) 2013 OwnerListens. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AlertBackgroundDelegate <NSObject>

- (void)alertBackgroundDidReciveTap;

@end

@interface AlertBackgroundWindow : UIView

@property (assign, nonatomic) NSInteger light;
@property (weak, nonatomic) id <AlertBackgroundDelegate> delegate;

@end

//
//  WorldContentCell.h
//  MyMentorV2
//
//  Created by Walter Yaron on 12/29/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentWorldCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *worldNameLabel;

@property (weak, nonatomic) IBOutlet UITextView *worldDescriptionTextView;
@end

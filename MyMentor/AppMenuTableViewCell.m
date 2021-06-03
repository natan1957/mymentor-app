//
//  AppMenuTableViewCell.m
//  MyMentorV2
//
//  Created by Walter Yaron on 7/7/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import "AppMenuTableViewCell.h"

@implementation AppMenuTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

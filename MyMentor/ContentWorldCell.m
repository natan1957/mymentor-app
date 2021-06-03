//
//  WorldContentCell.m
//  MyMentorV2
//
//  Created by Walter Yaron on 12/29/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import "ContentWorldCell.h"

@implementation ContentWorldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    if (selected)
    {
        self.contentView.backgroundColor = [UIColor lightGrayColor];
        self.worldDescriptionTextView.textColor = [UIColor whiteColor];
    }
    else
    {
        self.worldDescriptionTextView.textColor = [UIColor blackColor];
    }
}

@end

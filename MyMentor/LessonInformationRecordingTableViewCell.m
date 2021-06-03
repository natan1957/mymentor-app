//
//  LessonInformationRecordingTableViewCell.m
//  MyMentorV2
//
//  Created by Walter Yaron on 5/8/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import "LessonInformationRecordingTableViewCell.h"

@interface LessonInformationRecordingTableViewCell ()

- (IBAction)lessonFilePerformActionClicked:(id)sender;

@end


@implementation LessonInformationRecordingTableViewCell

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

- (IBAction)lessonFilePerformActionClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(lessonInformationRecordingButtonDidClicked:)])
    {
        [self.delegate lessonInformationRecordingButtonDidClicked:self.indexPath];
    }
}
@end

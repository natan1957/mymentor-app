//
//  clipCell.m
//  MyMentor
//
//  Created by Walter Yaron on 4/24/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import "LessonCell.h"

@interface LessonCell () <UIGestureRecognizerDelegate>

@end

@implementation LessonCell

- (void)ffCircularProgressViewStopButtonTouchUpInside
{
    if ([self.delegate respondsToSelector:@selector(lessonDownloadCancelClicked:)])
    {
        [self.delegate lessonDownloadCancelClicked:self.indexPath];
    }
}

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
}

-(void) showProgressBar
{
    self.circularProgressView.hidden = NO;
    self.circularProgressView.progress = 0.f;
    self.circularProgressView.delegate = self;
}

-(void) hideProgressBar
{
    self.circularProgressView.hidden = YES;
}

- (IBAction)pressButton:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(lessonCustomButtonClicked:withType:)])
    {
        [self.delegate lessonCustomButtonClicked:self.indexPath withType:sender.tag];
    }
}

@end

//
//  LessonInformationRecordingTableViewCell.h
//  MyMentorV2
//
//  Created by Walter Yaron on 5/8/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LessonInformationRecordingDelegate <NSObject>

- (void)lessonInformationRecordingButtonDidClicked:(NSIndexPath*)indexPath;

@end

@interface LessonInformationRecordingTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lessonFileRecordingNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lessonFileRecordingDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *lessonFileRecordingDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lessonFileRecordingSizeLabel;
@property (weak, nonatomic) IBOutlet UIButton *lessonFileRecordingActionButton;
@property (assign, nonatomic) BOOL lessonFileRecordingPlaying;
@property (copy, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) id <LessonInformationRecordingDelegate> delegate;

@end

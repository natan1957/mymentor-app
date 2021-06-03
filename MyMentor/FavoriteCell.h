//
//  clipCell.h
//  MyMentor
//
//  Created by Walter Yaron on 4/24/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFCircularProgressView.h"

@protocol FavoriteCellDelegate <NSObject>

-(void) lessonCustomButtonClicked:(NSIndexPath*)indexPath withType:(NSInteger)type;
-(void) lessonDownloadCancelClicked:(NSIndexPath*)indexPath;

@end

@interface FavoriteCell : UITableViewCell <FFCircularProgressViewDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *favoriteImageView;
@property (weak, nonatomic) IBOutlet UITextView *lessonNameTextView;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (weak, nonatomic) IBOutlet UIImageView *lessonDemoImageView;
@property (copy, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet FFCircularProgressView *circularProgressView;
@property (unsafe_unretained, nonatomic) id <FavoriteCellDelegate> delegate;

- (void)showProgressBar;
- (void)hideProgressBar;
- (IBAction)pressButton:(id)sender;

@end

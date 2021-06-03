//
//  UserGroupImageViewController.m
//  MyMentorV2
//
//  Created by Walter Yaron on 5/7/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import "UserGroupImageViewController.h"

@interface UserGroupImageViewController ()



@end

@implementation UserGroupImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.userGroupImageView.image = self.image;
    [self fadein];
}

- (void)fadein
{
    [UIView animateWithDuration:1.4f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.view.alpha = 1.f;
                     } completion:^(BOOL finished)
    {
    }];
}

- (void)fadeout:(void(^)(void))complitionHandler
{
    [UIView animateWithDuration:1.4f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.view.alpha = 0.f;
                     } completion:^(BOOL finished)
     {
         complitionHandler();
     }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.userGroupImageView.alpha = 0.f;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  FirstViewController.m
//  MyMentor
//
//  Created by Walter Yaron on 8/30/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import "FirstViewController.h"
#import "MainViewController.h"
#import "Defines.h"
#import "ContentWorld.h"
#import "AppDelegate.h"

@interface FirstViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *splashImageView;

@end

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)showMainView
{
    if ([self.delegate respondsToSelector:@selector(firstViewControllerDidFinish)])
    {
        [self.delegate firstViewControllerDidFinish];
    }
}

- (void)loadImageFromContentWorld
{
    NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ContentWorld"];
    [request setFetchLimit:1];

    NSError *error = nil;

    NSArray *items = [managedObjectContext executeFetchRequest:request error:&error];

    ContentWorld *world;

    if ([items count])
    {
        world = items[0];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *directory = world.worldId;
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:directory];
        NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"splash.jpg"];
        self.splashImageView.image = [UIImage imageWithContentsOfFile:imagePath];
        [self performSelector:@selector(showMainView) withObject:nil afterDelay:1.f];
    }
    else
    {
        self.splashImageView.image = [UIImage imageNamed:@"splash.png"];
        [self performSelector:@selector(showMainView) withObject:nil afterDelay:1.f];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadImageFromContentWorld];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSplashImageView:nil];
    [super viewDidUnload];
}
@end

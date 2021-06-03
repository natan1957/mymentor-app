//
//  ChooseWorldViewController.m
//  MyMentorV2
//
//  Created by Walter Yaron on 12/29/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import <Parse/Parse.h>
#import "ChooseContentWorldViewController.h"
#import "ContentWorldCell.h"
#import "Settings.h"
#import "AppDelegate.h"
#import "ContentWorld.h"
#import "YHRoundBorderedButton.h"
#import "MBProgressHUD.h"

@interface ChooseContentWorldViewController () <UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *infoLabel1;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel2;
@property (weak, nonatomic) IBOutlet UITextView *infoText3;
@property (weak, nonatomic) IBOutlet YHRoundBorderedButton *worldSelectButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *worlds;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSNumber *index;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (assign, nonatomic) NSInteger selectedRow;


- (IBAction)selectButtonDidPressed:(id)sender;

@end

@implementation ChooseContentWorldViewController

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self moveToNextStep];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.worlds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContentWorldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"worldCellIdentifier"];
    PFObject *obj = self.worlds[indexPath.row];
    if ([[Settings sharedInstance].currentLanguage isEqualToString:@"he_il"])
    {
        cell.worldNameLabel.text = obj[@"value_he_il"];
        cell.worldDescriptionTextView.text = obj[@"description_he_il"];
    }
    else
    {
        cell.worldNameLabel.text = obj[@"value_en_us"];
        cell.worldDescriptionTextView.text = obj[@"description_en_us"];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRow = indexPath.row;
    self.worldSelectButton.hidden = NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)moveToNextStep
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.internetActive)
    {
        switch ([self.index integerValue]) {
            case 0:
                [self loadWorldsFromServer];
                break;
            case 1:
                [self updateContentWorld];
            default:
                break;
        }
    }
}

- (void)checkForInternet:(NSNumber*)index
{
    self.index = index;
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.internetActive)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:[[Settings sharedInstance] getStringByName:@"nointernetfound"]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        [self moveToNextStep];
    }
}

- (void)loadWorldsFromServer
{
    [self.hud hide:YES];
    PFQuery *query = [PFQuery queryWithClassName:@"WorldContentType"];
    [query whereKey:@"status" equalTo:@"Active"];
    __weak ChooseContentWorldViewController *weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             [objects enumerateObjectsUsingBlock:^(PFObject *obj, NSUInteger idx, BOOL *stop)
              {
                  [weakSelf.worlds addObject:obj];
              }];
             [weakSelf.tableView reloadData];
         }
     }];
}

- (void)loadStrings
{
    self.infoLabel1.text = [[Settings sharedInstance] getStringByName:@"choosecontent_title"];
    self.infoLabel2.text = [[Settings sharedInstance] getStringByName:@"choosecontent_info"];
    self.infoText3.editable = YES;
    self.infoText3.contentInset = UIEdgeInsetsMake(-8.f, 0.f, -8.f, 0.f);
    self.infoText3.textColor = [UIColor whiteColor];
    self.infoText3.font = [UIFont systemFontOfSize:17.f];
    self.infoText3.text = [[Settings sharedInstance] getStringByName:@"choosecontent_description"];
    self.infoText3.editable = NO;
    [self.worldSelectButton setTitle:[[Settings sharedInstance] getStringByName:@"choosecontent_choose"] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadStrings];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    self.worlds = [[NSMutableArray alloc] initWithCapacity:1];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self checkForInternet:@(0)];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateContentWorld
{
    [self.hud hide:YES];
    PFObject *obj = self.worlds[self.selectedRow];

    __weak ChooseContentWorldViewController *weakSelf = self;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud showAnimated:YES
  whileExecutingBlock:^
     {
         BOOL saveToUser = NO;
         if ([[PFUser currentUser] isAuthenticated])
             saveToUser = YES;
         [[Settings sharedInstance] saveContentWorldToCoreData:obj save:saveToUser];
     }
      completionBlock:^{
          // need to save to the database user x and world y
          if ([weakSelf.delegate respondsToSelector:@selector(serverUpdateWorldSuccessfully)])
          {
              [weakSelf.delegate serverUpdateWorldSuccessfully];
          }
      }];
}

- (IBAction)selectButtonDidPressed:(id)sender
{
    [self checkForInternet:@(1)];
    // save in core data
}


@end

//
//  AppMenuViewController.m
//  MyMentorV2
//
//  Created by Walter Yaron on 7/3/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import <Parse/Parse.h>
#import "AppMenuViewController.h"
#import "MMNavigationController.h"
#import "AppMenuTableViewCell.h"

@interface AppMenuViewController () <   UITableViewDataSource,
                                        UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation AppMenuViewController

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[PFUser currentUser] isAuthenticated])
        return 4;

    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppMenuCellIdentifier"];
    if (!cell)
    {
        cell = [[AppMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AppMenuCellIdentifier"];
    }

    switch (indexPath.row)
    {
        case 0:
            cell.appMenuImageView.image = [UIImage imageNamed:@"btn_list_normal.png"];
            break;
        case 1:
            cell.appMenuImageView.image = [UIImage imageNamed:@"btn_fav_normal.png"];
            break;
        case 2:
            cell.appMenuImageView.image = [UIImage imageNamed:@"btn_settings_normal.png"];
            break;
        case 3:
        {
            if ([[PFUser currentUser] isAuthenticated])
                cell.appMenuImageView.image = [UIImage imageNamed:@"btn_about_normal.png"];
            else
                cell.appMenuImageView.image = [UIImage imageNamed:@"btn_login_normal.png"];
            break;
        }
        case 4:
            cell.appMenuImageView.image = [UIImage imageNamed:@"btn_about_normal.png"];
            break;

        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    SWRevealViewController *revealController = [self revealViewController];
    MMNavigationController *navController = (MMNavigationController*)revealController.frontViewController;

    switch (indexPath.row)
    {
        case 0:
            [navController exchangeRootViewController:0];
            [revealController revealToggle:nil];
            break;
        case 1:
            [navController exchangeRootViewController:1];
            [revealController revealToggle:nil];
            break;
        case 2:
            [revealController setFrontViewPosition:FrontViewPositionRightMost animated:YES];
            [self.navigationController pushViewController:[navController getAppSettingsViewController] animated:YES];
            break;
        case 3:
        {
            if ([[PFUser currentUser] isAuthenticated])
            {
                [revealController setFrontViewPosition:FrontViewPositionRightMost animated:YES];
                [self.navigationController pushViewController:[navController getAboutViewController] animated:YES];
            }
            else
            {
                [revealController setFrontViewPosition:FrontViewPositionRightMost animated:YES];
                [self.navigationController pushViewController:[navController getLoginViewController] animated:YES];
            }
                break;
        }
        case 4:
            [revealController setFrontViewPosition:FrontViewPositionRightMost animated:YES];
            [self.navigationController pushViewController:[navController getAboutViewController] animated:YES];

            break;

        default:
            break;
    }
}

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
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    if ([[PFUser currentUser] isAuthenticated])
//        self.viewControllers = @[self.aboutController];
//    else
//        self.viewControllers = @[self.loginController];


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

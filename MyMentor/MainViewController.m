//
//  ViewController.m
//  MyMentor
//
//  Created by Walter Yaron on 4/24/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import <Parse/Parse.h>
#import "MainViewController.h"
#import "LessonCell.h"
#import "AFClient.h"
#import "MBProgressHUD.h"
#import "ZipArchive.h"
#import "Clip.h"
#import "DownloadMMN.h"
#import "Defines.h"
#import "PlayerViewController.h"
#import "MBProgressHUD.h"
#import "SVPullToRefresh.h"
#import "SIAlertView.h"
#import "LessonInformationViewController.h"
#import "FavoriteViewController.h"
#import "AboutViewController.h"
#import "AppDelegate.h"
#import "Settings.h"
#import "SLTDoubleTapSegmentedControl.h"
#import "ContentWorld.h"
#import "DownloadVoicePrompts.h"
#import "User.h"
#import "RNFrostedSidebar.h"

@interface MainViewController () <  LessonCellDelegate,
                                    UITextFieldDelegate,
                                    RNFrostedSidebarDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchTextView;
@property (strong, nonatomic) IBOutlet UIView *searchBarView;
@property (weak, nonatomic) IBOutlet SLTDoubleTapSegmentedControl *filterSegmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *searchCancelButton;
@property (strong, nonatomic) NSMutableArray *lessons;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) NSMutableArray *remoteLessons;
@property (strong, nonatomic) NSMutableArray *localLessons;
@property (strong, nonatomic) NSMutableArray *localClips;
@property (strong, nonatomic) NSMutableDictionary *downloadClips;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) NSDate *lastSwipeDate;
@property (strong, nonatomic) RNFrostedSidebar *sideBar;
@property (assign, nonatomic) BOOL searchActive;

- (IBAction)searchButtonTouchUpInside:(id)sender;
- (IBAction)menuButtonDidPressed:(id)sender;
- (IBAction)filterButtonValueChanged:(SLTDoubleTapSegmentedControl*)sender;
- (IBAction)searchLessonCancelButtonClicked:(id)sender;
- (IBAction)textFieldValueChanged:(UITextField*)sender;

@end

@implementation MainViewController

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 5000)
    {
        MMNavigationController *navController = (MMNavigationController*)self.navigationController;
        [navController exchangeRootViewController:0];
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        AppSetupViewController *appSetup = [self.storyboard instantiateInitialViewController];
        appDelegate.window.rootViewController = appSetup;
        [appDelegate.window makeKeyAndVisible];
        [appDelegate setupMainViewController];
    }
    else
    {
        switch (buttonIndex) {
            case 0:

                break;
            case 1:
            {
                MMNavigationController *navController = (MMNavigationController*)self.revealViewController.frontViewController;
                [navController exchangeRootViewController:3];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - RNfrostedSideBar Delegate

- (void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index
{
    SWRevealViewController *revealController = [self revealViewController];
    MMNavigationController *navController = (MMNavigationController*)revealController.frontViewController;
    [sidebar dismissAnimated:YES
                  completion:^(BOOL finished)
    {
        [navController exchangeRootViewController:index];
    }];
}

#pragma mark - UISearchBarController

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text length] > 0 || [textField.text length] > 0)
    {
//        [self searchPlaces];
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self searchLessonByText:@""];
    return YES;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchActive)
    {
        return [self.searchResults count];
    }
    return [self.lessons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LessonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LessonCell"];
    if (!cell)
    {
        cell = [[LessonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LessonCell"];
    }

    NSDictionary *lesson;
    if (self.searchActive)
        lesson = self.searchResults[indexPath.row];
    else
        lesson = self.lessons[indexPath.row];
    
    NSDictionary *data = lesson[@"data"];

    if ([[Settings sharedInstance].currentLanguage isEqualToString:@"he_il"])
    {
        if (![Settings sharedInstance].appSettingsNaturalLanguage)
        {
            cell.lessonNameTextView.text = data[@"name_he_il"];
        }
        else
        {
            cell.lessonNameTextView.text = data[@"name_en_us"];
        }
    }
    else if ([[Settings sharedInstance].currentLanguage isEqualToString:@"en_us"])
    {
        if (![Settings sharedInstance].appSettingsNaturalLanguage)
        {
            cell.lessonNameTextView.text = data[@"name_en_us"];
        }
        else
        {
            cell.lessonNameTextView.text = data[@"name_he_il"];
        }
    }

    if ([data[@"lessonDemo"] boolValue])
        cell.lessonDemoImageView.hidden = NO;

    else
        cell.lessonDemoImageView.hidden = YES;


    if (self.downloadClips[data[@"identifier"]])
    {
        NSDictionary *clip = self.downloadClips[data[@"identifier"]];
        NSDictionary *data = clip[@"data"];
        if ([data[@"favorite"] boolValue])
        {
            cell.favoriteImageView.image = [UIImage imageNamed:@"btn_CellFavorite_selected.png"];
        }
        else
        {
            cell.favoriteImageView.image = [UIImage imageNamed:@"btn_CellFavorite_normal.png"];
        }
    }
    else
        cell.favoriteImageView.image = [UIImage imageNamed:@"btn_CellFavorite_normal.png"];


    cell.delegate = self;
    cell.indexPath = indexPath;

    if (self.downloadClips[data[@"identifier"]])
    {
        NSDate *serverDate = data[@"updatedByMyMentor"];
        NSDictionary *clip = self.downloadClips[data[@"identifier"]];
        NSDictionary *data1 = clip[@"data"];
        NSDate *currentDate = data1[@"updatedByMyMentor"];

        NSComparisonResult result = [currentDate compare:serverDate];
        if (result == NSOrderedSame)
        {
            [self updatePlayButton:cell.statusButton withClip:data1[@"identifier"]];
            cell.statusButton.tag = PLAYBUTTON;
        }
        else
        {
            [cell.statusButton setImage:[UIImage imageNamed:@"btn_CellReload_normal.png"] forState:UIControlStateNormal];
            cell.statusButton.tag = UPDATEBUTTON;

        }
    }
    else
    {
        [cell.statusButton setImage:[UIImage imageNamed:@"btn_CellDownload_normal.png"] forState:UIControlStateNormal];
        cell.statusButton.tag = DOWNLOADBUTTON;
    }

    switch ([lesson[@"status"] integerValue])
    {
        case ClipRegular:
//            [cell hideProgressBar];
            break;
        case ClipDownload:
//            [cell showProgressBar];
            break;
        case ClipDelete:
            [cell.statusButton setImage:[UIImage imageNamed:@"btn_CellDelete_normal.png"] forState:UIControlStateNormal];
            cell.statusButton.tag = DELETEBUTTON;
            break;
        default:
            break;
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[NSDate date] timeIntervalSinceDate:self.lastSwipeDate] < 0.5f)
    {
        return nil;
    }
    return indexPath;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *lesson = self.lessons[indexPath.row];
    LessonCell *cell = (LessonCell*)[tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *data = lesson[@"data"];
    if (data[@"locked"])
    {
        if ([data[@"locked"] boolValue])
        {
            return UITableViewCellEditingStyleNone;
        }
    }
    if ([lesson[@"status"] integerValue] == ClipRegular)
    {
        [lesson setObject:@(ClipDelete) forKey:@"status"];
        [cell.statusButton setImage:[UIImage imageNamed:@"btn_CellDelete_normal.png"] forState:UIControlStateNormal];
        cell.statusButton.tag = DELETEBUTTON;
    }
    else if ([lesson[@"status"] integerValue] == ClipDelete)
    {
        [lesson setObject:@(ClipRegular) forKey:@"status"];
        NSDictionary *data = lesson[@"data"];
        LessonCell *cell = (LessonCell*)[tableView cellForRowAtIndexPath:indexPath];
        if (self.downloadClips[data[@"identifier"]])
        {
            NSDate *serverDate = data[@"updatedByMyMentor"];
            NSDictionary *clip = self.downloadClips[data[@"identifier"]];
            NSDictionary *data1 = clip[@"data"];
            NSDate *currentDate = data1[@"updatedByMyMentor"];

            NSComparisonResult result = [currentDate compare:serverDate];
            if (result == NSOrderedSame)
            {
                [self updatePlayButton:cell.statusButton withClip:data1[@"identifier"]];
                cell.statusButton.tag = PLAYBUTTON;
            }
            else
            {
                [cell.statusButton setImage:[UIImage imageNamed:@"btn_CellReload_normal.png"] forState:UIControlStateNormal];
                cell.statusButton.tag = UPDATEBUTTON;
            }
        }
        else
        {
            [cell.statusButton setImage:[UIImage imageNamed:@"btn_CellDownload_normal.png"] forState:UIControlStateNormal];
            cell.statusButton.tag = DOWNLOADBUTTON;
        }
    }

    self.lastSwipeDate = [NSDate date];
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchActive)
    {
        [self.searchResults enumerateObjectsUsingBlock:^(NSMutableDictionary *obj, NSUInteger idx, BOOL *stop)
         {
             [obj setObject:@(ClipRegular) forKey:@"status"];
         }];
    }
    else
    {
        [self.lessons enumerateObjectsUsingBlock:^(NSMutableDictionary *obj, NSUInteger idx, BOOL *stop)
         {
             [obj setObject:@(ClipRegular) forKey:@"status"];
         }];
    }
}

- (void)updatePlayButton:(UIButton*)button withClip:(NSString*)identifier
{
    NSDictionary *clip = self.downloadClips[identifier];
    NSDictionary *data = clip[@"data"];
    if (data)
    {
        if ([data[@"arrowDirectionType"] integerValue] == ArrowDirectionTypeLeft)
            [button setImage:[UIImage imageNamed:@"btn_CellPlay_Fliped.png"] forState:UIControlStateNormal];

        else
            [button setImage:[UIImage imageNamed:@"btn_CellPlay_normal.png"] forState:UIControlStateNormal];
    }
}

-(void) updateClipToCoreData:(NSIndexPath*)indexPath
{
    NSDictionary *lesson;

    if (self.searchActive)
    {
        lesson = self.searchResults[indexPath.row];
    }
    else
    {
        lesson = self.lessons[indexPath.row];
    }

    NSDictionary *data = lesson[@"data"];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Clip" inManagedObjectContext:[self managedObjectContext]];
    [request setEntity:entity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", data[@"identifier"]];
    [request setPredicate:predicate];

    NSError *error;
    NSArray *array = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (array != nil)
    {
        NSUInteger count = [array count]; // May be 0 if the object has been deleted.
        if (count)
        {
            [array enumerateObjectsUsingBlock:^(Clip *obj, NSUInteger idx, BOOL *stop)
            {
                [obj updateClipToCoreData:data];
                NSError *error = nil;
                [[self managedObjectContext] save:&error];
                if (error)
                {
                    NSLog(@"%@",error.description);
                }
            }];
        }
    }
    else
    {
        // Deal with error.
    }

    [self.downloadClips removeObjectForKey:data[@"identifier"]];
    [self.downloadClips setObject:lesson forKey:data[@"identifier"]];
    [self.localLessons addObject:lesson];
}

-(void) saveNewClipToCoreData:(NSIndexPath*)indexPath
{
    NSDictionary *lesson;

    if (self.searchActive)
        lesson = self.searchResults[indexPath.row];
    else
        lesson = self.lessons[indexPath.row];

    NSMutableDictionary *data = lesson[@"data"];
    data[@"arrowDirectionType"] = @([Settings sharedInstance].appSettingsArrowDirectionType);
    NSManagedObjectContext *context = [self managedObjectContext];
    Clip *clipDB = [NSEntityDescription insertNewObjectForEntityForName:@"Clip" inManagedObjectContext:context];
    [clipDB saveNewClipToCoreData:data];
    NSError *error = nil;
    [context save:&error];
    if (error)
    {
        NSLog(@"%@",error.description);
    }

    [self.downloadClips setObject:lesson forKey:data[@"identifier"]];
    [self.localLessons addObject:lesson];
}

- (void) performAction:(NSUInteger)action onClip:(NSIndexPath*)indexPath
{
    // need to check which file to download base on demoStatus and LessonStatus
    NSMutableDictionary *tmp;
    if (self.searchActive)
        tmp = self.searchResults[indexPath.row];
    else
        tmp = self.lessons[indexPath.row];

    NSMutableDictionary *data = tmp[@"data"];

    BOOL downloadVoicePrompts = YES;

    PFObject *voicePrompts = data[@"voicePrompts"];
    if ([[Settings sharedInstance] checkIfVoicePromptsExist:voicePrompts.objectId])
    {
        downloadVoicePrompts = NO;
    }

    DownloadMMN *download = [[DownloadMMN alloc] init];
    [tmp setObject:download forKey:@"download"];
    [tmp setObject:@(ClipDownload) forKey:@"status"];
    //[self.downloadArray addObject:download];
    __weak MainViewController *weakSelf = self;
    LessonCell *cell = (LessonCell*)[weakSelf.tableView cellForRowAtIndexPath:indexPath];
    [cell showProgressBar];
    [download setDownloadProgressBlock:^(long long totalBytesRead, long long totalBytesExpectedToRead)
    {
        LessonCell *cell = (LessonCell*)[weakSelf.tableView cellForRowAtIndexPath:indexPath];
        float currentProgress = ((float)totalBytesRead) / totalBytesExpectedToRead;
        if (downloadVoicePrompts)
            currentProgress /= 2;

        cell.circularProgressView.progress = currentProgress;
    }];

    [download downloadWithFilename:data[@"fileName"]
                            andURL:data[@"fileURL"]
                       withSuccess:^(BOOL done)
    {
        [tmp removeObjectForKey:@"download"];

        if (downloadVoicePrompts)
        {
            [weakSelf downloadVoicePrompts:action onClip:indexPath];
        }
        else
        {
            [tmp setObject:@(ClipRegular) forKey:@"status"];
            //[self.downloadArray removeObject:download];
            LessonCell *cell = (LessonCell*)[weakSelf.tableView cellForRowAtIndexPath:indexPath];

            cell.statusButton.tag = PLAYBUTTON;
            if (action == DOWNLOADBUTTON)
            {
                [weakSelf saveNewClipToCoreData:indexPath];
            }
            if (action == UPDATEBUTTON)
            {
                [weakSelf updateClipToCoreData:indexPath];
            }
            [weakSelf updatePlayButton:cell.statusButton withClip:data[@"identifier"]];
            [weakSelf updateLessonStatus:data afterDownload:YES];
            [cell hideProgressBar];
        }
    }
                       withFailure:^(NSError *error)
    {

    }];
}

- (void)downloadVoicePrompts:(NSUInteger)action onClip:(NSIndexPath*)indexPath
{
    // need to check if voice prompts exist
    NSMutableDictionary *tmp;

    if (self.searchActive)
        tmp = self.searchResults[indexPath.row];
    else
        tmp = self.lessons[indexPath.row];
    NSMutableDictionary *data = tmp[@"data"];

    [tmp setObject:@(ClipDownload) forKey:@"status"];

    LessonCell *cell = (LessonCell*)[self.tableView cellForRowAtIndexPath:indexPath];

    PFObject *voicePrompts = data[@"voicePrompts"];

    DownloadVoicePrompts *downloadPrompts = [[DownloadVoicePrompts alloc] init];
    [tmp setObject:downloadPrompts forKey:@"downloadPrompts"];

    __weak MainViewController *weakSelf = self;

    [downloadPrompts downloadVoicePrompts:voicePrompts
                        progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations)
    {
        float currentProgress = ((float)numberOfFinishedOperations) / totalNumberOfOperations;
        currentProgress /= 2;
        cell.circularProgressView.progress = currentProgress + 0.5f;
    }
                          completionBlock:^(BOOL done)
    {
        if (done)
        {
            [tmp setObject:@(ClipRegular) forKey:@"status"];
            LessonCell *cell = (LessonCell*)[weakSelf.tableView cellForRowAtIndexPath:indexPath];
            cell.circularProgressView.progress = 1.f;
            cell.statusButton.tag = PLAYBUTTON;
            [[Settings sharedInstance] saveVoicePromptsToCoreData:voicePrompts];
            if (action == DOWNLOADBUTTON)
            {
                [weakSelf saveNewClipToCoreData:indexPath];
            }
            if (action == UPDATEBUTTON)
            {
                [weakSelf updateClipToCoreData:indexPath];

            }
            [weakSelf updatePlayButton:cell.statusButton withClip:data[@"identifier"]];
            [weakSelf updateLessonStatus:data afterDownload:YES];
            [cell hideProgressBar];
        }
    }];
}

-(void) updateClip:(NSIndexPath*)indexPath
{
    [self performAction:UPDATEBUTTON onClip:indexPath];
}

-(void) downloadClip:(NSIndexPath*)indexPath
{
    [self performAction:DOWNLOADBUTTON onClip:indexPath];
}

- (void)deleteUserFiles:(NSString*)identifier
{
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSFileManager *manager = [[NSFileManager alloc] init];
    NSArray *contents = [manager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    for (NSString* item in contents)
    {
        if ([item rangeOfString:identifier].location == 0)
        {
            error = nil;
            [manager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:item] error:&error];
            if (error)
            {
                NSLog(@"%@",[error localizedDescription]);
            }
        }
    }
}

- (void)deleteClip:(NSIndexPath*)indexPath
{
    NSUInteger lessonsCount;
    NSDictionary *tmp;
    if (self.searchActive)
    {
        lessonsCount = [self.searchResults count];
        tmp = self.searchResults[indexPath.row];
    }
    else
    {
        lessonsCount = [self.lessons count];
        tmp = self.lessons[indexPath.row];
    }
    NSDictionary *data = tmp[@"data"];
    NSString *filename = data[@"fileName"];
    NSString *identifier = data[@"identifier"];

    [self.downloadClips removeObjectForKey:identifier];
    [self.localLessons removeObject:tmp];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Clip" inManagedObjectContext:[self managedObjectContext]];
    [request setEntity:entity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
    [request setPredicate:predicate];

    NSError *error = nil;
    NSArray *array = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (array != nil)
    {
        NSUInteger count = [array count]; // May be 0 if the object has been deleted.
        if (count)
        {
            [array enumerateObjectsUsingBlock:^(Clip *obj, NSUInteger idx, BOOL *stop)
             {
                 [self.managedObjectContext deleteObject:obj];
             }];

            NSError *error = nil;
            [self.managedObjectContext save:&error];
            if (error)
            {
                NSLog(@"%@",error.description);
            }
        }
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSFileManager *manager = [[NSFileManager alloc] init];
    [manager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:&error];

    if (error)
    {
        NSLog(@"%@",[error localizedDescription]);
    }

    NSArray *contents = [manager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    for (NSString* item in contents)
    {
        if ([item rangeOfString:identifier].location == 0)
        {
            if ([[item pathExtension] isEqualToString:@"html"] ||
                 [[item pathExtension] isEqualToString:@"json"] ||
                 [[item pathExtension] isEqualToString:@"mp3"])
            {
                error = nil;
                [manager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:item] error:&error];
                if (error)
                {
                    NSLog(@"%@",[error localizedDescription]);
                }
            }
        }
    }

    if (self.searchActive)
        [self.searchResults removeObjectAtIndex:indexPath.row];
    else
        [self.lessons removeObjectAtIndex:indexPath.row];

    if (self.searchActive)
    {
        if ([self.searchResults count] != lessonsCount)
        {
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.4f];
        }
    }
    else
    {
        if ([self.lessons count] != lessonsCount)
        {
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.4f];
        }
    }
}

#pragma mark - cell Delegate

- (void)lessonDownloadCancelClicked:(NSIndexPath*)indexPath
{
    NSMutableDictionary *tmp;
    if (self.searchActive)
        tmp  = self.searchResults[indexPath.row];
    else
        tmp  = self.lessons[indexPath.row];
    DownloadMMN *download = tmp[@"download"];
    [download cancelDownload];
    DownloadVoicePrompts *downloadPrompts = tmp[@"downloadPrompts"];
    if (downloadPrompts)
    {
        [downloadPrompts cancelDownload];
    }

    [tmp removeObjectForKey:@"download"];
    [tmp setObject:@(ClipRegular) forKey:@"status"];
    LessonCell *cell = (LessonCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell hideProgressBar];
}

- (void)showPlayerView:(NSIndexPath*)indexPath
{
    PlayerViewController *playerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayerViewController"];
    NSDictionary *tmp;
    if (self.searchActive)
    {
        [self.searchTextView resignFirstResponder];
        [self hideSearchBar:NO];
        tmp = self.searchResults[indexPath.row];
    }
    else
    {
        tmp = self.lessons[indexPath.row];
    }

    NSDictionary *data = tmp[@"data"];
    playerViewController.fileName = data[@"identifier"];

    NSString *name;

    if ([[Settings sharedInstance].currentLanguage isEqualToString:@"he_il"])
    {
        if (![Settings sharedInstance].appSettingsNaturalLanguage)
        {
            name = data[@"name_he_il"];
        }
        else
        {
            name = data[@"name_en_us"];
        }
    }
    else if ([[Settings sharedInstance].currentLanguage isEqualToString:@"en_us"])
    {
        if (![Settings sharedInstance].appSettingsNaturalLanguage)
        {
            name = data[@"name_en_us"];
        }
        else
        {
            name = data[@"name_he_il"];
        }
    }

    playerViewController.lessonName = name;
    playerViewController.lessonDictionary = data;
    playerViewController.managedObjectContext = self.managedObjectContext;
    if (self.HUD)
    {
        [self.HUD hide:YES];
    }

    [self.navigationController pushViewController:playerViewController animated:YES];
}

-(void)deleteDataAndShowMessage:(NSString*)message
{
    [Settings deleteAllUserFiles];
    [Settings deleteClips];
    [Settings deleteUser];
    [Settings deleteContentWorlds];
    [PFUser logOut];
    [self setupMenu];
    [self.remoteLessons removeAllObjects];
    [self.downloadClips removeAllObjects];
    [self.localLessons removeAllObjects];
    [self.lessons removeAllObjects];
    [self.tableView reloadData];
    [self.HUD hide:YES];

    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil
                                                         message:message
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    alertView.tag = 5000;
    [alertView show];
}

- (void)lessonCustomButtonClicked:(NSIndexPath*)indexPath withType:(NSInteger)type
{
    switch (type)
    {
        case PLAYBUTTON:
        {
            self.HUD = nil;
            if ([[PFUser currentUser] isAuthenticated])
            {
                AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                if (appDelegate.internetActive)
                {
                    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    [self.HUD show:YES];

                    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error)
                    {
                        PFUser *currentUser =  [PFUser currentUser];
                        PFObject *adminData = currentUser[@"adminData"];
                        [adminData fetch];
                        PFObject *userStatus = adminData[@"userStatus"];
                        [userStatus fetch];

                        if (!([userStatus[@"status"] isEqualToString:@"active"]) && !([userStatus[@"status"] isEqualToString:@"checking"]) && !([userStatus[@"status"] isEqualToString:@"app"]))
                        {
                            NSString *message;

                            if ([userStatus[@"status"] isEqualToString:@"blocked"])
                            {
                                message = [[Settings sharedInstance] getStringByName:@"login_userstatusblocked"];
                            }
                            else if ([userStatus[@"status"] isEqualToString:@"hold"])
                            {
                                message = [[Settings sharedInstance] getStringByName:@"login_userstatushold"];
                            }
                            else if ([userStatus[@"status"] isEqualToString:@"new"])
                            {
                                message = [[Settings sharedInstance] getStringByName:@"login_userstatusnew"];
                            }

                            [self deleteDataAndShowMessage:message];
                            return;
                        }

                       NSString *deviceIdentifier = currentUser[@"deviceIdentifier"];
                       if (![[Settings sharedInstance].deviceIdentifier isEqualToString:deviceIdentifier])
                       {
                           [self deleteDataAndShowMessage:[[Settings sharedInstance] getStringByName:@"otherusermakelogin"]];
                           return;
                       }
                       else
                       {
                           [self showPlayerView:indexPath];
                       }
                    }];
                }
                else
                {
                    [self showPlayerView:indexPath];
                }
            }
            else
            {
                [self showPlayerView:indexPath];
            }
            break;
        }
        case UPDATEBUTTON:
        {
            if ([(AppDelegate*)[[UIApplication sharedApplication] delegate] internetActive])
            {
                [self updateClip:indexPath];
            }
            else
            {
                [self showAlert];
            }
            
            break;
        }
        case DOWNLOADBUTTON:
        {
            if ([(AppDelegate*)[[UIApplication sharedApplication] delegate] internetActive])
            {
                [self downloadClip:indexPath];
            }
            else
            {
                [self showAlert];
            }
            
            break;
        }
        case DELETEBUTTON:
        {
            if ([(AppDelegate*)[[UIApplication sharedApplication] delegate] internetActive])
            {
                [self deleteClip:indexPath];
            }
            else
            {
                [self showAlert];
            }
            break;
        }

        default:
            break;
    }
}

- (void)showAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[[Settings sharedInstance] getStringByName:@"nointernetfound"]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)updateFilters
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ContentWorld"];
    [request setFetchLimit:1];

    NSError *error = nil;

    NSArray *items = [self.managedObjectContext executeFetchRequest:request error:&error];

    ContentWorld *world;

    if ([items count])
    {
        world = items[0];

        while(self.filterSegmentedControl.numberOfSegments > 0) {
            [self.filterSegmentedControl removeSegmentAtIndex:0 animated:NO];
        }

        if ([[Settings sharedInstance].currentLanguage isEqualToString:@"he_il"])
        {

            [self.filterSegmentedControl insertSegmentWithTitle:@"מורה" atIndex:0 animated:NO];

            if ([world.category2_he_il length])
            {
                [self.filterSegmentedControl insertSegmentWithTitle:world.category2_he_il atIndex:0 animated:NO];
            }

            if ([world.category3_he_il length])
            {
                [self.filterSegmentedControl insertSegmentWithTitle:world.category3_he_il atIndex:0 animated:NO];
            }

            if ([world.category4_he_il length])
            {
                [self.filterSegmentedControl insertSegmentWithTitle:world.category4_he_il atIndex:0 animated:NO];
            }
        }
        else
        {
            if ([world.category4_en_us length])
            {
                [self.filterSegmentedControl insertSegmentWithTitle:world.category4_en_us atIndex:0 animated:NO];
            }

            if ([world.category3_en_us length])
            {
                [self.filterSegmentedControl insertSegmentWithTitle:world.category3_en_us atIndex:0 animated:NO];
            }

            if ([world.category2_en_us length])
            {
                [self.filterSegmentedControl insertSegmentWithTitle:world.category2_en_us atIndex:0 animated:NO];
            }

            [self.filterSegmentedControl insertSegmentWithTitle:@"teacher" atIndex:0 animated:NO];
        }
    }
}

- (void)updateNaturalLanguageUI:(NSNotification*)note
{
    [self updateFilters];
    [self loadLocalLessons];
//    [self.tableView reloadData];
}

- (void)updateLessonsAfterContentWorldChange:(NSNotification*)note
{
    [self updateFilters];
    [self loadLocalLessons];
    [self checkifUserLogin];
}

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNaturalLanguageUI:)
                                                 name:kUpdateNaturalLanguageUI
                                               object:nil];


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateLessonsAfterContentWorldChange:)
                                                 name:kUpdateLessonsListAfterAction
                                               object:nil];
}

- (void)setupMenu
{
    NSMutableArray *images = [@[ [UIImage imageNamed:@"btn_list_normal.png"],
                                 [UIImage imageNamed:@"btn_fav_normal.png"],
                                 [UIImage imageNamed:@"btn_settings_normal.png"],
                                 [UIImage imageNamed:@"btn_login_normal.png"],
                                 [UIImage imageNamed:@"btn_about_normal.png"]] mutableCopy];

    NSMutableArray *selectedImages = [@[ [UIImage imageNamed:@"btn_list_selected.png"],
                                         [UIImage imageNamed:@"btn_fav_selected.png"],
                                         [UIImage imageNamed:@"btn_settings_selected.png"],
                                         [UIImage imageNamed:@"btn_login_selected.png"],
                                         [UIImage imageNamed:@"btn_about_selected.png"]] mutableCopy];

    if ([[PFUser currentUser] isAuthenticated])
    {
        [images removeObjectAtIndex:3];
        [selectedImages removeObjectAtIndex:3];
    }

    self.sideBar = [[RNFrostedSidebar alloc] initWithImages:images selectedImages:selectedImages];
    self.sideBar.delegate = self;
}

- (void)updateTexts
{
    self.searchTextView.placeholder = [[Settings sharedInstance] getStringByName:@"lessonslist_searchplaceholder"];
    [self.searchCancelButton setTitle:[[Settings sharedInstance] getStringByName:@"lessonslist_cancelsearch"] forState:UIControlStateNormal];
    [self updateFilters];
    if (self.lessons || self.searchResults)
        [self.tableView reloadData];
}

-(void) setupView
{
    [self.navigationController.view addSubview:self.searchBarView];
    [self hideSearchBar:NO];
    self.tableView.contentInset = UIEdgeInsetsMake(0.f, 0.f, 40.f, 0.f);
    self.filterSegmentedControl.selectedSegmentIndex = -1;
    self.managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;

    self.tableView.allowsMultipleSelection = NO;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.allowsSelectionDuringEditing = NO;
    self.localLessons   = [[NSMutableArray alloc] init];
    self.remoteLessons  = [[NSMutableArray alloc] init];
    self.lessons        = [[NSMutableArray alloc] init];
    self.searchResults  = [[NSMutableArray alloc] init];
    self.downloadClips  = [[NSMutableDictionary alloc] init];
    self.localClips     = [[NSMutableArray alloc] init];
    self.searchActive   = NO;

    [self.tableView addPullToRefreshWithActionHandler:^
    {
        if (self.searchActive)
        {
            [self.searchResults enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop)
             {
                 NSUInteger downloading = [obj[@"status"] integerValue];
                 if (downloading == ClipDownload)
                 {
                     DownloadMMN *download = obj[@"download"];
                     [download cancelDownload];
                 }
             }];
        }
        else
        {
            [self.lessons enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop)
             {
                 NSUInteger downloading = [obj[@"status"] integerValue];
                 if (downloading == ClipDownload)
                 {
                     DownloadMMN *download = obj[@"download"];
                     [download cancelDownload];
                 }
             }];
        }
        if ([(AppDelegate*)[[UIApplication sharedApplication] delegate] internetActive])
        {
            [self loadLocalLessons];
            [self checkifUserLogin];
        }
        else
        {
            [self showAlert];
        }

        [self.tableView.pullToRefreshView stopAnimating];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerObservers];
    [self setupView];
    [self loadLocalLessons];
    if (![self.localLessons count])
    {
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        if (appDelegate.internetActive)
            [self checkifUserLogin];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"apptitle"]]];
    [self setupMenu];
    [self updateTexts];
    if ([Settings sharedInstance].lessonUpdate)
    {
        [self loadLocalLessons];
    }
    if (self.searchActive)
    {
        [self showSearchBar:YES];
    }
    else
    {
        if (![[PFUser currentUser] isAuthenticated])
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showLoginMessage];
            });

        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title = @"";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.searchActive) {
        [self hideSearchBar:YES];
    }

}

+ (instancetype)sharedInstance
{
    static MainViewController *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MainViewController alloc] init];
    });
    return instance;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSearchBar:(BOOL)animated
{
    CGFloat searchViewHeight = 64.f;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        searchViewHeight -= 20.f;
    }
    [UIView animateWithDuration:animated?0.4f:0.f
                     animations:^{
                         self.searchBarView.frame = CGRectMake(60.f, 00.f, 260.f, searchViewHeight);
                     }
                     completion:^(BOOL finished)
     {
         [self.searchTextView becomeFirstResponder];
         self.tableView.showsPullToRefresh = NO;
     }];
}

- (void)hideSearchBar:(BOOL)animated
{
    CGFloat searchViewHeight = 64.f;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        searchViewHeight -= 20.f;
    }

    [UIView animateWithDuration:animated?0.4f:0.f
                     animations:^{
                         self.searchBarView.frame = CGRectMake(60.f, -searchViewHeight, 260.f, searchViewHeight);
                     }
                     completion:^(BOOL finished)
     {
         [self.tableView reloadData];
         self.tableView.showsPullToRefresh = YES;
     }];
}

- (void)showLoginMessage
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[Settings sharedInstance] getStringByName:@"lessonslist_unregisteruserview_title"]
                                                        message:[[Settings sharedInstance] getStringByName:@"lessonslist_unregisteruserview_info"]
                                                       delegate:self
                                              cancelButtonTitle:[[Settings sharedInstance] getStringByName:@"lessonslist_unregisteruserview_cancel"]
                                              otherButtonTitles:[[Settings sharedInstance] getStringByName:@"lessonslist_unregisteruserview_login"] ,nil];
    [alertView show];
}

- (void)hideLoginMessage
{
}


- (void)updateLessonStatus:(NSDictionary*)lessonData afterDownload:(BOOL)status
{
    if ([[PFUser currentUser] isAuthenticated])
    {
        PFObject *lesson = [PFObject objectWithoutDataWithClassName:@"Purchases" objectId:lessonData[@"purchaseId"]];

        if (![lessonData[@"lessonDemo"] boolValue])
        {
            [lesson setObject:@"Lesson_is_active" forKey:@"purchaseStatusCode"];
        }
        else
        {
            [lesson setObject:@"Demo_is_active" forKey:@"purchaseStatusCode"];
        }

        if (status) {
            [lesson fetch];

            if ([lessonData[@"lessonDemo"] boolValue])
            {
                if (!lesson[@"DemoFirstDownloadDate"])
                {
                    lesson[@"DemoFirstDownloadDate"] = [NSDate date];
                }
                [lesson incrementKey:@"DemoDownloadCounter" byAmount:@(1)];

            }
            else
            {
                if (!lesson[@"LessonFirstDownloadDate"])
                {
                    lesson[@"LessonFirstDownloadDate"] = [NSDate date];
                }
                [lesson incrementKey:@"LessonDownloadCounter" byAmount:@(1)];
            }
        }
        [lesson saveInBackground];
    }
}

- (void)deleteLessonFromCoreData:(PFObject*)lesson
{
    PFObject *clip = lesson[@"clipKey"];
    NSString *identifier = clip[@"clipId"];
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Clip"];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
    [request setPredicate:predicate];
    [request setFetchLimit:1];

    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if ([array count])
    {
        Clip *localClip = array[0];
        NSString *lessonStatus = lesson[@"purchaseStatusCode"];
        lessonStatus = [lessonStatus lowercaseString];
        if ([lessonStatus isEqualToString:@"lesson_to_be_deleted"] || [lessonStatus isEqualToString:@"demo_order_removed"] || [lessonStatus isEqualToString:@"demo_to_be_deleted"] || [lessonStatus isEqualToString:@"lesson_removed_from_basket"])
        {
            if ([localClip.lessonDemo boolValue])
            {
                [lesson setObject:@"Demo_deleted" forKey:@"purchaseStatusCode"];
            }
            else
            {
                [lesson setObject:@"Lesson_deleted" forKey:@"purchaseStatusCode"];
            }
        }
        else if ([lessonStatus isEqualToString:@"demo_deleted"])
        {
            if ([localClip.lessonDemo boolValue])
            {
            }
            else
            {
                [lesson setObject:@"Lesson_deleted" forKey:@"purchaseStatusCode"];
            }
        }
        else if ([lessonStatus isEqualToString:@"lesson_deleted"])
        {
            if ([localClip.lessonDemo boolValue])
            {
                [lesson setObject:@"Demo_deleted" forKey:@"purchaseStatusCode"];
            }
        }

        if (lesson.isDirty)
            [lesson saveInBackground];

        [moc deleteObject:localClip];
        error = nil;

        if (![moc save:&error])
        {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }

        [self deleteUserFiles:identifier];
        [self.downloadClips removeObjectForKey:identifier];
        [self.localLessons removeObject:clip];
    }
}

- (void)logoutUserAndRemoveClips
{
    [self.tableView.pullToRefreshView stopAnimating];
}

- (void)checkifUserLogin
{
    if ([[PFUser currentUser] isAuthenticated])
    {
        PFUser *currentUser =  [PFUser currentUser];

        [currentUser fetchInBackgroundWithBlock:^(PFObject *object, NSError *error)
         {
             PFUser *currentUser =  [PFUser currentUser];
             PFObject *adminData = currentUser[@"adminData"];
             [adminData fetch];
             PFObject *userStatus = adminData[@"userStatus"];
             [userStatus fetch];

             if (!([userStatus[@"status"] isEqualToString:@"active"]) && !([userStatus[@"status"] isEqualToString:@"checking"]) && !([userStatus[@"status"] isEqualToString:@"app"]))
             {
                 NSString *message;

                 if ([userStatus[@"status"] isEqualToString:@"blocked"])
                 {
                     message = [[Settings sharedInstance] getStringByName:@"login_userstatusblocked"];
                 }
                 else if ([userStatus[@"status"] isEqualToString:@"hold"])
                 {
                     message = [[Settings sharedInstance] getStringByName:@"login_userstatushold"];
                 }
                 else if ([userStatus[@"status"] isEqualToString:@"new"])
                 {
                     message = [[Settings sharedInstance] getStringByName:@"login_userstatusnew"];
                 }

                 [self deleteDataAndShowMessage:message];
                 return;
             }

             NSString *deviceIdentifier = currentUser[@"deviceIdentifier"];
             if (![[Settings sharedInstance].deviceIdentifier isEqualToString:deviceIdentifier])
             {
                 [self deleteDataAndShowMessage:[[Settings sharedInstance] getStringByName:@"otherusermakelogin"]];
                 return;
             }
             else
             {
                 [self loadRemoteLessons];
             }
         }];
    }
    else
    {
        [self loadRemoteLessons];
    }
}

- (void)loadRemoteLessons
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    MMNavigationController *navigationController = (MMNavigationController*)self.parentViewController;
    FavoriteViewController *favoriteController = [navigationController getFavoriteViewController];
    [favoriteController.serverLessons removeAllObjects];

    PFQuery *query;
    BOOL searchPurchase = NO;

    User *user = [[Settings sharedInstance] loadUserFromCoreData];
    PFObject *world;
    if (user)
    {
        world = [PFObject objectWithoutDataWithClassName:@"WorldContentType" objectId:user.contentWorldId];
    }
    else
    {
        world = [PFObject objectWithoutDataWithClassName:@"WorldContentType" objectId:[Settings sharedInstance].appSettingsContentWorldId];
    }

    if ([[PFUser currentUser] isAuthenticated])
    {
        query = [PFQuery queryWithClassName:@"Purchases"];
        [query whereKey:@"world" equalTo:world];
        [query whereKey:@"userKey" equalTo:[PFUser currentUser]];
        [query includeKey:@"clipKey"];
        [query includeKey:@"clipKey.status"];
        [query includeKey:@"clipKey.category1"];
        [query includeKey:@"clipKey.category2"];
        [query includeKey:@"clipKey.category3"];
        [query includeKey:@"clipKey.category4"];
        [query includeKey:@"clipKey.teacher"];
        [query includeKey:@"clipKey.VoicePrompts"];
        searchPurchase = YES;
    }
    else
    {
        query = [PFQuery queryWithClassName:@"AnonymousClips"];
        [query whereKey:@"WorldContentType" equalTo:world];
        [query includeKey:@"clipKey"];
        [query includeKey:@"clipKey.status"];
        [query includeKey:@"clipKey.category1"];
        [query includeKey:@"clipKey.category2"];
        [query includeKey:@"clipKey.category3"];
        [query includeKey:@"clipKey.category4"];
        [query includeKey:@"clipKey.teacher"];
        [query includeKey:@"clipKey.VoicePrompts"];
    }

    __weak MainViewController *weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             [weakSelf.remoteLessons removeAllObjects];
             [weakSelf.lessons removeAllObjects];
             [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];

             [objects enumerateObjectsUsingBlock:^(PFObject *purchase, NSUInteger idx, BOOL *stop)
              {
                  PFObject *obj;
                  NSString *lessonStatus;
                  BOOL getLesson = NO;
                  BOOL lessonActive = NO;
                  BOOL demoActive = NO;
                  if (searchPurchase)
                  {
                      obj = purchase[@"clipKey"];
                      lessonStatus = purchase[@"purchaseStatusCode"];
                      lessonStatus = [lessonStatus lowercaseString];
                      NSDictionary *tmpLesson = self.downloadClips[obj[@"clipId"]];
                      NSDictionary *lessonTmpData = tmpLesson[@"data"];
                      if ([lessonStatus isEqualToString:@"lesson_purchased"])
                      {
                          if (!tmpLesson)
                          {
                              getLesson = YES;
                              lessonActive = YES;
                          }
                          else
                          {
                              if ([lessonTmpData[@"lessonDemo"] boolValue])
                              {
                                  NSDictionary *lessonToDelete = weakSelf.downloadClips[obj[@"clipId"]];
                                  if (lessonToDelete)
                                      [weakSelf.localLessons removeObject:lessonToDelete];

                                  [weakSelf deleteLessonFromCoreData:purchase];
                                  getLesson = YES;
                                  lessonActive = YES;
                              }
                              else
                              {
                                  [weakSelf updateLessonStatus:@{@"purchaseId":purchase.objectId,@"lessonDemo":@NO} afterDownload:NO];
                              }
                          }
                      }
                      else if ([lessonStatus isEqualToString:@"demo_ordered"])
                      {
                          if (!tmpLesson)
                          {
                              getLesson = YES;
                              demoActive = YES;
                          }
                          else
                          {

                              if ([lessonTmpData[@"lessonDemo"] boolValue])
                              {
                                  [weakSelf updateLessonStatus:@{@"purchaseId":purchase.objectId,@"lessonDemo":@YES} afterDownload:NO];
                              }
                              else
                              {
                                  NSDictionary *lessonToDelete = weakSelf.downloadClips[obj[@"clipId"]];
                                  if (lessonToDelete)
                                      [weakSelf.localLessons removeObject:lessonToDelete];

                                  [weakSelf deleteLessonFromCoreData:purchase];
                                  getLesson = YES;
                                  demoActive = YES;
                              }

                          }
                      }
                      else if ([lessonStatus isEqualToString:@"lesson_is_active"])
                      {
                          if (!tmpLesson)
                          {
                              getLesson = YES;
                              lessonActive = YES;
                          }
                          else
                          {
                              if ([lessonTmpData[@"lessonDemo"] boolValue])
                              {
                                  NSDictionary *lessonToDelete = weakSelf.downloadClips[obj[@"clipId"]];
                                  if (lessonToDelete)
                                      [weakSelf.localLessons removeObject:lessonToDelete];

                                  [weakSelf deleteLessonFromCoreData:purchase];
                                  getLesson = YES;
                                  lessonActive = YES;
                              }
                              else
                              {
                                  getLesson = YES;
                                  lessonActive = YES;
                              }
                          }
                      }
                      else if ([lessonStatus isEqualToString:@"demo_is_active"] || [lessonStatus isEqualToString:@"lesson_is_in_basket"])
                      {
                          if (!tmpLesson)
                          {
                              getLesson = YES;
                              demoActive = YES;
                          }
                          else
                          {
                              if ([lessonTmpData[@"lessonDemo"] boolValue])
                              {
                                  getLesson = YES;
                                  demoActive = YES;
                              }
                              else
                              {
                                  NSDictionary *lessonToDelete = weakSelf.downloadClips[obj[@"clipId"]];
                                  if (lessonToDelete)
                                      [weakSelf.localLessons removeObject:lessonToDelete];

                                  [weakSelf deleteLessonFromCoreData:purchase];
                                  getLesson = YES;
                                  demoActive = YES;
                              }
                          }
                      }
                  }
                  else
                  {
                      obj = purchase[@"clipKey"];
                      getLesson = YES;
                  }

                  if (getLesson && obj)
                  {
                      if (self.downloadClips[obj[@"clipId"]])
                      {
                          NSDictionary *lesson = weakSelf.downloadClips[obj[@"clipId"]];
                          [weakSelf.localLessons removeObject:lesson];
                      }

                      NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithCapacity:1];
                      PFFileObject *file;
                      if (searchPurchase)
                      {
                          if (lessonActive)
                              file = obj[@"clipFile"];
                          else
                              file = obj[@"demoClipFile"];
                      }
                      else
                      {
                          file = obj[@"clipFile"];
                      }

                      if (purchase[@"IncludingSupport"])
                      {
                          [data setObject:purchase[@"IncludingSupport"] forKey:@"lessonIncludingSupport"];
                      }

                      if (obj[@"category1"])
                      {
                          PFObject *category1 = obj[@"category1"];
                          if ([[category1 allKeys] count])
                          {
                              [data setObject:category1[@"value_en_us"] forKey:@"category1_en_us"];
                              [data setObject:category1[@"value_he_il"] forKey:@"category1_he_il"];
                              [data setObject:category1[@"order"] forKey:@"category1_order"];
                          }
                      }
                      if (obj[@"category2"])
                      {
                          PFObject *category2 = obj[@"category2"];
                          if ([[category2 allKeys] count])
                          {
                              [data setObject:category2[@"value_en_us"] forKey:@"category2_en_us"];
                              [data setObject:category2[@"value_he_il"] forKey:@"category2_he_il"];
                              [data setObject:category2[@"order"] forKey:@"category2_order"];
                          }
                      }
                      if (obj[@"category3"])
                      {
                          PFObject *category3 = obj[@"category3"];
                          if ([[category3 allKeys] count])
                          {
                              [data setObject:category3[@"value_en_us"] forKey:@"category3_en_us"];
                              [data setObject:category3[@"value_he_il"] forKey:@"category3_he_il"];
                              [data setObject:category3[@"order"] forKey:@"category3_order"];
                          }
                      }
                      if (obj[@"category4"])
                      {
                          PFObject *category4 = obj[@"category4"];
                          if ([[category4 allKeys] count])
                          {
                              [data setObject:category4[@"value_en_us"] forKey:@"category4_en_us"];
                              [data setObject:category4[@"value_he_il"] forKey:@"category4_he_il"];
                              [data setObject:category4[@"order"] forKey:@"category4_order"];
                          }
                      }
                      if (obj[@"teacher"])
                      {
                          PFObject *teacher = obj[@"teacher"];
                          [data setObject:teacher.objectId forKey:@"teacherId"];
                          NSString *fullName_he_il = [NSString stringWithFormat:@"%@ %@",teacher[@"firstName_he_il"],teacher[@"lastName_he_il"]];
                          [data setObject:fullName_he_il forKey:@"teacherName_he_il"];
                          NSString *fullName_en_us = [NSString stringWithFormat:@"%@ %@",teacher[@"firstName_en_us"],teacher[@"lastName_en_us"]];
                          [data setObject:fullName_en_us forKey:@"teacherName_en_us"];


                          PFObject *adminData = teacher[@"adminData"];
                          [adminData fetch];
                          PFObject *group = adminData[@"group"];
                          if (group)
                          {
                              [group fetchIfNeeded];
                              [data setObject:group.objectId forKey:@"teacherGroupId"];
                              if (group[@"parent"])
                              {
                                  PFObject *parentGroup = group[@"parent"];
                                  [data setObject:parentGroup.objectId forKey:@"teacherParentGroupId"];
                              }
                          }
                      }
                      if (obj[@"VoicePrompts"])
                      {
                          PFObject *voicePrompts = obj[@"VoicePrompts"];
                          [data setObject:voicePrompts.objectId forKey:@"defaultVoicePromptsId"];
                          [data setObject:voicePrompts forKey:@"voicePrompts"];
                      }
                      if (obj[@"clipSize"])
                      {
                          [data setObject:obj[@"clipSize"] forKey:@"clipSize"];
                      }
                      if (obj.createdAt)
                      {
                          [data setObject:obj.createdAt forKey:@"createdAt"];
                      }
                      if (obj[@"createdByUser"])
                      {
                          [data setObject:obj[@"createdByUser"] forKey:@"createdByUser"];
                      }
                      if (file.name)
                      {
                          [data setObject:file.name forKey:@"fileName"];
                      }
                      if (file.url)
                      {
                          [data setObject:file.url forKey:@"fileURL"];
                      }
                      if (obj[@"remarks_he_il"])
                      {
                          [data setObject:obj[@"remarks_he_il"] forKey:@"lessonRemarks_he_il"];
                      }
                      if (obj[@"remarks_en_us"])
                      {
                          [data setObject:obj[@"remarks_en_us"] forKey:@"lessonRemarks_en_us"];
                      }
                      if (obj[@"existsNikud"])
                      {
                          [data setObject:obj[@"existsNikud"] forKey:@"lessonNikudActive"];
                      }
                      if (obj[@"existsTeamim"])
                      {
                          [data setObject:obj[@"existsTeamim"] forKey:@"lessonTeamimActive"];
                      }
                      if (obj[@"clipId"])
                      {
                          [data setObject:obj[@"clipId"] forKey:@"identifier"];
                      }
                      if (obj[@"description_he_il"] && obj[@"description_he_il"] != [NSNull null])
                      {
                          [data setObject:obj[@"description_he_il"] forKey:@"lessonDescription_he_il"];
                      }
                      if (obj[@"name_he_il"] && obj[@"name_he_il"] != [NSNull null])
                      {
                          [data setObject:obj[@"name_he_il"] forKey:@"name_he_il"];
                      }
                      if (obj[@"description_en_us"] && obj[@"description_en_us"] != [NSNull null])
                      {
                          [data setObject:obj[@"description_en_us"] forKey:@"lessonDescription_en_us"];
                      }
                      if (obj[@"fingerPrint"])
                      {
                          [data setObject:obj[@"fingerPrint"] forKey:@"fingerPrint"];
                      }
                      if (obj[@"name_en_us"] && obj[@"name_en_us"] != [NSNull null])
                      {
                          [data setObject:obj[@"name_en_us"] forKey:@"name_en_us"];
                      }
                      if (obj[@"updatedByMyMentor"])
                      {
                          [data setObject:obj[@"updatedByMyMentor"] forKey:@"updatedByMyMentor"];
                      }
                      if (obj[@"performer"] && obj[@"performer"] != [NSNull null])
                      {
                          [data setObject:obj[@"performer"] forKey:@"performer_he_il"];
                      }
                      if (obj[@"Performer_en_us"] && obj[@"Performer_en_us"] != [NSNull null])
                      {
                          [data setObject:obj[@"Performer_en_us"] forKey:@"performer_en_us"];
                      }
                      if (obj[@"clipDuration"] && obj[@"clipDuration"] != [NSNull null])
                      {
                          [data setObject:obj[@"clipDuration"] forKey:@"lessonDuration"];
                      }
                      if (obj.updatedAt)
                      {
                          [data setObject:obj.updatedAt forKey:@"updatedAt"];
                      }
                      if (obj[@"version"])
                      {
                          [data setObject:obj[@"version"] forKey:@"version"];
                      }
                      if (obj.objectId)
                      {
                          [data setObject:obj.objectId forKey:@"lessonId"];
                      }
                      if (purchase.objectId)
                      {
                          [data setObject:purchase.objectId forKey:@"purchaseId"];
                      }

                      [data setObject:@([Settings sharedInstance].appSettingsArrowDirectionType) forKey:@"arrowDirectionType"];


                      if (searchPurchase)
                      {
                          if (lessonActive)
                          {
                              [data setObject:@NO forKey:@"lessonDemo"];
                          }
                          else if (demoActive)
                          {
                              [data setObject:@YES forKey:@"lessonDemo"];
                          }
                      }
                      else
                      {
                          [data setObject:@NO forKey:@"lessonDemo"];
                      }

                      [data setObject:[Settings sharedInstance].appSettingsContentWorldId forKey:@"lessonContentWorldId"];

                      NSMutableDictionary *item = [@{@"data" : data,
                                                   @"status" : @(1)} mutableCopy];
                      [weakSelf.remoteLessons addObject:item];
                      [favoriteController.serverLessons setObject:item forKey:data[@"identifier"]];
                  }
                  else
                  {
                      if (searchPurchase)
                      {
                          NSString *lessonStatus = purchase[@"purchaseStatusCode"];
                          lessonStatus = [lessonStatus lowercaseString];
                          if ([lessonStatus isEqualToString:@"lesson_to_be_deleted"])
                          {
                              NSDictionary *lessonToDelete = weakSelf.downloadClips[obj[@"clipId"]];
                              if (lessonToDelete)
                                  [weakSelf.localLessons removeObject:lessonToDelete];

                              [weakSelf deleteLessonFromCoreData:purchase];
                          }

                          if ([lessonStatus isEqualToString:@"demo_to_be_deleted"])
                          {
                              NSDictionary *lessonToDelete = weakSelf.downloadClips[obj[@"clipId"]];
                              if (lessonToDelete)
                                  [weakSelf.localLessons removeObject:lessonToDelete];

                              [weakSelf deleteLessonFromCoreData:purchase];
                          }

                          if ([lessonStatus isEqualToString:@"demo_order_removed"])
                          {
                              NSDictionary *lessonToDelete = weakSelf.downloadClips[obj[@"clipId"]];
                              if (lessonToDelete)
                                  [weakSelf.localLessons removeObject:lessonToDelete];

                              [weakSelf deleteLessonFromCoreData:purchase];
                          }
                          if ([lessonStatus isEqualToString:@"demo_deleted"])
                          {
                              NSDictionary *lessonToDelete = weakSelf.downloadClips[obj[@"clipId"]];
                              if (lessonToDelete)
                                  [weakSelf.localLessons removeObject:lessonToDelete];

                              [weakSelf deleteLessonFromCoreData:purchase];
                          }
                          if ([lessonStatus isEqualToString:@"lesson_deleted"])
                          {
                              NSDictionary *lessonToDelete = weakSelf.downloadClips[obj[@"clipId"]];
                              if (lessonToDelete)
                                  [weakSelf.localLessons removeObject:lessonToDelete];

                              [weakSelf deleteLessonFromCoreData:purchase];
                          }
                          if ([lessonStatus isEqualToString:@"lesson_removed_from_basket"])
                          {
                              NSDictionary *lessonToDelete = weakSelf.downloadClips[obj[@"clipId"]];
                              if (lessonToDelete)
                                  [weakSelf.localLessons removeObject:lessonToDelete];

                              [weakSelf deleteLessonFromCoreData:purchase];
                          }
                      }
                  }
              }];

             [weakSelf.lessons addObjectsFromArray:weakSelf.remoteLessons];
             [weakSelf.lessons addObjectsFromArray:weakSelf.localLessons];
             [weakSelf.lessons sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
             {
                 NSDictionary *lesson1 = obj1[@"data"];
                 NSDictionary *lesson2 = obj2[@"data"];
                 NSString *name1 = lesson1[@"name"];
                 NSString *name2 = lesson2[@"name"];
                 return [name1 compare:name2];
             }];

             [weakSelf.tableView reloadData];
         }
         else
         {
             [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
             NSLog(@"Error: %@", [error localizedDescription]);
         }
     }];
}

- (void)loadLocalLessons
{
    [self.downloadClips removeAllObjects];
    [self.localLessons removeAllObjects];
    [self.lessons removeAllObjects];

    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Clip"];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lessonContentWorldId == %@", [Settings sharedInstance].appSettingsContentWorldId];
    [request setPredicate:predicate];

    NSSortDescriptor *sortDescriptor;
    if ([[Settings sharedInstance].currentLanguage isEqualToString:@"he_il"])
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name_he_il" ascending:YES];
    else
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name_en_us" ascending:YES];

    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    [array enumerateObjectsUsingBlock:^(Clip *obj, NSUInteger idx, BOOL *stop)
    {
        NSMutableDictionary *data = [obj loadClipFromCoreData];

        NSMutableDictionary *lesson = [@{@"data" : data,
                                     @"status" : @(1)} mutableCopy];
        
        [self.downloadClips setObject:lesson forKey:obj.identifier];
        [self.localLessons addObject:lesson];
        [self.lessons addObject:lesson];
    }];

    [self.tableView reloadData];
    self.lessonUpdate = NO;
    [Settings sharedInstance].lessonUpdate = NO;
}

- (void)searchLessonByText:(NSString*)text
{
    if ([text length])
    {
        NSPredicate* predicate;
        if ([[Settings sharedInstance].currentLanguage isEqualToString:@"he_il"])
        {
            predicate = [NSPredicate predicateWithFormat:@"data.name_he_il contains[c] %@",text];
        }
        else
        {
            predicate = [NSPredicate predicateWithFormat:@"data.name_en_us contains[c] %@",text];
        }
        self.searchResults = [[self.lessons filteredArrayUsingPredicate:predicate] mutableCopy];
//        if ([self.searchResults count])
//        {
            [self.tableView reloadData];
//        }
    }
    else
    {
        [self.searchResults removeAllObjects];
        [self.searchResults addObjectsFromArray:self.lessons];
        [self.tableView reloadData];
    }
}

- (void)filterLessons:(NSUInteger)index
{
    NSSortDescriptor *category1Sorter = [[NSSortDescriptor alloc] initWithKey:@"data.category1_order" ascending:YES];
    NSSortDescriptor *category2Sorter = [[NSSortDescriptor alloc] initWithKey:@"data.category2_order" ascending:YES];
    NSSortDescriptor *category3Sorter = [[NSSortDescriptor alloc] initWithKey:@"data.category3_order" ascending:YES];
    NSSortDescriptor *category4Sorter = [[NSSortDescriptor alloc] initWithKey:@"data.category4_order" ascending:YES];
    NSSortDescriptor *lessonNameSorter = nil;
    NSSortDescriptor *nameSorter = nil;
    if ([[Settings sharedInstance].currentLanguage isEqualToString:@"he_il"])
    {
        nameSorter = [[NSSortDescriptor alloc] initWithKey:@"data.teacherName_he_il" ascending:YES];
        lessonNameSorter = [[NSSortDescriptor alloc] initWithKey:@"data.name_he_il" ascending:YES];
    }
    if ([[Settings sharedInstance].currentLanguage isEqualToString:@"en_us"])
    {
        nameSorter = [[NSSortDescriptor alloc] initWithKey:@"data.teacherName_en_us" ascending:YES];
        lessonNameSorter = [[NSSortDescriptor alloc] initWithKey:@"data.name_en_us" ascending:YES];
    }

    switch (index) {
        case 0:
        {
            if ([[Settings sharedInstance].currentLanguage isEqualToString:@"en_us"])
                [self.lessons sortUsingDescriptors:@[nameSorter,category1Sorter,category2Sorter,category3Sorter,category4Sorter]];
            else
                [self.lessons sortUsingDescriptors:@[category4Sorter,category1Sorter,category2Sorter,category3Sorter,nameSorter]];
            break;
        }
        case 1:
        {
            if ([[Settings sharedInstance].currentLanguage isEqualToString:@"en_us"])
                [self.lessons sortUsingDescriptors:@[category1Sorter,category2Sorter,category3Sorter,category4Sorter,nameSorter]];
            else
                [self.lessons sortUsingDescriptors:@[category3Sorter,category1Sorter,category2Sorter,category4Sorter,nameSorter]];
            break;
        }
        case 2:
        {
            if ([[Settings sharedInstance].currentLanguage isEqualToString:@"en_us"])
                [self.lessons sortUsingDescriptors:@[category3Sorter,category1Sorter,category2Sorter,category4Sorter,nameSorter]];
            else
                [self.lessons sortUsingDescriptors:@[category1Sorter,category2Sorter,category3Sorter,category4Sorter,nameSorter]];
            break;
        }
        case 3:
        {
            if ([[Settings sharedInstance].currentLanguage isEqualToString:@"en_us"])
                [self.lessons sortUsingDescriptors:@[category4Sorter,category1Sorter,category2Sorter,category3Sorter,nameSorter]];
            else
                [self.lessons sortUsingDescriptors:@[nameSorter,category1Sorter,category2Sorter,category3Sorter,category4Sorter]];
            break;
        }
        default:
            [self.lessons sortUsingDescriptors:@[lessonNameSorter]];
            break;
    }

    [self.tableView reloadData];
}

- (IBAction)searchButtonTouchUpInside:(id)sender
{
    [self hideLoginMessage];
    self.searchActive = YES;
    [self.searchTextView becomeFirstResponder];
    [self showSearchBar:YES];
    [self.searchResults removeAllObjects];
    [self.searchResults addObjectsFromArray:self.lessons];
    [self.tableView reloadData];
}

- (IBAction)menuButtonDidPressed:(id)sender
{
    [self.searchTextView resignFirstResponder];
    [self.sideBar show:0];
}

- (IBAction)filterButtonValueChanged:(SLTDoubleTapSegmentedControl*)sender
{
    [self filterLessons:sender.selectedSegmentIndex];
}

- (IBAction)searchLessonCancelButtonClicked:(id) sender
{
    [self.searchTextView resignFirstResponder];
    self.searchTextView.text = @"";
    self.searchActive = NO;
    [self hideSearchBar:YES];
}

- (IBAction)textFieldValueChanged:(UITextField*)sender
{
    [self searchLessonByText:sender.text];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"openLessonInformationFromMainSegue"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *tmp;

        if (self.searchActive)
        {
            [self.searchTextView resignFirstResponder];
            [self hideSearchBar:NO];
            tmp = self.searchResults[indexPath.row];
        }
        else
        {
            tmp = self.lessons[indexPath.row];
        }

        NSDictionary *data = tmp[@"data"];

        LessonInformationViewController *viewController = segue.destinationViewController;
        viewController.fileName = data[@"identifier"];
        viewController.lessonClip = tmp;
        viewController.managedObjectContext = self.managedObjectContext;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInternetStatusChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateNaturalLanguageUI object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateLessonsListAfterAction object:nil];
}

@end

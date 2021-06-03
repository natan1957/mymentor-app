//
//  FavoriteViewController.m
//  MyMentorV2
//
//  Created by Walter Yaron on 12/29/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import "FavoriteViewController.h"
#import "MMNavigationController.h"
#import "AppDelegate.h"
#import "Settings.h"
#import "Clip.h"
#import "FavoriteCell.h"
#import "Defines.h"
#import "MBProgressHUD.h"
#import "DownloadMMN.h"
#import "PlayerViewController.h"
#import "LessonInformationViewController.h"
#import "RNFrostedSidebar.h"
#import "CocoaSecurity.h"

@interface FavoriteViewController () <  UITableViewDataSource,
                                        UITableViewDelegate,
                                        FavoriteCellDelegate,
                                        RNFrostedSidebarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *currentLanguage;
@property (strong, nonatomic) NSMutableArray *lessons;
@property (strong, nonatomic) NSMutableArray *localLessons;
@property (strong, nonatomic) NSMutableArray *localClips;
@property (strong, nonatomic) NSMutableDictionary *downloadClips;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) NSDate *lastSwipeDate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) RNFrostedSidebar *sideBar;
@property (assign, nonatomic) BOOL internetActive;
@property (assign, nonatomic) BOOL searchActive;

- (IBAction)menuButtonDidPressed:(id)sender;

@end

@implementation FavoriteViewController

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

- (void)lessonDownloadCancelClicked:(NSIndexPath*)indexPath
{
    NSMutableDictionary *tmp = self.lessons[indexPath.row];
    DownloadMMN *download = tmp[@"download"];
    [download cancelDownload];
    [tmp removeObjectForKey:@"download"];
    [tmp setObject:@(ClipRegular) forKey:@"status"];
    FavoriteCell *cell = (FavoriteCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell hideProgressBar];
}

- (void)showPlayerView:(NSIndexPath*)indexPath
{
    PlayerViewController *playerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayerViewController"];
    NSDictionary *tmp = self.lessons[indexPath.row];
    NSDictionary *data = tmp[@"data"];
    playerViewController.fileName = data[@"identifier"];
    playerViewController.lessonName = data[@"name"];
    playerViewController.lessonDictionary = data;
    playerViewController.managedObjectContext = self.managedObjectContext;
    if (self.HUD)
    {
        [self.HUD hide:YES];
    }

    [self.navigationController pushViewController:playerViewController animated:YES];
}

- (void)deleteDataAndShowMessage:(NSString*)message
{
    [Settings deleteAllUserFiles];
    [Settings deleteClips];
    [Settings deleteUser];
    [Settings deleteContentWorlds];
    [PFUser logOut];
    [self setupMenu];
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
            if ([[PFUser currentUser] isAuthenticated])
            {
                self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                __weak FavoriteViewController *weakSelf = self;
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

                         [weakSelf deleteDataAndShowMessage:message];
                         return;
                     }


                     NSString *deviceIdentifier = currentUser[@"deviceIdentifier"];
                     if (![[Settings sharedInstance].deviceIdentifier isEqualToString:deviceIdentifier])
                     {
                        [weakSelf deleteDataAndShowMessage:[[Settings sharedInstance] getStringByName:@"otherusermakelogin"]];
                        return;
                     }
                     else
                     {
                         [weakSelf showPlayerView:indexPath];
                     }
                 }];
            }
            else
            {
                [self showPlayerView:indexPath];
            }

            break;
        }
        case UPDATEBUTTON:
        {
            if (self.internetActive)
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
            if (self.internetActive)
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
            if (self.internetActive)
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

- (void)deleteClip:(NSIndexPath*)indexPath
{
    NSUInteger lessonsCount = [self.lessons count];
    NSDictionary *tmp = self.lessons[indexPath.row];
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
            error = nil;
            [manager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:item] error:&error];
            if (error)
            {
                NSLog(@"%@",[error localizedDescription]);
            }
        }
    }

    [self.lessons removeObjectAtIndex:indexPath.row];

    if ([self.lessons count] != lessonsCount)
    {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.4f];
    }
}

- (void)updateClipToCoreData:(NSIndexPath*)indexPath
{
    NSDictionary *lesson = self.lessons[indexPath.row];
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

- (void)saveNewClipToCoreData:(NSIndexPath*)indexPath
{
    NSDictionary *lesson = self.lessons[indexPath.row];
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

- (void)updateClip:(NSIndexPath*)indexPath
{
    [self performAction:UPDATEBUTTON onClip:indexPath];
}

- (void)downloadClip:(NSIndexPath*)indexPath
{
    [self performAction:DOWNLOADBUTTON onClip:indexPath];
}

- (void)performAction:(NSUInteger)action onClip:(NSIndexPath*)indexPath
{
    NSMutableDictionary *tmp = self.lessons[indexPath.row];
    NSMutableDictionary *data = tmp[@"data"];

    DownloadMMN *download = [[DownloadMMN alloc] init];
    [tmp setObject:download forKey:@"download"];
    [tmp setObject:@(ClipDownload) forKey:@"status"];
    //[self.downloadArray addObject:download];
    __weak FavoriteViewController *weakSelf = self;
    FavoriteCell *cell = (FavoriteCell*)[weakSelf.tableView cellForRowAtIndexPath:indexPath];
    [cell showProgressBar];
    [download setDownloadProgressBlock:^(long long totalBytesRead, long long totalBytesExpectedToRead)
     {
         FavoriteCell *cell = (FavoriteCell*)[weakSelf.tableView cellForRowAtIndexPath:indexPath];
         float currentProgress = ((float)totalBytesRead) / totalBytesExpectedToRead;
         cell.circularProgressView.progress = currentProgress;
     }];

    [download downloadWithFilename:data[@"fileName"] andURL:data[@"fileURL"] withSuccess:^(BOOL done)
     {
         [tmp removeObjectForKey:@"download"];
         [tmp setObject:@(ClipRegular) forKey:@"status"];
         //[self.downloadArray removeObject:download];
         FavoriteCell *cell = (FavoriteCell*)[weakSelf.tableView cellForRowAtIndexPath:indexPath];

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
         [cell hideProgressBar];
     }
                       withFailure:^(NSError *error)
     {
         
     }];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.lessons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FavoriteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteCell"];
    if (!cell)
    {
        cell = [[FavoriteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FavoriteCell"];
    }
    NSDictionary *lesson = self.lessons[indexPath.row];
    NSDictionary *data = lesson[@"data"];

    if ([self.currentLanguage isEqualToString:@"he_il"])
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
    else if ([self.currentLanguage isEqualToString:@"en_us"])
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


        cell.favoriteImageView.image = [UIImage imageNamed:@"btn_CellFavorite_selected.png"];

    //    cell.dateLabel.text = [self.formatter stringFromDate:data[@"createdAt"]];
    //    cell.versionLabel.text = [NSString stringWithFormat:@"גירסה %@",data[@"version"]];
    cell.delegate = self;
    cell.indexPath = indexPath;

    if (self.serverLessons[data[@"identifier"]])
    {
        NSDate *localDate = data[@"updatedByMyMentor"];
        NSDictionary *clip = self.serverLessons[data[@"identifier"]];
        NSDictionary *data1 = clip[@"data"];
        NSDate *serverDate = data1[@"updatedByMyMentor"];

        NSComparisonResult result = [serverDate compare:localDate];
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
         [self updatePlayButton:cell.statusButton withClip:data[@"identifier"]];
        cell.statusButton.tag = PLAYBUTTON;
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
    FavoriteCell *cell = (FavoriteCell*)[tableView cellForRowAtIndexPath:indexPath];
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
        FavoriteCell *cell = (FavoriteCell*)[tableView cellForRowAtIndexPath:indexPath];
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
    [self.lessons enumerateObjectsUsingBlock:^(NSMutableDictionary *obj, NSUInteger idx, BOOL *stop)
     {
         [obj setObject:@(ClipRegular) forKey:@"status"];
     }];
}

- (void)searchLessonByText:(NSString*)text
{
    if ([text length])
    {
        NSPredicate* predicate;
        if ([self.currentLanguage isEqualToString:@"he_il"])
        {
            predicate = [NSPredicate predicateWithFormat:@"data.name_he_il beginswith[c] %@",text];
        }
        else
        {
            predicate = [NSPredicate predicateWithFormat:@"data.name_en_us beginswith[c] %@",text];
        }
        self.searchResults = [self.lessons filteredArrayUsingPredicate:predicate];
        if ([self.searchResults count])
        {
            [self.tableView reloadData];
        }
    }
    else
    {
        self.searchResults = self.lessons;
        [self.tableView reloadData];
    }
}

- (void)filterLessons:(NSUInteger)index
{
    [self.lessons sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
     {
         NSDictionary *lesson1 = obj1[@"data"];
         NSDictionary *lesson2 = obj2[@"data"];
         NSString *category1Name,*category2Name;

         if ([self.currentLanguage isEqualToString:@"he_il"])
         {
             switch (index)
             {
                 case 0:
                     category1Name = lesson1[@"category1_he_il"];
                     category2Name = lesson2[@"category1_he_il"];
                     break;
                 case 1:
                     category1Name = lesson1[@"category2_he_il"];
                     category2Name = lesson2[@"category2_he_il"];
                     break;
                 case 2:
                     category1Name = lesson1[@"category3_he_il"];
                     category2Name = lesson2[@"category3_he_il"];
                     break;
                 case 3:
                     category1Name = lesson1[@"category4_he_il"];
                     category2Name = lesson2[@"category4_he_il"];
                     break;
                 default:
                     category1Name = lesson1[@"name"];
                     category2Name = lesson2[@"name"];
                     break;
             }
         }
         else if ([self.currentLanguage isEqualToString:@"en_us"])
         {
             switch (index)
             {
                 case 0:
                     category1Name = lesson1[@"category1_en_us"];
                     category2Name = lesson2[@"category1_en_us"];
                     break;
                 case 1:
                     category1Name = lesson1[@"category2_en_us"];
                     category2Name = lesson2[@"category2_en_us"];
                     break;
                 case 2:
                     category1Name = lesson1[@"category3_en_us"];
                     category2Name = lesson2[@"category3_en_us"];
                     break;
                 case 3:
                     category1Name = lesson1[@"category4_en_us"];
                     category2Name = lesson2[@"category4_en_us"];
                     break;
                 default:
                     category1Name = lesson1[@"name"];
                     category2Name = lesson2[@"name"];
                     break;
             }
         }
         return [category1Name compare:category2Name];
     }];

    [self.tableView reloadData];
}

- (void)loadLocalLessons
{
    [self.lessons removeAllObjects];
    NSManagedObjectContext *moc = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Clip"];

    NSSortDescriptor *sortDescriptor;
    if ([self.currentLanguage isEqualToString:@"he_il"])
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name_he_il" ascending:YES];
    else
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name_en_us" ascending:YES];

    [request setSortDescriptors:@[sortDescriptor]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favorite = %@", @YES];
    [request setPredicate:predicate];

    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    [array enumerateObjectsUsingBlock:^(Clip *obj, NSUInteger idx, BOOL *stop)
     {

         NSMutableDictionary *data = [obj loadClipFromCoreData];
         NSMutableDictionary *lesson = [@{@"data" : data,
                                          @"status" : @(1)} mutableCopy];

         [self.downloadClips setObject:lesson forKey:obj.identifier];
         [self.localLessons addObject:lesson];

         if ([self.serverLessons count])
         {
             [self.serverLessons enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *serverLesson, BOOL *stop)
             {
                 if ([key isEqualToString:obj.identifier])
                 {
                            [self.lessons addObject:lesson];
                 }
             }];
         }
         else
         {
             [self.lessons addObject:lesson];
         }
     }];
    [self.tableView reloadData];
}

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserverForName:kInternetStatusChanged
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note)
     {
         self.internetActive = [note.object boolValue];
     }];
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
    self.title = [[Settings sharedInstance] getStringByName:@"favorites_title"];
}

- (void)setupView
{
    self.searchActive   = NO;
    Settings *localSettings = [Settings sharedInstance];
    self.currentLanguage = [[localSettings currentLanguage] lowercaseString];
    self.managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.localLessons   = [[NSMutableArray alloc] init];
        self.serverLessons  = [[NSMutableDictionary alloc] init];
        self.lessons        = [[NSMutableArray alloc] init];
        self.searchResults  = [[NSArray alloc] init];
        self.downloadClips  = [[NSMutableDictionary alloc] init];
        self.localClips     = [[NSMutableArray alloc] init];
        self.formatter      = [[NSDateFormatter alloc] init];
    }
    return self;
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

    [self loadLocalLessons];
    [self updateTexts];
    [self setupMenu];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.title = @"";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerObservers];
    [self setupView];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"openLessonInformationFromFavoritesSegue"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *tmp = self.lessons[indexPath.row];
        NSDictionary *data = tmp[@"data"];
        LessonInformationViewController *viewController = segue.destinationViewController;
        viewController.fileName = data[@"identifier"];
        viewController.lessonClip = tmp;
        viewController.managedObjectContext = self.managedObjectContext;
    }
}

- (IBAction)menuButtonDidPressed:(id)sender
{
    [self.sideBar show:1];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInternetStatusChanged object:nil];
}

@end

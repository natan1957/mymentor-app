//
//  AppDelegate.m
//  MyMentor
//
//  Created by Walter Yaron on 4/24/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

//#import <Fabric/Fabric.h>
#import <Parse/Parse.h>
//#import <Crashlytics/Crashlytics.h>
#import "AppDelegate.h"
#import "AFClient.h"
#import "PlayerViewController.h"
#import "Defines.h"
#import "FirstViewController.h"
#import "ChooseContentWorldViewController.h"
#import "TermsViewController.h"
#import "MMNavigationController.h"
#import "Settings.h"

@interface AppDelegate () <ChooseContentWorldDelegate,TermsViewDelegate>

@property (strong, nonatomic) ChooseContentWorldViewController *worldsController;
@property (strong, nonatomic) TermsViewController *termsViewController;

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (void)serverUpdateWorldSuccessfully
{
    [self.window setRootViewController:self.termsViewController];
    [self.window makeKeyAndVisible];
}

- (void)userDidApprove
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTermsApproved];
    [self.window setRootViewController:self.mainController];
    [self.window makeKeyAndVisible];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateLessonsListAfterAction
                                                        object:nil
                                                      userInfo:nil];
}

- (void)firstViewControllerDidFinish
{
    [UIView transitionFromView:self.appSetupViewController.view
                        toView:self.worldsController.view
                      duration:1.4f
                       options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve
                    completion:^(BOOL finished)
     {
         if (finished)
         {
             [self.window setRootViewController:self.worldsController];
             [self.window makeKeyAndVisible];
         }
     }];
}

-(void) addReachabilityCheck
{
    __weak AppDelegate *weakSelf = self;
    [[[AFClient sharedInstance] client] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         switch (status)
         {
             case AFNetworkReachabilityStatusUnknown:
             {
                 weakSelf.internetActive = NO;
                 [[NSNotificationCenter defaultCenter] postNotificationName:kInternetStatusChanged
                                                                     object:@NO
                                                                   userInfo:nil];
                 break;
             }
             case AFNetworkReachabilityStatusNotReachable:
             {
                 weakSelf.internetActive = NO;
                 [[NSNotificationCenter defaultCenter] postNotificationName:kInternetStatusChanged
                                                                     object:@NO
                                                                   userInfo:nil];
                 break;
             }
             case AFNetworkReachabilityStatusReachableViaWWAN:
             case AFNetworkReachabilityStatusReachableViaWiFi:
             {
                 weakSelf.internetActive = YES;
                 [[NSNotificationCenter defaultCenter] postNotificationName:kInternetStatusChanged
                                                                     object:@YES
                                                                   userInfo:nil];
                 break;
             }
             default:
                 break;
         }
     }];
//    [[[AFClient sharedInstance] client] startMonitoringNetworkReachability];
}

- (void)setupMainViewController
{
    self.mainController = nil;
    self.worldsController = nil;
    self.termsViewController = nil;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self.mainController = [storyboard instantiateViewControllerWithIdentifier:@"RevealViewController"];
    self.worldsController = [storyboard instantiateViewControllerWithIdentifier:@"ChooseContentWorldViewController"];
    self.worldsController.delegate = self;
    self.termsViewController = [storyboard instantiateViewControllerWithIdentifier:@"TermsViewController"];
    self.termsViewController.delegate = self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self addReachabilityCheck];
    //[AudioPlayer sharedInstance];
//    [Fabric with:@[CrashlyticsKit]];

    [Settings sharedInstance];

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        [[UIView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
    }
    
    NSLog(@"test");

    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration>  _Nonnull configuration)
    {
        configuration.applicationId = @"qvC0Pgq7QGSqntpqnA75vGnNUBewQ08DplQcJtMI";
        configuration.clientKey = @"LIKvXjU0UVJiTy2uxRi6qA7K8YXHpLsmVu8t4Hl9";
//        BOOL production = [Settings sharedInstance].environmentProduction;
//        if (production)
//        {
//            configuration.server = @"https://parse4mymentorapp.herokuapp.com/parse/";
//        }
//        else
//        {
            configuration.server = @"https://parse4mymentorapptest.herokuapp.com/parse/";
//        }
        configuration.localDatastoreEnabled = YES;
        
    }]];
    

    PFACL *defaultACL = [PFACL ACL];

    // register a custom class for a tag

	// for debugging, we make sure that UIView methods are only called on main thread
//	[UIView toggleViewMainThreadChecking];

    // If you would like all objects to be private by default, remove this line.
    [defaultACL setPublicReadAccess:YES];

    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [Parse setLogLevel:PFLogLevelDebug];
    self.internetActive = YES;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self.appSetupViewController = [storyboard instantiateInitialViewController];
    [self setupMainViewController];

    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           UITextAttributeFont : [UIFont fontWithName:@"HelveticaNeue-Medium" size:22.f],
                                                           UITextAttributeTextColor : [UIColor whiteColor],
                                                           UITextAttributeTextShadowColor : [UIColor clearColor],
                                                           UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 0.0f)]}];

    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];





    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        [self.window setTintColor:[UIColor whiteColor]];
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
//        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:16.f/255.f green:134.f/255.f blue:203.f/255.f alpha:1.f]];
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.f/255.f green:149.f/255.f blue:219.f/255.f alpha:1.f]];
        [[UISwitch appearance] setTintColor:[UIColor redColor]];
        [[UISwitch appearance] setBackgroundColor:[UIColor redColor]];
    }
    else
    {
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.f/255.f green:129.f/255.f blue:210.f/255.f alpha:1.f]];
    }

    self.window.rootViewController = self.appSetupViewController;
    [self.window makeKeyAndVisible];

    [DTTextAttachment registerClass:[DTObjectTextAttachment class] forTagName:@"Walter"];

	// preload font matching table
	[DTCoreTextFontDescriptor asyncPreloadFontLookupTable];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    [[Settings sharedInstance] setIdletimer:NO];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    if (self.wasActiveBeforeInterrupt)
//    {
//        NSLog(@"countinue to play");
//
//        [[PlayerViewController sharedInstance] performSelector:@selector(play) withObject:nil afterDelay:2.f];
//
//    }

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    PFUser *user = [PFUser currentUser];
    if (user)
    {
        [currentInstallation setObject:user forKey:@"User"];
        currentInstallation.channels = @[@"global"];
        [currentInstallation saveInBackground];
    }
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if (error.code == 3010)
    {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    }
    else
    {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
	}
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
//    [PFPush handlePush:userInfo];
//
//    if (application.applicationState != UIApplicationStateActive) {
//        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
//    }

     [PFPush handlePush:userInfo];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - ()

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error
{
    if ([result boolValue])
    {
        NSLog(@"ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
    }
    else
    {
        NSLog(@"ParseStarterProject failed to subscribe to push notifications on the broadcast channel.");
    }
}

//- (void)flushDatabase
//{
//    [_managedObjectContext lock];
//    NSArray *stores = [_persistentStoreCoordinator persistentStores];
//    for(NSPersistentStore *store in stores)
//    {
//        [_persistentStoreCoordinator removePersistentStore:store error:nil];
//        [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
//    }
//    [_managedObjectContext unlock];
//    _managedObjectModel    = nil;
//    _managedObjectContext  = nil;
//    _persistentStoreCoordinator = nil;
//
//    [Settings sharedInstance].managedObjectContext = self.managedObjectContext;
//}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"mymentorV2" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"mymentorV 2.sqlite"];

    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES};

    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.

         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.


         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.

         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]

         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}

         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.

         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

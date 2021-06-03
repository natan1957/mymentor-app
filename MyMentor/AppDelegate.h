//
//  AppDelegate.h
//  MyMentor
//
//  Created by Walter Yaron on 4/24/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppSetupViewController.h"
#import "MainViewController.h"
#import "MMNavigationController.h"
#import "FirstViewController.h"

@class DemoTextViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,FirstViewControllerDelegate>

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AppSetupViewController *appSetupViewController;
@property (strong, nonatomic) MMNavigationController *mainController;
@property (assign, nonatomic) BOOL internetActive;

- (void)saveContext;
- (NSURL*)applicationDocumentsDirectory;
- (void)setupMainViewController;

@end

//
//  AppDelegate.m
//  LionsRoar
//
//  Created by Matt Dahl on 2/25/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import "AppDelegate.h"
#import "TopNewsTableViewController.h"
#import "NewsViewController.h"
#import "SectionsViewController.h"
#import "SearchViewController.h"
#import "SettingsViewController.h"
#import "ArticleStore.h"
#import "APIConnection.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize topNewsTableViewController = _topNewsTableViewController;
@synthesize newsViewController = _newsViewController;
@synthesize sectionViewController = _sectionViewController;
@synthesize searchViewController = _searchViewController;
@synthesize settingsViewController = _settingsViewController;
@synthesize articleStore = _articleStore;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOption {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
        
    // registers for push notifications
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasBeenLaunched"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"pushNotifications"]) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"pushNotifications"];
    }
    
    // load saved store
    _articleStore = [NSKeyedUnarchiver unarchiveObjectWithFile:[self archivePath]];
    
    if (!_articleStore)
        _articleStore = [[ArticleStore alloc] init]; // holds a reference for later saving
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasBeenLaunched"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"autoUpdateArticles"]) {
        [ArticleStore startup]; // starts loading articles
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"autoUpdateArticles"];
    }
    
    _topNewsTableViewController = [[TopNewsTableViewController alloc] init];
    _newsViewController = [[NewsViewController alloc] init];
    _sectionViewController = [[SectionsViewController alloc] init];
    _searchViewController = [[SearchViewController alloc] init];
    _settingsViewController = [[SettingsViewController alloc] init];
        
    UINavigationController *topNewsNavController = [[UINavigationController alloc] initWithRootViewController:_topNewsTableViewController];
    UINavigationController *newsNavController = [[UINavigationController alloc] initWithRootViewController:_newsViewController];
    UINavigationController *sectionNavController = [[UINavigationController alloc] initWithRootViewController:_sectionViewController];
    UINavigationController *searchNavController = [[UINavigationController alloc] initWithRootViewController:_searchViewController];
    UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:_settingsViewController];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    NSArray *viewControllers = [NSArray arrayWithObjects:topNewsNavController, newsNavController, sectionNavController, searchNavController, settingsNavController, nil];
    [tabBarController setViewControllers:viewControllers];

    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"BlankNavBarImage.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:255.0/255.0 green:130.0/255.0 blue:33.0/255.0 alpha:1],
                                                           UITextAttributeTextColor,
                                                           [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
                                                           UITextAttributeTextShadowColor,
                                                           [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
                                                           UITextAttributeTextShadowOffset,
                                                           [UIFont fontWithName:@"Charcoal CY" size:22],
                                                           UITextAttributeFont,
                                                           nil]];
    
    [[self window] setRootViewController:tabBarController];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [NSKeyedArchiver archiveRootObject:_articleStore toFile:[self archivePath]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // We need to properly handle activation of the app with regards to Facebook Login
    // (e.g., returning from iOS 6.0 Login Dialog or from fast app switching).
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    
    [NSKeyedArchiver archiveRootObject:_articleStore toFile:[self archivePath]];
    
    [self saveContext];
}

- (NSString *)archivePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
        
    return [documentDirectory stringByAppendingPathComponent:@"articleStore.archive"];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"LionsRoar" withExtension:@"momd"];
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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"LionsRoar.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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

#pragma mark - Push notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	NSLog(@"My push notification token is: %@", deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"Failed to get token, error: %@", error);
}


+ (BOOL)isRetina {
    if ([UIScreen mainScreen].scale == 2)
        return YES;
    return NO;
}

@end

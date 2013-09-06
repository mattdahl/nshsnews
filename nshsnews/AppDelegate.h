//
//  AppDelegate.h
//  LionsRoar
//
//  Created by Matt Dahl on 2/25/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TopNewsTableViewController;
@class NewsViewController;
@class SectionsViewController;
@class SearchViewController;
@class SettingsViewController;
@class ArticleStore;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TopNewsTableViewController *topNewsTableViewController;
@property (strong, nonatomic) NewsViewController *newsViewController;
@property (strong, nonatomic) SectionsViewController *sectionViewController;
@property (strong, nonatomic) SearchViewController *searchViewController;
@property (strong, nonatomic) SettingsViewController *settingsViewController;
@property (strong, nonatomic) ArticleStore *articleStore;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSString *)archivePath;

+ (BOOL)isRetina;

@end

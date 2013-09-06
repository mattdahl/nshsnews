//
//  NewsViewController.h
//  LionsRoar
//
//  Created by Matt Dahl on 4/7/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingViewController.h"

@interface NewsViewController : UITableViewController <NSCoding, UITableViewDelegate, UITableViewDataSource, LoadingViewControllerDelegate> {
    BOOL isFinishedLoading;
}

@property (nonatomic, strong) LoadingViewController *loadingViewController;

- (void)updateArticles;
+ (NSString *)archivePath;

@end
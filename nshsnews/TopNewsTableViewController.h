//
//  TopNewsTableViewController.h
//  LionsRoar
//
//  Created by Matt Dahl on 3/29/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleStore.h"
#import "LoadingViewController.h"

@interface TopNewsTableViewController : UITableViewController <UITableViewDelegate, LoadingViewControllerDelegate> {
    BOOL isFinishedLoading;
}

@property (nonatomic, strong) LoadingViewController *loadingViewController;

- (void)loadArticles;
- (void)setNeedsRefresh;

@end
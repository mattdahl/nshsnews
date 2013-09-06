//
//  SectionNewsViewController.h
//  LionsRoar
//
//  Created by Matt Dahl on 4/23/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingViewController.h"
#import "APIConnection.h"

@interface SectionNewsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, LoadingViewControllerDelegate> {
    NSArray *articles;
    BOOL isFinishedLoading;
}

@property NSString *sectionTitle;
@property (nonatomic, strong) LoadingViewController *loadingViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil sectionTitle:(NSString *)t;

- (Article *)firstArticle;

@end
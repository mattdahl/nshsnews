//
//  SearchResultsViewController.h
//  nshsnews
//
//  Created by Matt Dahl on 6/2/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil articles:(NSArray *)a;

@end

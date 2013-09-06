//
//  SettingsViewController.h
//  LionsRoar
//
//  Created by Matt Dahl on 5/8/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BOOL hasAccessToFacebookAccounts;
@property (nonatomic) BOOL hasAccessToTwitterAccounts;

@end

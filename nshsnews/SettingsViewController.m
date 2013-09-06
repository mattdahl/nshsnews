//
//  SettingsViewController.m
//  LionsRoar
//
//  Created by Matt Dahl on 5/8/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "AboutViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>

@implementation SettingsViewController

@synthesize hasAccessToFacebookAccounts, hasAccessToTwitterAccounts;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        [self.tabBarItem setTitle:@"Settings"];
        [self.tabBarItem setImage:[UIImage imageNamed:@"SettingsTabBarImage"]];
        [self setTitle:@"Settings"];
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasBeenLaunched"]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"pushNotifications"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"autoUpdateArticles"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"cacheImages"];

            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasBeenLaunched"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        [self requestAccessForAccountType:ACAccountTypeIdentifierFacebook];
        [self requestAccessForAccountType:ACAccountTypeIdentifierTwitter];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self)
        return [self initWithStyle:UITableViewStyleGrouped];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)switchDidToggle:(id)sender {
    UISwitch *s = (UISwitch *)sender;    
    if ([s isOn]) {
        switch ([s tag]) {
            case 0:
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"pushNotifications"];
                break;
            case 1:
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"autoUpdateArticles"];
                break;
            case 2:
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"cacheImages"];
                break;
            default:
                break;
        }
    }
    else {
        switch ([s tag]) {
            case 0:
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"pushNotifications"];
                break;
            case 1:
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"autoUpdateArticles"];
                break;
            case 2:
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"cacheImages"];
                break;
            default:
                break;
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 3;
        case 2:
            return 2;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.section == 0) {
        [cell.textLabel setText:@"About"];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    else if (indexPath.section == 1) {
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        [switchView addTarget:self action:@selector(switchDidToggle:) forControlEvents:UIControlEventValueChanged];
        [switchView setTag:indexPath.row];
        [cell setAccessoryView:switchView];
        
        switch (indexPath.row) {
            case 0:
                [cell.textLabel setText:@"Push Notifications"];
                [switchView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"pushNotifications"]];
                break;
            case 1:
                [cell.textLabel setText:@"Auto-Update Articles"];
                [switchView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"autoUpdateArticles"]];
                break;
            case 2:
                [cell.textLabel setText:@"Cache Images"];
                [switchView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"cacheImages"]];
                break;
            default:
                break;
        }
    }
    else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
                [cell.textLabel setText:@"Facebook"];
                
                if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook] && hasAccessToFacebookAccounts)
                    [cell.detailTextLabel setText:[[self accountForAccountType:ACAccountTypeIdentifierFacebook] username]];
                else
                    [cell.detailTextLabel setText:@"Not Active"];
                break;
            case 1:
                [cell.textLabel setText:@"Twitter"];
                
                if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] && hasAccessToTwitterAccounts)
                    [cell.detailTextLabel setText:[[self accountForAccountType:ACAccountTypeIdentifierTwitter] username]];
                else
                    [cell.detailTextLabel setText:@"Not Active"];
                break;
            default:
                break;
        }
    }
    
    return cell;
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Reading Preferences";
        case 1:
            return @"Social Media";
        default:
            return @"";
            break;
    }
}
*/
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 2)
        return @"Native social media integration can be configured from the Settings app.";
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        if (indexPath.row == 0 && ![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            UIViewController *facebookComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            for (UIView *view in [[facebookComposer view] subviews])
                [view removeFromSuperview];
            [self presentViewController:facebookComposer animated:NO completion:nil];
        }
        else if (indexPath.row == 1 && ![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            UIViewController *tweetComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            for (UIView *view in [[tweetComposer view] subviews])
                [view removeFromSuperview];
            [self presentViewController:tweetComposer animated:NO completion:nil];
        }
    }
    else if (indexPath.section == 0) {
        AboutViewController *avc = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
        [self.navigationController pushViewController:avc animated:YES];
    }
}

#pragma mark - Account methods

- (ACAccount *)accountForAccountType:(NSString *)type {    
    ACAccountStore *store = [[ACAccountStore alloc] init];
    
    return [[store accountsWithAccountType:[store accountTypeWithAccountTypeIdentifier:type]] objectAtIndex:0];
}

- (void)requestAccessForAccountType:(NSString *)type {
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *acType = [store accountTypeWithAccountTypeIdentifier:type];
    
    if ([type isEqualToString:ACAccountTypeIdentifierFacebook]) {
        NSDictionary *options = @{
                                  ACFacebookAppIdKey: @"369954733104428",
                                  ACFacebookPermissionsKey: @[@"publish_stream", @"publish_actions"],
                                  ACFacebookAudienceKey: ACFacebookAudienceFriends
                                  };
        [store requestAccessToAccountsWithType:acType options:options completion:^(BOOL granted, NSError *error) {
            if (granted) {
                hasAccessToFacebookAccounts = YES;
                [self.tableView reloadData];
            }
            else {
                NSLog(@"No Facebook Access Error");
            }
        }];
    }
    else if ([type isEqualToString:ACAccountTypeIdentifierTwitter])
        [store requestAccessToAccountsWithType:acType options:nil completion:^(BOOL granted, NSError *error) {
            if (granted) {
                hasAccessToTwitterAccounts = YES;
                [self.tableView reloadData];
            }
            else {
                NSLog(@"No Twitter Access Error");
            }
        }];
}

@end

//
//  SearchViewController.m
//  LionsRoar
//
//  Created by Matt Dahl on 2/25/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultsViewController.h"
#import "NSHSNewsSearchBar.h"
#import "ArticleStore.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {        
        sourceOptions = malloc(3 * sizeof(bool));
        sourceOptions[0] = true;
        sourceOptions[1] = false;
        sourceOptions[2] = false;
        
        checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark.png"]];
        
        lionsRoarSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [lionsRoarSwitch setOn:YES animated:NO];
        denebolaSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [denebolaSwitch setOn:YES animated:NO];
        
        [self.navigationItem setTitle:@"Search"];
        [self.tabBarItem setImage:[UIImage imageNamed:@"SearchTabBarImage"]];
        [self setTitle:@"Search"];
        
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [(NSHSNewsSearchBar *)searchBar setInputView:[[UIDatePicker alloc] init]];
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.view removeGestureRecognizer:tapRecognizer];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSArray *foundArticles;

    if (sourceOptions[0] == true) {
        if ([lionsRoarSwitch isOn] && [denebolaSwitch isOn])
            foundArticles = [ArticleStore searchArticleStoreWithSearchType:titleSearchType filterType:allFilterType criterion:searchBar.text];
        else if ([lionsRoarSwitch isOn])
            foundArticles = [ArticleStore searchArticleStoreWithSearchType:titleSearchType filterType:lionsRoarFilterType criterion:searchBar.text];
        else if ([denebolaSwitch isOn])
            foundArticles = [ArticleStore searchArticleStoreWithSearchType:titleSearchType filterType:denebolaFilterType criterion:searchBar.text];
        else {
            [[[UIAlertView alloc] initWithTitle:@"Invalid search."
                                        message:@"Select at least one newspaper to search!"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            return;
        }
    }
    else if (sourceOptions[1] == true) {
        if ([lionsRoarSwitch isOn] && [denebolaSwitch isOn])
            foundArticles = [ArticleStore searchArticleStoreWithSearchType:authorSearchType filterType:allFilterType criterion:searchBar.text];
        else if ([lionsRoarSwitch isOn])
            foundArticles = [ArticleStore searchArticleStoreWithSearchType:authorSearchType filterType:lionsRoarFilterType criterion:searchBar.text];
        else if ([denebolaSwitch isOn])
            foundArticles = [ArticleStore searchArticleStoreWithSearchType:authorSearchType filterType:denebolaFilterType criterion:searchBar.text];
        else {
            [[[UIAlertView alloc] initWithTitle:@"Invalid search."
                                        message:@"Select at least one newspaper to search!"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            return;
        }
    }
    else if (sourceOptions[2] == true) {
        if ([lionsRoarSwitch isOn] && [denebolaSwitch isOn])
            foundArticles = [ArticleStore searchArticleStoreWithSearchType:bodySearchType filterType:allFilterType criterion:searchBar.text];
        else if ([lionsRoarSwitch isOn])
            foundArticles = [ArticleStore searchArticleStoreWithSearchType:bodySearchType filterType:lionsRoarFilterType criterion:searchBar.text];
        else if ([denebolaSwitch isOn])
            foundArticles = [ArticleStore searchArticleStoreWithSearchType:bodySearchType filterType:denebolaFilterType criterion:searchBar.text];
        else {
            [[[UIAlertView alloc] initWithTitle:@"Invalid search."
                                        message:@"Select at least one newspaper to search!"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            return;
        }
    }
    
    if ([foundArticles count] == 0)
        [[[UIAlertView alloc] initWithTitle:@"No articles found."
                                    message:@"Try searching with other terms, or change the criterion."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    else {
        SearchResultsViewController *srvc = [[SearchResultsViewController alloc] initWithNibName:@"SearchResultsViewController"
                                                                                          bundle:nil
                                                                                        articles:foundArticles];
        [self.navigationController pushViewController:srvc
                                             animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 2;
        case 1:
            return 3;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                [cell.textLabel setText:@"Lion's Roar Articles"];
                [cell setAccessoryView:lionsRoarSwitch];
                break;
            case 1:
                [cell.textLabel setText:@"Denebola Articles"];
                [cell setAccessoryView:denebolaSwitch];
                break;
            default:
                break;
        }
    }
    else if (indexPath.section == 1) {
        if (sourceOptions[indexPath.row])
            [cell setAccessoryView:checkmark];
        else
            [cell setAccessoryView:nil];
        
        switch (indexPath.row) {
            case 0:
                [cell.textLabel setText:@"Search Title"];
                break;
            case 1:
                [cell.textLabel setText:@"Search Author"];
                break;
            case 2:
                [cell.textLabel setText:@"Search Article Body"];
                break;
            default:
                break;
        }
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Filter Sources";
        case 1:
            return @"Search Criterion";
        default:
            return @"";
            break;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (sourceOptions[indexPath.row])
            sourceOptions[indexPath.row] = false;
        else {
            for (int i = 0; i < 3; i++)
                sourceOptions[i] = false;
            sourceOptions[indexPath.row] = true;
        }
        [tableView reloadData];
    }
}

@end

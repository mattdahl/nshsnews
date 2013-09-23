//
//  TopNewsTableViewController.m
//  LionsRoar
//
//  Created by Matt Dahl on 3/29/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import "TopNewsTableViewController.h"
#import "TopArticleCell.h"
#import "Article.h"
#import "ArticleCell.h"
#import "APIConnection.h"
#import "ArticleStore.h"
#import "ArticleViewController.h"

@implementation TopNewsTableViewController

@synthesize loadingViewController;

static NSArray *articles;

- (id)init {
    self = [super init];
    if (self) {
        isFinishedLoading = NO;
        [self.navigationItem setTitle:@"Top News"];
        
        [self.tableView setDelegate:self]; // this controller conforms to the UITableViewDelegate protocol
        
        [self.tabBarItem setTitle:@"Top News"];
        [self.tabBarItem setImage:[UIImage imageNamed:@"TopNewsTabBarImage"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"ArticleCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ArticleCell"];
    
    if ([ArticleStore hasArticlesForSection:@"Top News"]) {
        articles = [ArticleStore getArticlesForSection:@"Top News"];
        [ArticleStore updateArticles];
    }
    else
        loadingViewController = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil delegate:self task:[ArticleStore isFinishedLoadingArticlesBlock]];
    
    UIRefreshControl *r = [[UIRefreshControl alloc] init];
    [r setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Pull to Refresh"]];
    [r addTarget:self
          action:@selector(refreshView:)
forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:r];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!isFinishedLoading)
        [UIApplication.sharedApplication.delegate.window addSubview:loadingViewController.view];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [loadingViewController.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNeedsRefresh {
    [self loadArticles];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [articles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *regularCellIdentifier = @"ArticleCell";
    static NSString *topCellIndentifer = @"TopArticleCell";
    
    UITableViewCell *cell;
    Article *a = [articles objectAtIndex:indexPath.row];
    
    if (indexPath.row == 0) {
        cell = (TopArticleCell *)[tableView dequeueReusableCellWithIdentifier:topCellIndentifer];
        if (!cell)
            cell = [[TopArticleCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:topCellIndentifer
                                             withArticle:[articles objectAtIndex:indexPath.row]];
       
        [(TopArticleCell *)cell setArticle:a];
        [[(TopArticleCell *)cell articleTitle] setText:a.title];
        [a setDelegate:(TopArticleCell *)cell];
        [[(TopArticleCell *)cell bigThumbnailImageView] setImage:nil]; // clears old thumbnail
        [(TopArticleCell *)cell setNeedsDisplay];            
    }
    else {
        cell = (ArticleCell *)[tableView dequeueReusableCellWithIdentifier:regularCellIdentifier];
        
        [(ArticleCell *)cell setArticle:a];
        [a setDelegate:(ArticleCell *)cell];
        [[(ArticleCell *)cell thumbnailImageView] setImage:nil]; // clears old thumbnail
        [(ArticleCell *)cell setNeedsDisplay];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMMM dd, yyyy"];
        NSString *formattedDate = [formatter stringFromDate:a.date];
        [[(ArticleCell *)cell articleDate] setText:formattedDate];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0)
        return 180;
    else
        return 80;
}

#pragma mark - Refresh callback

- (void)refreshView:(UIRefreshControl *)r {
    [r setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Refreshing data..."]];
    
    [ArticleStore updateArticles];
    [self loadArticles];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, HH:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[ArticleStore lastUpdateDate]]];
    [r setAttributedTitle:[[NSAttributedString alloc] initWithString:lastUpdated]];
    [r endRefreshing];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *navBarTitle = [NSString stringWithFormat:@"%d of %d", indexPath.row+1, [articles count]];
    ArticleViewController *avc = [[ArticleViewController alloc] initWithNibName:@"ArticleViewController"
                                                                         bundle:nil
                                                                        article:[articles objectAtIndex:indexPath.row]
                                                                    navBarTitle:navBarTitle];
    [[articles objectAtIndex:indexPath.row] setDelegate:avc]; // passes the delegate
    [self.navigationController pushViewController:avc animated:YES];
}

- (void)loadArticles {
    articles = [ArticleStore getArticlesForSection:@"Top News"];
    [self.tableView reloadData];
}

#pragma mark - LoadingViewControllerDelegate

- (BOOL)shouldLoadingViewControllerAnimate:(LoadingViewController *)loadingViewController {
    return YES;
}

- (void)loadingViewControllerDidStartLoading:(LoadingViewController *)loadingViewController {
    [UIApplication.sharedApplication.delegate.window addSubview:self->loadingViewController.view];
}

- (void)loadingViewControllerDidFinishLoading:(LoadingViewController *)loadingViewController {
    isFinishedLoading = true;
    [self->loadingViewController.view removeFromSuperview];
    [self loadArticles];
    [self.tableView reloadData];
    [self.tableView setUserInteractionEnabled:YES];
}

@end
